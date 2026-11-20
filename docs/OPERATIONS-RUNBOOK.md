# AARVIX Operations Runbook

This runbook describes the current connected pilot. It does not authorise paid work, custody, escrow, token issuance or crypto transfers.

## Current operating state

| Area | State |
|---|---|
| Supabase project | Active, Mumbai |
| Authentication | Email/password connected; redirect allowlist still needs dashboard configuration |
| Practice tasks | Five public non-cash examples |
| Member submissions | Database-backed |
| XP | Server-side check-in; non-cash |
| Contribution credits | Server-side ledger; non-cash |
| Business workspaces | Draft creation |
| Campaigns and tasks | Draft creation only |
| Contact messages | Database inbox; no outbound notification |
| Staff review queue | Role-gated; no staff user assigned yet |
| Cash campaigns and payouts | Disabled; no payment partner configured |
| Crypto rewards | Disabled; no signing/transfer service configured |
| ARVX asset | Not launched |

## Daily checks for an authorised operator

1. Review Supabase Auth signup errors, email delivery and abuse/rate-limit signals.
2. Review contact messages and support tickets.
3. Review newly created business workspaces and verification requests.
4. Check task drafts for scope, acceptance criteria, permitted data use and country restrictions.
5. Keep campaign status at draft until legal and funding checks are complete.
6. Review security and performance advisors after database or policy changes.
7. Check GitHub Actions to confirm Pages remains deployed successfully.

## Member and reviewer flow

1. A member signs up using an email and password and verifies the email address.
2. A new profile and the base member role are created by the database auth trigger.
3. The member browses open practice tasks, applies and submits work.
4. A designated reviewer checks the evidence and selects accept, request changes or reject with a reason.
5. Accepted practice work may receive non-cash XP and contribution credits. Those ledgers are not money and do not convert to money.
6. Do not accept paid or crypto items until the payment and token settlement paths are implemented and independently tested.

## Initial super-admin assignment

Only an adult operator with authority over the business and database should do this. First create and verify the operator's account on the website, then run the following in the Supabase SQL Editor after replacing the email:

```sql
insert into public.account_roles (user_id, role, assigned_by)
select id, 'super_admin', id
from auth.users
where lower(email) = lower('ADULT_OPERATOR_EMAIL')
on conflict (user_id, role) do nothing;
```

Use reviewer, support and finance roles for their specific job functions; do not give every staff member super-admin access. Do not allow members to assign roles to themselves.

## Paid campaign launch gates

Before any cash reward is advertised:

- Have counsel review the business model, contracts, participant age/country eligibility and Indian payment-services classification.
- Complete the business entity, tax/accounting, bank and provider onboarding.
- Select a payment partner with the right marketplace/merchant and payout model.
- Implement signed webhook verification, idempotency, duplicate-event handling, settlement reconciliation, refunds, disputes and payout status callbacks.
- Test the complete journey using provider sandbox transactions and a small, capped pilot.
- Publish exact reward, currency, acceptance terms, fees, deadlines, review target, appeal route and payout conditions before members apply.
- Turn `paid_campaigns_enabled` on only after the operator and counsel explicitly approve the complete flow.

A database field marked funded is not proof that funds are held in escrow. Store provider references and only treat signed provider events as evidence of funding.

## Crypto reward launch gates

The database contains wallet-address and reward-allocation records, but no code that signs or broadcasts token transfers. Before enabling any crypto reward:

- Have qualified counsel assess VDA activity, FIU-IND reporting/registration perimeter, tax, sanctions, travel-rule and country-specific requirements.
- Decide whether AARVIX is paying from a non-custodial wallet, a regulated payout provider or a different approved model. Do not build an unreviewed custodial wallet.
- Establish a controlled treasury and funding source separate from user funds.
- Implement a wallet-address ownership verification method and clear network/asset/fee warnings.
- Implement server-side transaction signing using a properly isolated provider or HSM-backed key service. Never put a private key or seed phrase in the browser, repo or Postgres profile.
- Add idempotent payout jobs, transaction-signature verification, failure/retry handling and reconciliation.
- Complete Devnet tests, security review and approved small-value pilot before considering mainnet.
- Keep `crypto_rewards_enabled`, `solana_devnet_enabled` and `solana_mainnet_enabled` off until the corresponding stage is approved.

No one should be asked to send AARVIX money or crypto to unlock tasks, withdraw earnings, verify an account or increase a reward.

## Incident response

- Pause publishing of tasks and campaigns if funding, eligibility, data access or review integrity is uncertain.
- Preserve database audit logs, provider event IDs and relevant timestamps.
- Revoke compromised sessions and rotate exposed credentials immediately.
- Do not delete or silently edit ledger records; use reversal/adjustment entries and record the reason.
- Notify affected users through an approved support channel and follow the documented privacy and breach process.
