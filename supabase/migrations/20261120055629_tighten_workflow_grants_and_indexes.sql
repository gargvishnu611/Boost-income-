
grant usage on schema private to anon;
grant execute on function private.is_staff(text[]) to anon;
grant execute on function private.has_org_role(uuid,text[]) to anon;

-- Never expose internal snapshot ownership identifiers through the public base table.
revoke select on public.public_snapshots from anon,authenticated;
grant select(slug,display_name,headline,skills,badges,approved_work_count,completed_projects_count,is_active,published_at,expires_at,revoked_at)
on public.public_snapshots to anon,authenticated;

-- Clients can apply and submit only as their signed-in identity; workflow status stays server-controlled.
revoke insert on public.applications from authenticated;
grant insert(task_id,member_id,proposal) on public.applications to authenticated;
alter table public.applications alter column member_id set default auth.uid();
drop policy if exists applications_apply_self on public.applications;
create policy applications_apply_self on public.applications for insert to authenticated
with check(member_id=(select auth.uid()) and status='submitted' and exists(
  select 1 from public.tasks t where t.id=task_id and t.status='open'
  and (t.is_demo or exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.marketplace_eligible))
));

revoke insert on public.submissions from authenticated;
grant insert(assignment_id,task_id,member_id,submission_text,proof_url,version) on public.submissions to authenticated;
alter table public.submissions alter column member_id set default auth.uid();
drop policy if exists submissions_insert_assigned on public.submissions;
create policy submissions_insert_assigned on public.submissions for insert to authenticated
with check(member_id=(select auth.uid()) and status='submitted' and exists(
  select 1 from public.assignments a where a.id=assignment_id and a.member_id=(select auth.uid()) and a.task_id=task_id and a.status='active'
));

-- Organization and verification status are controlled by verified operations staff.
revoke insert on public.organizations from authenticated;
grant insert(owner_user_id,name,organization_type,website,country_code) on public.organizations to authenticated;
drop policy if exists organizations_insert_owner on public.organizations;
create policy organizations_insert_owner on public.organizations for insert to authenticated
with check(owner_user_id=(select auth.uid()) and verification_status='unverified');

revoke insert on public.verification_cases from authenticated;
grant insert(organization_id,user_id,case_type) on public.verification_cases to authenticated;
drop policy if exists verification_insert_self on public.verification_cases;
create policy verification_insert_self on public.verification_cases for insert to authenticated
with check(status='pending' and reviewed_at is null and reviewer_id is null and
 ((user_id=(select auth.uid()) and case_type in ('identity','marketplace_eligibility')) or
  (organization_id is not null and case_type='business' and (select private.has_org_role(organization_id,array['owner'])))));

-- Organization membership is created by a trusted trigger when an organization is created.
revoke insert on public.organization_members from authenticated;

-- Learning completion and awards are written by trusted server-side endpoints.
revoke insert,update on public.course_progress from authenticated;
grant select on public.course_progress to authenticated;

create index if not exists account_roles_assigned_by_idx on public.account_roles(assigned_by);
create index if not exists applications_member_idx on public.applications(member_id);
create index if not exists assignments_member_idx on public.assignments(member_id);
create index if not exists audit_events_actor_idx on public.audit_events(actor_id);
create index if not exists campaign_funding_events_campaign_idx on public.campaign_funding_events(campaign_id);
create index if not exists campaigns_created_by_idx on public.campaigns(created_by);
create index if not exists campaigns_org_status_idx on public.campaigns(organization_id,status,funding_state);
create index if not exists cash_ledger_campaign_idx on public.cash_ledger(campaign_id);
create index if not exists cash_ledger_submission_idx on public.cash_ledger(submission_id);
create index if not exists contact_messages_member_idx on public.contact_messages(member_id);
create index if not exists course_progress_course_idx on public.course_progress(course_id);
create index if not exists crypto_allocations_task_idx on public.crypto_reward_allocations(task_id);
create index if not exists crypto_wallets_member_idx on public.crypto_wallets(member_id);
create index if not exists daily_activity_xp_idx on public.daily_activity(xp_entry_id);
create index if not exists learning_courses_reviewed_by_idx on public.learning_courses(reviewed_by);
create index if not exists organization_members_user_idx on public.organization_members(user_id);
create index if not exists organizations_owner_idx on public.organizations(owner_user_id);
create index if not exists public_snapshots_member_idx on public.public_snapshots(member_id);
create index if not exists referrals_referrer_idx on public.referrals(referrer_id);
create index if not exists review_decisions_reviewer_idx on public.review_decisions(reviewer_id);
create index if not exists review_decisions_submission_idx on public.review_decisions(submission_id);
create index if not exists submissions_assignment_idx on public.submissions(assignment_id);
create index if not exists submissions_member_idx on public.submissions(member_id);
create index if not exists submissions_task_idx on public.submissions(task_id);
create index if not exists support_messages_sender_idx on public.support_messages(sender_id);
create index if not exists support_messages_ticket_idx on public.support_messages(ticket_id);
create index if not exists support_tickets_member_idx on public.support_tickets(member_id);
create index if not exists support_tickets_task_idx on public.support_tickets(task_id);
create index if not exists tasks_created_by_idx on public.tasks(created_by);
create index if not exists tasks_campaign_status_idx on public.tasks(campaign_id,status);
create index if not exists verification_cases_org_idx on public.verification_cases(organization_id);
create index if not exists verification_cases_reviewer_idx on public.verification_cases(reviewer_id);
create index if not exists verification_cases_user_idx on public.verification_cases(user_id);
