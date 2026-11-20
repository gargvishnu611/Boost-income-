
create or replace function public.submit_task_work(assignment_uuid uuid, body_text text, evidence_url text default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  assignment_row public.assignments%rowtype;
  latest_status text;
  new_submission uuid;
  next_version integer;
begin
  if actor is null then raise exception 'Sign in is required'; end if;
  if char_length(trim(body_text)) < 10 or char_length(body_text) > 12000 then
    raise exception 'Submission must be between 10 and 12000 characters';
  end if;
  if evidence_url is not null and evidence_url !~ '^https?://' then
    raise exception 'Evidence link must start with http or https';
  end if;
  select * into assignment_row from public.assignments
  where id=assignment_uuid and member_id=actor;
  if not found or assignment_row.status not in ('active','submitted') then
    raise exception 'Active assignment not found';
  end if;
  select status into latest_status from public.submissions
  where assignment_id=assignment_uuid order by version desc limit 1;
  if assignment_row.status='submitted' and latest_status <> 'changes_requested' then
    raise exception 'This work is already submitted and awaiting review';
  end if;
  select coalesce(max(version),0)+1 into next_version from public.submissions where assignment_id=assignment_uuid;
  if next_version > 5 then raise exception 'Maximum revision count reached'; end if;
  insert into public.submissions(assignment_id,task_id,member_id,submission_text,proof_url,version,status)
  values(assignment_uuid,assignment_row.task_id,actor,trim(body_text),evidence_url,next_version,'submitted')
  returning id into new_submission;
  update public.assignments set status='submitted' where id=assignment_uuid;
  return new_submission;
end;
$$;

create or replace function public.review_submission(
  submission_uuid uuid,
  review_decision text,
  decision_reason_code text,
  decision_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  sub_row public.submissions%rowtype;
  task_row public.tasks%rowtype;
begin
  if actor is null or not private.is_staff(array['reviewer','super_admin']) then
    raise exception 'Reviewer access is required';
  end if;
  if review_decision not in ('accepted','changes_requested','rejected') then
    raise exception 'Invalid review decision';
  end if;
  if char_length(trim(decision_reason)) < 5 or char_length(decision_reason) > 3000 then
    raise exception 'A clear review reason is required';
  end if;
  select * into sub_row from public.submissions where id=submission_uuid for update;
  if not found or sub_row.status not in ('submitted','quality_review','client_review') then
    raise exception 'Submission is not awaiting review';
  end if;
  select * into task_row from public.tasks where id=sub_row.task_id;
  if not found then raise exception 'Task was not found'; end if;
  if not task_row.is_demo then
    raise exception 'Paid and crypto work settlement has not been enabled; do not approve this item yet';
  end if;

  insert into public.review_decisions(submission_id,reviewer_id,decision,reason_code,reason)
  values(submission_uuid,actor,review_decision,coalesce(nullif(trim(decision_reason_code),''),'review_note'),trim(decision_reason));

  update public.submissions set status=review_decision where id=submission_uuid;
  update public.assignments set status=case
    when review_decision='accepted' then 'accepted'
    when review_decision='changes_requested' then 'active'
    else 'rejected' end
  where id=sub_row.assignment_id;

  if review_decision='accepted' then
    insert into public.xp_ledger(member_id,amount,reason,source_type,source_id)
    values(sub_row.member_id,10,'Accepted practice contribution: '||task_row.title,'accepted_practice',submission_uuid)
    on conflict do nothing;
    insert into public.contribution_ledger(member_id,amount,reason,source_type,source_id)
    values(sub_row.member_id,1,'Verified practice contribution: '||task_row.title,'accepted_practice',submission_uuid)
    on conflict do nothing;
  end if;

  return jsonb_build_object('submission_id',submission_uuid,'status',review_decision);
end;
$$;

revoke all on function public.submit_task_work(uuid,text,text) from public,anon;
grant execute on function public.submit_task_work(uuid,text,text) to authenticated;
revoke all on function public.review_submission(uuid,text,text,text) from public,anon;
grant execute on function public.review_submission(uuid,text,text,text) to authenticated;
