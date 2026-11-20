
grant select on public.campaigns to anon;
drop policy if exists campaigns_select_participants on public.campaigns;
create policy campaigns_select_participants on public.campaigns for select to anon,authenticated
using(
  (select private.has_org_role(organization_id))
  or (status='open' and funding_state='funded' and funded_minor>=budget_minor)
  or (select private.is_staff())
);
