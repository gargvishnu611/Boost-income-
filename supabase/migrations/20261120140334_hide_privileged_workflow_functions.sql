
alter function public.apply_to_task(uuid,text) set schema private;
alter function public.submit_task_work(uuid,text,text) set schema private;
alter function public.claim_daily_checkin() set schema private;
alter function public.review_submission(uuid,text,text,text) set schema private;
alter function public.complete_learning_course(uuid,jsonb) set schema private;

create or replace function public.apply_to_task(task_uuid uuid, proposal_text text)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.apply_to_task(task_uuid,proposal_text); $$;

create or replace function public.submit_task_work(assignment_uuid uuid, body_text text, evidence_url text default null)
returns uuid
language sql
security invoker
set search_path = ''
as $$ select private.submit_task_work(assignment_uuid,body_text,evidence_url); $$;

create or replace function public.claim_daily_checkin()
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.claim_daily_checkin(); $$;

create or replace function public.review_submission(submission_uuid uuid, review_decision text, decision_reason_code text, decision_reason text)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.review_submission(submission_uuid,review_decision,decision_reason_code,decision_reason); $$;

create or replace function public.complete_learning_course(course_uuid uuid, quiz_answers jsonb)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.complete_learning_course(course_uuid,quiz_answers); $$;

revoke all on function private.apply_to_task(uuid,text) from public,anon;
revoke all on function private.submit_task_work(uuid,text,text) from public,anon;
revoke all on function private.claim_daily_checkin() from public,anon;
revoke all on function private.review_submission(uuid,text,text,text) from public,anon;
revoke all on function private.complete_learning_course(uuid,jsonb) from public,anon;
grant execute on function private.apply_to_task(uuid,text) to authenticated;
grant execute on function private.submit_task_work(uuid,text,text) to authenticated;
grant execute on function private.claim_daily_checkin() to authenticated;
grant execute on function private.review_submission(uuid,text,text,text) to authenticated;
grant execute on function private.complete_learning_course(uuid,jsonb) to authenticated;

revoke all on function public.apply_to_task(uuid,text) from public,anon;
revoke all on function public.submit_task_work(uuid,text,text) from public,anon;
revoke all on function public.claim_daily_checkin() from public,anon;
revoke all on function public.review_submission(uuid,text,text,text) from public,anon;
revoke all on function public.complete_learning_course(uuid,jsonb) from public,anon;
grant execute on function public.apply_to_task(uuid,text) to authenticated;
grant execute on function public.submit_task_work(uuid,text,text) to authenticated;
grant execute on function public.claim_daily_checkin() to authenticated;
grant execute on function public.review_submission(uuid,text,text,text) to authenticated;
grant execute on function public.complete_learning_course(uuid,jsonb) to authenticated;
