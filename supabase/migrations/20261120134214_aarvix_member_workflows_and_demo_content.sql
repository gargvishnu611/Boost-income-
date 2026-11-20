
alter table public.tasks alter column created_by drop not null;

create or replace function public.apply_to_task(task_uuid uuid, proposal_text text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  task_row public.tasks%rowtype;
  application_row public.applications%rowtype;
  assignment_id uuid;
begin
  if actor is null then
    raise exception 'Sign in is required';
  end if;
  if char_length(trim(proposal_text)) < 10 or char_length(proposal_text) > 3000 then
    raise exception 'Proposal must be between 10 and 3000 characters';
  end if;
  select * into task_row from public.tasks where id = task_uuid and status = 'open';
  if not found then
    raise exception 'This task is not available';
  end if;
  if not task_row.is_demo then
    if not exists(select 1 from public.profiles p where p.id=actor and p.marketplace_eligible=true) then
      raise exception 'This account is not yet eligible for paid marketplace work';
    end if;
    if task_row.reward_asset='crypto' and not exists(select 1 from public.feature_flags f where f.key='crypto_rewards_enabled' and f.enabled) then
      raise exception 'Crypto rewards are not enabled yet';
    end if;
    if task_row.reward_asset='fiat' and not exists(select 1 from public.feature_flags f where f.key='paid_campaigns_enabled' and f.enabled) then
      raise exception 'Paid campaigns are not enabled yet';
    end if;
  end if;
  insert into public.applications(task_id,member_id,proposal,status)
  values(task_uuid,actor,trim(proposal_text),'submitted')
  on conflict(task_id,member_id) do update set proposal=excluded.proposal
  returning * into application_row;

  if task_row.is_demo then
    update public.applications set status='accepted' where id=application_row.id returning * into application_row;
    insert into public.assignments(task_id,application_id,member_id,status)
    values(task_uuid,application_row.id,actor,'active')
    on conflict(task_id,member_id) do update set status='active'
    returning id into assignment_id;
  end if;

  return jsonb_build_object(
    'application_id',application_row.id,
    'application_status',application_row.status,
    'assignment_id',assignment_id
  );
end;
$$;

create or replace function public.submit_task_work(assignment_uuid uuid, body_text text, evidence_url text default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  assignment_row public.assignments%rowtype;
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
  where id=assignment_uuid and member_id=actor and status='active';
  if not found then raise exception 'Active assignment not found'; end if;
  select coalesce(max(version),0)+1 into next_version from public.submissions where assignment_id=assignment_uuid;
  insert into public.submissions(assignment_id,task_id,member_id,submission_text,proof_url,version,status)
  values(assignment_uuid,assignment_row.task_id,actor,trim(body_text),evidence_url,next_version,'submitted')
  returning id into new_submission;
  update public.assignments set status='submitted' where id=assignment_uuid;
  return new_submission;
end;
$$;

create or replace function public.claim_daily_checkin()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  xp_id uuid;
begin
  if actor is null then raise exception 'Sign in is required'; end if;
  insert into public.daily_activity(member_id,activity_date,activity_type)
  values(actor,current_date,'daily_checkin')
  on conflict do nothing;
  if not found then
    return jsonb_build_object('claimed',false,'message','Already claimed today');
  end if;
  insert into public.xp_ledger(member_id,amount,reason,source_type,source_id)
  values(actor,1,'Daily learning check-in','daily_checkin',null)
  returning id into xp_id;
  update public.daily_activity set xp_entry_id=xp_id
  where member_id=actor and activity_date=current_date and activity_type='daily_checkin';
  return jsonb_build_object('claimed',true,'xp',1,'date',current_date);
end;
$$;

create or replace function private.guard_reward_feature_flags()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.reward_asset='fiat' and not exists(select 1 from public.feature_flags where key='paid_campaigns_enabled' and enabled) then
    raise exception 'Paid rewards are temporarily disabled';
  end if;
  if new.reward_asset='crypto' and not exists(select 1 from public.feature_flags where key='crypto_rewards_enabled' and enabled) then
    raise exception 'Crypto rewards are temporarily disabled pending approvals and funding';
  end if;
  if new.reward_asset='crypto' and new.crypto_network='solana-mainnet-beta'
    and not exists(select 1 from public.feature_flags where key='solana_mainnet_enabled' and enabled) then
    raise exception 'Solana mainnet rewards are not enabled';
  end if;
  return new;
end;
$$;

drop trigger if exists guard_task_reward_flags on public.tasks;
create trigger guard_task_reward_flags before insert or update of reward_asset,crypto_network on public.tasks
for each row execute procedure private.guard_reward_feature_flags();

revoke all on function public.apply_to_task(uuid,text) from public,anon;
revoke all on function public.submit_task_work(uuid,text,text) from public,anon;
revoke all on function public.claim_daily_checkin() from public,anon;
grant execute on function public.apply_to_task(uuid,text) to authenticated;
grant execute on function public.submit_task_work(uuid,text,text) to authenticated;
grant execute on function public.claim_daily_checkin() to authenticated;
revoke all on function private.guard_reward_feature_flags() from public,anon,authenticated;

insert into public.tasks
(campaign_id,title,description,category,skill_tags,level,estimated_minutes,requirements,acceptance_criteria,verification_rules,task_kind,reward_asset,is_demo,status,created_by)
values
(null,'Review a sample mobile onboarding flow','Explore a fictional onboarding flow and share clear, actionable feedback about confusing steps.','Product testing',array['UX','Testing','Writing'],'Beginner',20,
 array['Review all five sample screens','Identify at least two usability observations','Explain one improvement with a reason'],
 array['At least two specific observations','Clear rationale and actionable suggestion'],
 'Reviewed for completeness, clarity and specific evidence. Duplicate or generic submissions are not accepted.','contribution','none',true,'open',null),
(null,'Translate a short community guide','Translate a short fictional help guide while preserving meaning, tone and formatting.','Translation',array['Translation','Language'],'Intermediate',30,
 array['Translate all provided paragraphs','Keep product terms consistent','Add a note for ambiguous phrases'],
 array['Meaning preserved','Terminology consistent','Readable target-language text'],
 'Reviewed for accuracy, readability, originality and adherence to the brief.','contribution','none',true,'open',null),
(null,'Write a helpful first-time user FAQ','Draft a concise FAQ that answers common first-time user questions in plain language.','Writing',array['Writing','Research'],'Intermediate',40,
 array['Write five to seven useful questions','Keep answers factual and easy to scan','Avoid unsupported claims'],
 array['Five to seven relevant questions','Accurate, concise answers','No invented claims'],
 'Reviewed for usefulness, correctness, originality and clarity.','contribution','none',true,'open',null),
(null,'Create a simple campaign visual concept','Create a concept visual for a fictional community learning campaign.','Design',array['Graphic design','Accessibility'],'Advanced',60,
 array['Submit a preview image or design URL','Include a short design rationale','Use accessible contrast'],
 array['Fits the fictional brief','Includes design rationale','Uses readable contrast'],
 'Reviewed for brief fit, visual quality, originality and accessibility.','contribution','none',true,'open',null),
(null,'Organize a small public dataset','Clean and organize a fictional public dataset sample, documenting any assumptions.','Research',array['Data organization','Spreadsheets'],'Beginner',30,
 array['Preserve original source values','Flag missing or inconsistent fields','Summarize changes'],
 array['Source values preserved','Changes documented','Missing data flagged'],
 'Reviewed for accuracy, reproducibility and transparent handling of missing data.','contribution','none',true,'open',null)
on conflict do nothing;

insert into public.learning_courses(title,description,category,level,estimated_minutes,content,is_published,content_version)
values
('What counts as a useful contribution?','Learn how to identify work that genuinely helps another person or team.','Getting started','Beginner',4,
 '{"sections":[{"heading":"Quality over volume","body":"A contribution solves a real problem or helps another person. Quality and evidence matter more than activity volume."}],"quiz":[{"question":"What makes a contribution useful?","options":["Only the number of actions","A real problem solved with clear evidence","Posting repeatedly"],"answer":1}]}',true,'1'),
('How to write a strong task submission','Learn to read acceptance criteria and make proof easy to review.','Work skills','Beginner',6,
 '{"sections":[{"heading":"Before you start","body":"Read the acceptance criteria, ask questions when scope is unclear, and keep your work original."},{"heading":"Submitting proof","body":"Explain what you completed and make evidence easy for the reviewer to verify."}]}',true,'1'),
('Feedback that teams can actually use','Practice writing actionable feedback that includes context and a practical next step.','Communication','Beginner',5,
 '{"sections":[{"heading":"Be specific","body":"Describe what happened, include the context and suggest a practical next step."}]}',true,'1')
on conflict do nothing;

create index if not exists tasks_public_browse_idx on public.tasks(status,is_demo,category);
create index if not exists tasks_skills_gin_idx on public.tasks using gin(skill_tags);
create index if not exists assignments_member_status_idx on public.assignments(member_id,status,created_at desc);
create index if not exists applications_task_status_idx on public.applications(task_id,status,created_at desc);
create index if not exists submissions_assignment_version_idx on public.submissions(assignment_id,version desc);
