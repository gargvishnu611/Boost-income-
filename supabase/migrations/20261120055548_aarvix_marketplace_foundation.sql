
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated, service_role;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'AARVIX Member' check (char_length(display_name) between 1 and 60),
  avatar_url text, bio text not null default '' check(char_length(bio)<=500),
  country_code text check(country_code is null or country_code ~ '^[A-Z]{2}$'),
  marketplace_eligible boolean not null default false,
  eligibility_reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.account_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check(role in ('member','reviewer','support','finance','super_admin')),
  assigned_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  primary key(user_id,role)
);
create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users(id),
  name text not null check(char_length(name) between 2 and 120),
  organization_type text not null default 'business' check(organization_type in ('business','nonprofit','community','other')),
  website text, country_code text check(country_code is null or country_code ~ '^[A-Z]{2}$'),
  verification_status text not null default 'unverified' check(verification_status in ('unverified','pending','verified','rejected','suspended')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.organization_members (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  member_role text not null check(member_role in ('owner','manager','reviewer','finance','viewer')),
  created_at timestamptz not null default now(), primary key(organization_id,user_id)
);
create table public.verification_cases (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  case_type text not null check(case_type in ('business','identity','marketplace_eligibility')),
  status text not null default 'pending' check(status in ('pending','in_review','approved','rejected','needs_information')),
  submitted_at timestamptz not null default now(), reviewed_at timestamptz,
  reviewer_id uuid references auth.users(id), decision_reason text
);
create table public.campaigns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  title text not null check(char_length(title) between 4 and 140),
  description text not null check(char_length(description) between 20 and 10000),
  currency text not null default 'INR' check(currency ~ '^[A-Z]{3}$'),
  budget_minor bigint not null check(budget_minor > 0),
  funded_minor bigint not null default 0 check(funded_minor >= 0),
  service_fee_minor bigint not null default 0 check(service_fee_minor >= 0),
  status text not null default 'draft' check(status in ('draft','submitted','approved','awaiting_funding','open','paused','completed','cancelled')),
  funding_state text not null default 'unfunded' check(funding_state in ('unfunded','pending','funded','partially_refunded','refunded','failed')),
  funding_provider text, funding_reference text,
  country_eligibility text[] not null default '{}', terms_version text not null default 'v1',
  approved_at timestamptz, funded_at timestamptz, starts_at timestamptz, ends_at timestamptz,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check(funded_minor <= budget_minor),
  check(status <> 'open' or (funding_state='funded' and funded_minor>=budget_minor))
);
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid references public.campaigns(id) on delete cascade,
  title text not null check(char_length(title) between 4 and 140),
  description text not null check(char_length(description) between 20 and 10000),
  category text not null, skill_tags text[] not null default '{}',
  level text not null default 'Beginner' check(level in ('Beginner','Intermediate','Advanced','Expert')),
  estimated_minutes integer not null default 30 check(estimated_minutes between 1 and 10080),
  requirements text[] not null default '{}', acceptance_criteria text[] not null default '{}',
  verification_rules text not null,
  task_kind text not null default 'contribution' check(task_kind in ('contribution','paid_work','sponsored','bounty','competition','learning')),
  reward_asset text not null default 'none' check(reward_asset in ('none','fiat','crypto')),
  reward_amount_minor bigint check(reward_amount_minor is null or reward_amount_minor >= 0),
  reward_currency text check(reward_currency is null or reward_currency ~ '^[A-Z]{3}$'),
  crypto_asset_symbol text, crypto_network text check(crypto_network is null or crypto_network in ('solana-devnet','solana-mainnet-beta')),
  crypto_mint_address text,
  is_demo boolean not null default false,
  status text not null default 'draft' check(status in ('draft','moderation','awaiting_funding','open','paused','closed','cancelled')),
  max_workers integer check(max_workers is null or max_workers between 1 and 100000),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check(is_demo or campaign_id is not null),
  check((reward_asset='none' and reward_amount_minor is null and crypto_asset_symbol is null)
     or (reward_asset='fiat' and reward_amount_minor is not null and reward_currency is not null)
     or (reward_asset='crypto' and crypto_asset_symbol is not null and crypto_network is not null)),
  check(not is_demo or reward_asset='none')
);
create table public.applications (
  id uuid primary key default gen_random_uuid(), task_id uuid not null references public.tasks(id) on delete cascade,
  member_id uuid not null references auth.users(id) on delete cascade,
  proposal text not null check(char_length(proposal) between 10 and 3000),
  status text not null default 'submitted' check(status in ('submitted','shortlisted','accepted','declined','withdrawn')),
  created_at timestamptz not null default now(), unique(task_id,member_id)
);
create table public.assignments (
  id uuid primary key default gen_random_uuid(), task_id uuid not null references public.tasks(id),
  application_id uuid not null unique references public.applications(id), member_id uuid not null references auth.users(id),
  status text not null default 'active' check(status in ('active','submitted','accepted','rejected','cancelled','disputed')),
  due_at timestamptz, created_at timestamptz not null default now(), unique(task_id,member_id)
);
create table public.submissions (
  id uuid primary key default gen_random_uuid(), assignment_id uuid not null references public.assignments(id),
  task_id uuid not null references public.tasks(id), member_id uuid not null references auth.users(id),
  submission_text text not null check(char_length(submission_text) between 10 and 12000),
  proof_url text, version integer not null default 1 check(version between 1 and 20),
  status text not null default 'submitted' check(status in ('submitted','quality_review','client_review','changes_requested','accepted','rejected','disputed')),
  submitted_at timestamptz not null default now(), unique(assignment_id,version)
);
create table public.review_decisions (
  id uuid primary key default gen_random_uuid(), submission_id uuid not null references public.submissions(id) on delete cascade,
  reviewer_id uuid not null references auth.users(id),
  decision text not null check(decision in ('accepted','changes_requested','rejected')),
  reason_code text not null, reason text not null check(char_length(reason) between 5 and 3000),
  evidence jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create table public.xp_ledger (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id),
  amount integer not null check(amount <> 0), reason text not null, source_type text not null, source_id uuid,
  created_at timestamptz not null default now()
);
create unique index xp_ledger_idempotency on public.xp_ledger(member_id,source_type,source_id) where source_id is not null;
create index xp_ledger_member_time on public.xp_ledger(member_id,created_at desc);
create table public.contribution_ledger (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id),
  amount integer not null check(amount <> 0), reason text not null, source_type text not null, source_id uuid,
  created_at timestamptz not null default now()
);
create unique index contribution_ledger_idempotency on public.contribution_ledger(member_id,source_type,source_id) where source_id is not null;
create index contribution_ledger_member_time on public.contribution_ledger(member_id,created_at desc);
create table public.cash_ledger (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id),
  amount_minor bigint not null check(amount_minor <> 0), currency text not null check(currency ~ '^[A-Z]{3}$'),
  entry_type text not null check(entry_type in ('accepted_work','adjustment','refund','payout','reversal')),
  status text not null check(status in ('pending','payable','processing','paid','reversed','disputed')),
  campaign_id uuid references public.campaigns(id), submission_id uuid references public.submissions(id),
  provider_reference text, created_at timestamptz not null default now()
);
create index cash_ledger_member_time on public.cash_ledger(member_id,created_at desc);
create table public.crypto_wallets (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id),
  network text not null check(network in ('solana-devnet','solana-mainnet-beta')), wallet_address text not null,
  is_primary boolean not null default false, is_verified boolean not null default false,
  consented_at timestamptz not null default now(), revoked_at timestamptz, created_at timestamptz not null default now(),
  unique(network,wallet_address)
);
create table public.crypto_reward_allocations (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id),
  task_id uuid references public.tasks(id), asset_symbol text not null,
  network text not null check(network in ('solana-devnet','solana-mainnet-beta')), mint_address text,
  amount_base_units numeric(78,0) not null check(amount_base_units>0),
  status text not null default 'queued' check(status in ('queued','approved','broadcast','confirmed','failed','reversed')),
  transaction_signature text unique, provider_reference text, created_at timestamptz not null default now(), confirmed_at timestamptz
);
create index crypto_allocations_member_time on public.crypto_reward_allocations(member_id,created_at desc);
create table public.daily_activity (
  member_id uuid not null references auth.users(id), activity_date date not null default current_date,
  activity_type text not null check(activity_type in ('daily_checkin','lesson_complete','quiz_complete')),
  xp_entry_id uuid references public.xp_ledger(id), created_at timestamptz not null default now(),
  primary key(member_id,activity_date,activity_type)
);
create table public.learning_courses (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null, category text not null,
  level text not null default 'Beginner', estimated_minutes integer not null default 10 check(estimated_minutes between 1 and 10000),
  content jsonb not null default '{}'::jsonb, is_published boolean not null default false, content_version text not null default '1',
  reviewed_by uuid references auth.users(id), reviewed_at timestamptz, created_at timestamptz not null default now()
);
create table public.course_progress (
  member_id uuid not null references auth.users(id), course_id uuid not null references public.learning_courses(id) on delete cascade,
  status text not null default 'started' check(status in ('started','completed')),
  progress_percent integer not null default 0 check(progress_percent between 0 and 100),
  completed_at timestamptz, updated_at timestamptz not null default now(), primary key(member_id,course_id)
);
create table public.contact_messages (
  id uuid primary key default gen_random_uuid(), name text not null check(char_length(name) between 1 and 100),
  email text not null check(char_length(email) between 3 and 254), subject text not null check(char_length(subject) between 2 and 160),
  message text not null check(char_length(message) between 5 and 5000),
  status text not null default 'new' check(status in ('new','in_progress','resolved','spam')),
  member_id uuid references auth.users(id), created_at timestamptz not null default now()
);
create table public.support_tickets (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references auth.users(id), task_id uuid references public.tasks(id),
  ticket_type text not null check(ticket_type in ('question','appeal','payment','privacy','report','other')),
  subject text not null check(char_length(subject) between 3 and 160), status text not null default 'open' check(status in ('open','waiting','resolved','closed')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.support_messages (
  id uuid primary key default gen_random_uuid(), ticket_id uuid not null references public.support_tickets(id) on delete cascade,
  sender_id uuid references auth.users(id), message text not null check(char_length(message) between 1 and 8000),
  staff_only boolean not null default false, created_at timestamptz not null default now()
);
create table public.public_snapshots (
  id uuid primary key default gen_random_uuid(), slug text not null unique default encode(gen_random_bytes(12),'hex'),
  member_id uuid not null references auth.users(id), display_name text not null check(char_length(display_name) between 1 and 60),
  headline text not null default 'AARVIX contributor' check(char_length(headline)<=140),
  skills text[] not null default '{}', badges text[] not null default '{}',
  approved_work_count integer not null default 0 check(approved_work_count>=0),
  completed_projects_count integer not null default 0 check(completed_projects_count>=0),
  is_active boolean not null default false, published_at timestamptz, expires_at timestamptz, revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create table public.referrals (
  id uuid primary key default gen_random_uuid(), referrer_id uuid not null references auth.users(id),
  referred_member_id uuid unique references auth.users(id), referral_code text not null unique,
  status text not null default 'created' check(status in ('created','qualified','rewarded','rejected')),
  qualified_at timestamptz, created_at timestamptz not null default now(), check(referrer_id<>referred_member_id)
);
create table public.campaign_funding_events (
  id uuid primary key default gen_random_uuid(), campaign_id uuid not null references public.campaigns(id),
  provider text not null, provider_event_id text not null unique, event_type text not null,
  amount_minor bigint not null check(amount_minor>=0), currency text not null check(currency ~ '^[A-Z]{3}$'),
  signature_verified boolean not null default false, received_at timestamptz not null default now()
);
create table public.feature_flags (
  key text primary key, enabled boolean not null default false, public_description text not null, updated_at timestamptz not null default now()
);
create table public.audit_events (
  id bigint generated always as identity primary key, actor_id uuid references auth.users(id),
  action text not null, object_type text not null, object_id text, reason text,
  metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);

insert into public.feature_flags(key,enabled,public_description) values
('member_auth_enabled',true,'Email verification required'),
('client_workspaces_enabled',true,'Business workspace registration and drafting'),
('paid_campaigns_enabled',false,'Paid campaigns remain closed until legal and payment checks are approved'),
('crypto_rewards_enabled',false,'Crypto reward transfers remain disabled pending approvals and funding'),
('solana_devnet_enabled',false,'Devnet tests can be enabled after a test mint is created'),
('solana_mainnet_enabled',false,'Mainnet token rewards are disabled'),
('cash_payouts_enabled',false,'Cash payouts require an approved provider and reconciled funding'),
('public_snapshots_enabled',true,'Snapshots show only approved public summary fields')
on conflict(key) do nothing;

create or replace function private.is_staff(required_roles text[] default array['reviewer','support','finance','super_admin'])
returns boolean language sql stable security definer set search_path = ''
as $$
select (select auth.uid()) is not null and exists(
  select 1 from public.account_roles ar where ar.user_id=(select auth.uid()) and ar.role=any(required_roles)
);
$$;
create or replace function private.has_org_role(org_id uuid, allowed_roles text[] default array['owner','manager','reviewer','finance','viewer'])
returns boolean language sql stable security definer set search_path = ''
as $$
select (select auth.uid()) is not null and exists(
  select 1 from public.organization_members om where om.organization_id=org_id
  and om.user_id=(select auth.uid()) and om.member_role=any(allowed_roles)
);
$$;
create or replace function private.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles(id,display_name) values(new.id,coalesce(nullif(new.raw_user_meta_data->>'display_name',''),'AARVIX Member')) on conflict(id) do nothing;
  insert into public.account_roles(user_id,role) values(new.id,'member') on conflict do nothing;
  return new;
end;
$$;
create or replace function private.add_org_owner()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.organization_members(organization_id,user_id,member_role) values(new.id,new.owner_user_id,'owner') on conflict do nothing;
  return new;
end;
$$;
create or replace function private.set_updated_at()
returns trigger language plpgsql set search_path = ''
as $$ begin new.updated_at=now(); return new; end; $$;

revoke all on function private.is_staff(text[]) from public,anon;
revoke all on function private.has_org_role(uuid,text[]) from public,anon;
revoke all on function private.handle_new_user() from public,anon,authenticated;
revoke all on function private.add_org_owner() from public,anon,authenticated;
revoke all on function private.set_updated_at() from public,anon,authenticated;
grant execute on function private.is_staff(text[]) to authenticated;
grant execute on function private.has_org_role(uuid,text[]) to authenticated;

create trigger aarvix_auth_user_created after insert on auth.users for each row execute procedure private.handle_new_user();
create trigger aarvix_org_owner_created after insert on public.organizations for each row execute procedure private.add_org_owner();
create trigger profiles_updated before update on public.profiles for each row execute procedure private.set_updated_at();
create trigger organizations_updated before update on public.organizations for each row execute procedure private.set_updated_at();
create trigger campaigns_updated before update on public.campaigns for each row execute procedure private.set_updated_at();
create trigger tasks_updated before update on public.tasks for each row execute procedure private.set_updated_at();
create trigger support_tickets_updated before update on public.support_tickets for each row execute procedure private.set_updated_at();

create view public.public_contribution_snapshots with (security_invoker=true) as
select slug,display_name,headline,skills,badges,approved_work_count,completed_projects_count,published_at,expires_at
from public.public_snapshots where is_active and revoked_at is null and (expires_at is null or expires_at>now());

alter table public.profiles enable row level security;
alter table public.account_roles enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.verification_cases enable row level security;
alter table public.campaigns enable row level security;
alter table public.tasks enable row level security;
alter table public.applications enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.review_decisions enable row level security;
alter table public.xp_ledger enable row level security;
alter table public.contribution_ledger enable row level security;
alter table public.cash_ledger enable row level security;
alter table public.crypto_wallets enable row level security;
alter table public.crypto_reward_allocations enable row level security;
alter table public.daily_activity enable row level security;
alter table public.learning_courses enable row level security;
alter table public.course_progress enable row level security;
alter table public.contact_messages enable row level security;
alter table public.support_tickets enable row level security;
alter table public.support_messages enable row level security;
alter table public.public_snapshots enable row level security;
alter table public.referrals enable row level security;
alter table public.campaign_funding_events enable row level security;
alter table public.feature_flags enable row level security;
alter table public.audit_events enable row level security;

-- Profiles
grant select on public.profiles to authenticated;
grant update(display_name,avatar_url,bio,country_code) on public.profiles to authenticated;
create policy profiles_select_self_staff on public.profiles for select to authenticated
using(id=(select auth.uid()) or (select private.is_staff()));
create policy profiles_update_self on public.profiles for update to authenticated
using(id=(select auth.uid())) with check(id=(select auth.uid()));

-- Account roles
grant select on public.account_roles to authenticated;
create policy account_roles_read_self_staff on public.account_roles for select to authenticated
using(user_id=(select auth.uid()) or (select private.is_staff(array['super_admin'])));

-- Organizations / memberships
grant select,insert on public.organizations to authenticated;
grant insert(organization_id,user_id,member_role) on public.organization_members to authenticated;
grant select on public.organization_members to authenticated;
grant update(name,website,country_code) on public.organizations to authenticated;
create policy organizations_select_member on public.organizations for select to authenticated using((select private.has_org_role(id)));
create policy organizations_insert_owner on public.organizations for insert to authenticated with check(owner_user_id=(select auth.uid()) and verification_status='unverified');
create policy organizations_update_manager on public.organizations for update to authenticated
using((select private.has_org_role(id,array['owner','manager']))) with check((select private.has_org_role(id,array['owner','manager'])));
create policy memberships_select_related on public.organization_members for select to authenticated
using(user_id=(select auth.uid()) or (select private.has_org_role(organization_id,array['owner','manager'])));
create policy memberships_insert_owner on public.organization_members for insert to authenticated
with check(user_id=(select auth.uid()) and member_role='owner' and exists(select 1 from public.organizations o where o.id=organization_id and o.owner_user_id=(select auth.uid())));

-- Verification cases
grant select,insert on public.verification_cases to authenticated;
create policy verification_read_owner_staff on public.verification_cases for select to authenticated
using(user_id=(select auth.uid()) or (organization_id is not null and (select private.has_org_role(organization_id,array['owner','manager']))) or (select private.is_staff()));
create policy verification_insert_self on public.verification_cases for insert to authenticated
with check((user_id=(select auth.uid()) and case_type in ('identity','marketplace_eligibility')) or (organization_id is not null and case_type='business' and (select private.has_org_role(organization_id,array['owner']))));

-- Campaigns: client can draft, only server can mark approved or funded.
grant select on public.campaigns to authenticated;
grant insert(organization_id,title,description,currency,budget_minor,service_fee_minor,country_eligibility,terms_version,starts_at,ends_at) on public.campaigns to authenticated;
grant update(title,description,currency,budget_minor,service_fee_minor,country_eligibility,terms_version,starts_at,ends_at) on public.campaigns to authenticated;
create policy campaigns_select_participants on public.campaigns for select to authenticated
using((select private.has_org_role(organization_id)) or (status='open' and funding_state='funded' and funded_minor>=budget_minor) or (select private.is_staff()));
create policy campaigns_insert_draft on public.campaigns for insert to authenticated
with check(created_by=(select auth.uid()) and status='draft' and funding_state='unfunded' and funded_minor=0 and (select private.has_org_role(organization_id,array['owner','manager'])));
create policy campaigns_update_draft on public.campaigns for update to authenticated
using(status='draft' and (select private.has_org_role(organization_id,array['owner','manager'])))
with check(status='draft' and funding_state='unfunded' and funded_minor=0 and (select private.has_org_role(organization_id,array['owner','manager'])));

-- Tasks: examples are visible; paid tasks require a fully funded, open campaign.
grant select on public.tasks to anon,authenticated;
grant insert(campaign_id,title,description,category,skill_tags,level,estimated_minutes,requirements,acceptance_criteria,verification_rules,task_kind,reward_asset,reward_amount_minor,reward_currency,crypto_asset_symbol,crypto_network,crypto_mint_address,max_workers) on public.tasks to authenticated;
grant update(title,description,category,skill_tags,level,estimated_minutes,requirements,acceptance_criteria,verification_rules,task_kind,reward_asset,reward_amount_minor,reward_currency,crypto_asset_symbol,crypto_network,crypto_mint_address,max_workers) on public.tasks to authenticated;
create policy tasks_public_read on public.tasks for select to anon,authenticated
using((is_demo=true and status='open') or (status='open' and campaign_id is not null and exists(
  select 1 from public.campaigns c where c.id=campaign_id and c.status='open' and c.funding_state='funded' and c.funded_minor>=c.budget_minor
)) or (select private.is_staff()) or (campaign_id is not null and exists(select 1 from public.campaigns c where c.id=campaign_id and (select private.has_org_role(c.organization_id,array['owner','manager','reviewer'])))));
create policy tasks_insert_draft on public.tasks for insert to authenticated
with check(is_demo=false and status='draft' and created_by=(select auth.uid()) and campaign_id is not null and exists(
  select 1 from public.campaigns c where c.id=campaign_id and c.status='draft' and (select private.has_org_role(c.organization_id,array['owner','manager']))
));
create policy tasks_update_draft on public.tasks for update to authenticated
using(status='draft' and campaign_id is not null and exists(select 1 from public.campaigns c where c.id=campaign_id and (select private.has_org_role(c.organization_id,array['owner','manager']))))
with check(status='draft');

-- Applications, assignments and submissions
grant select,insert on public.applications to authenticated;
create policy applications_read_related on public.applications for select to authenticated
using(member_id=(select auth.uid()) or (select private.is_staff()) or exists(select 1 from public.tasks t join public.campaigns c on c.id=t.campaign_id where t.id=task_id and (select private.has_org_role(c.organization_id,array['owner','manager','reviewer']))));
create policy applications_apply_self on public.applications for insert to authenticated
with check(member_id=(select auth.uid()) and exists(
  select 1 from public.tasks t where t.id=task_id and t.status='open'
  and (t.is_demo or exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.marketplace_eligible))
));
grant select on public.assignments to authenticated;
create policy assignments_read_related on public.assignments for select to authenticated
using(member_id=(select auth.uid()) or (select private.is_staff()) or exists(select 1 from public.tasks t join public.campaigns c on c.id=t.campaign_id where t.id=task_id and (select private.has_org_role(c.organization_id,array['owner','manager','reviewer']))));
grant select,insert on public.submissions to authenticated;
create policy submissions_read_related on public.submissions for select to authenticated
using(member_id=(select auth.uid()) or (select private.is_staff()) or exists(select 1 from public.tasks t join public.campaigns c on c.id=t.campaign_id where t.id=task_id and (select private.has_org_role(c.organization_id,array['owner','manager','reviewer']))));
create policy submissions_insert_assigned on public.submissions for insert to authenticated
with check(member_id=(select auth.uid()) and exists(select 1 from public.assignments a where a.id=assignment_id and a.member_id=(select auth.uid()) and a.task_id=task_id and a.status='active'));

-- Reviews
grant select on public.review_decisions to authenticated;
create policy reviews_read_related on public.review_decisions for select to authenticated
using((select private.is_staff()) or exists(select 1 from public.submissions s where s.id=submission_id and s.member_id=(select auth.uid())) or exists(
 select 1 from public.submissions s join public.tasks t on t.id=s.task_id join public.campaigns c on c.id=t.campaign_id
 where s.id=submission_id and (select private.has_org_role(c.organization_id,array['owner','manager','reviewer']))
));

-- Ledgers are read-only to the owner; only service role can add entries.
grant select on public.xp_ledger,public.contribution_ledger,public.cash_ledger,public.crypto_reward_allocations to authenticated;
create policy xp_ledger_owner_or_staff on public.xp_ledger for select to authenticated using(member_id=(select auth.uid()) or (select private.is_staff()));
create policy contribution_ledger_owner_or_staff on public.contribution_ledger for select to authenticated using(member_id=(select auth.uid()) or (select private.is_staff()));
create policy cash_ledger_owner_finance on public.cash_ledger for select to authenticated using(member_id=(select auth.uid()) or (select private.is_staff(array['finance','super_admin'])));
create policy crypto_ledger_owner_finance on public.crypto_reward_allocations for select to authenticated using(member_id=(select auth.uid()) or (select private.is_staff(array['finance','super_admin'])));

grant select,insert on public.crypto_wallets to authenticated;
grant update(is_primary,revoked_at) on public.crypto_wallets to authenticated;
create policy crypto_wallets_owner_read on public.crypto_wallets for select to authenticated using(member_id=(select auth.uid()));
create policy crypto_wallets_owner_insert on public.crypto_wallets for insert to authenticated with check(member_id=(select auth.uid()) and is_verified=false);
create policy crypto_wallets_owner_update on public.crypto_wallets for update to authenticated
using(member_id=(select auth.uid())) with check(member_id=(select auth.uid()) and is_verified=false);

-- Learning / check-in progress
grant select on public.daily_activity to authenticated;
create policy daily_activity_owner_read on public.daily_activity for select to authenticated using(member_id=(select auth.uid()));
grant select on public.learning_courses to anon,authenticated;
create policy courses_read_published on public.learning_courses for select to anon,authenticated using(is_published=true or (select private.is_staff()));
grant select,insert,update on public.course_progress to authenticated;
create policy course_progress_owner_read on public.course_progress for select to authenticated using(member_id=(select auth.uid()));
create policy course_progress_owner_insert on public.course_progress for insert to authenticated with check(member_id=(select auth.uid()));
create policy course_progress_owner_update on public.course_progress for update to authenticated using(member_id=(select auth.uid())) with check(member_id=(select auth.uid()));

-- Contact form / private support
grant insert(name,email,subject,message,member_id) on public.contact_messages to anon,authenticated;
grant select,update(status) on public.contact_messages to authenticated;
create policy contact_public_insert on public.contact_messages for insert to anon,authenticated with check(
 char_length(trim(name)) between 1 and 100 and char_length(trim(email)) between 3 and 254
 and char_length(trim(subject)) between 2 and 160 and char_length(trim(message)) between 5 and 5000
);
create policy contact_staff_read on public.contact_messages for select to authenticated using((select private.is_staff(array['support','super_admin'])));
create policy contact_staff_update on public.contact_messages for update to authenticated using((select private.is_staff(array['support','super_admin']))) with check((select private.is_staff(array['support','super_admin'])));
grant select,insert on public.support_tickets to authenticated;
create policy support_ticket_read on public.support_tickets for select to authenticated using(member_id=(select auth.uid()) or (select private.is_staff(array['support','super_admin'])));
create policy support_ticket_create on public.support_tickets for insert to authenticated with check(member_id=(select auth.uid()));
grant select,insert on public.support_messages to authenticated;
create policy support_message_read on public.support_messages for select to authenticated using(
 exists(select 1 from public.support_tickets st where st.id=ticket_id and st.member_id=(select auth.uid())) or (select private.is_staff(array['support','super_admin']))
);
create policy support_message_create on public.support_messages for insert to authenticated with check(sender_id=(select auth.uid()) and staff_only=false and exists(select 1 from public.support_tickets st where st.id=ticket_id and st.member_id=(select auth.uid())));

-- Privacy controlled public snapshot
grant select on public.public_snapshots,public.public_contribution_snapshots to anon,authenticated;
create policy snapshot_read_owner_or_public on public.public_snapshots for select to authenticated using(member_id=(select auth.uid()) or (is_active and revoked_at is null and (expires_at is null or expires_at>now())));
create policy snapshot_read_public on public.public_snapshots for select to anon using(is_active and revoked_at is null and (expires_at is null or expires_at>now()));
grant select on public.referrals to authenticated;
create policy referrals_read_referrer on public.referrals for select to authenticated using(referrer_id=(select auth.uid()));
grant select on public.feature_flags to anon,authenticated;
create policy feature_flags_public_read on public.feature_flags for select to anon,authenticated using(true);
create policy funding_events_staff_read on public.campaign_funding_events for select to authenticated using((select private.is_staff(array['finance','super_admin'])));
create policy audit_superadmin_read on public.audit_events for select to authenticated using((select private.is_staff(array['super_admin'])));

revoke insert,update,delete on public.account_roles,public.organization_members,public.assignments,public.review_decisions,
public.xp_ledger,public.contribution_ledger,public.cash_ledger,public.crypto_reward_allocations,public.daily_activity,
public.campaign_funding_events,public.audit_events,public.referrals,public.feature_flags from anon,authenticated;
revoke update,delete on public.submissions,public.public_snapshots from anon,authenticated;
revoke delete on all tables in schema public from anon,authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('aarvix-submissions','aarvix-submissions',false,10485760,array['image/jpeg','image/png','image/webp','application/pdf','text/plain','application/zip'])
on conflict(id) do update set public=false,file_size_limit=10485760,allowed_mime_types=excluded.allowed_mime_types;
create policy aarvix_upload_own_submission_folder on storage.objects for insert to authenticated
with check(bucket_id='aarvix-submissions' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy aarvix_read_own_submission_folder on storage.objects for select to authenticated
using(bucket_id='aarvix-submissions' and ((storage.foldername(name))[1]=(select auth.uid())::text or (select private.is_staff())));
