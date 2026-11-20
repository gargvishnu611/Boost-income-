# AARVIX — contribution and work marketplace

**Product promise:** Make your useful work count.

AARVIX is a global contribution, learning and work marketplace. This repository contains the static web client and the versioned database migrations for the connected pilot.

## Current deployment

- GitHub repository: https://github.com/gargvishnu611/Boost-income-
- Expected Pages URL: https://gargvishnu611.github.io/Boost-income-/
- Supabase project: `qojxvskkcmtbzbplylgv` (Mumbai region, `ap-south-1`)
- Database migrations: `supabase/migrations/`

The Pages URL is not considered live until GitHub Pages is enabled in repository settings and the Actions deployment succeeds.

## Connected features

- Supabase email/password sign-up and sign-in, with email verification where enabled.
- Member profile stored in Postgres, not browser local storage.
- Live task feed (currently five non-cash practice tasks).
- Task applications and work submissions through server-side database functions.
- Server-side daily check-in and non-cash XP ledger.
- Member dashboard reading XP, contribution credits, submissions, payable records and crypto reward records from the database.
- Contact form writes to a private support inbox in Postgres.
- Business workspaces and draft campaigns/tasks.
- Role-gated submission review and support inbox surfaces.
- Row Level Security enabled on all 27 public tables.
- Separate XP, contribution, cash-payable and crypto-allocation ledgers.

## What is deliberately NOT live yet

This is a connected pilot foundation, **not an open paid earning platform**.

- All seeded tasks are examples for practice. They do not pay money or tokens.
- Paid campaigns, cash payouts, crypto rewards, Solana Devnet and Solana Mainnet flags are off.
- No payment provider, campaign funding webhook, payout provider, wallet signer or token contract is connected.
- No ARVX token has launched. Do not promise token price, allocation, exchange listing or conversion.
- The website never asks for a wallet recovery phrase or private key.
- Contact messages are stored in the support inbox, but outbound email alerts are not configured.
- Legal pages, policy acceptance, business verification, staff onboarding, fraud/appeal operations and full provider reconciliation must be completed before a public paid launch.

Never accept deposits from contributors to finance other contributors. AARVIX must not describe an internal database balance as escrow or as money already paid.

## First-time configuration

### 1. Enable GitHub Pages

Open **Settings → Pages** in this repository and select **GitHub Actions** as the build and deployment source. Then open the **Actions** tab and confirm that “Deploy AARVIX to GitHub Pages” completes. The repository workflow intentionally does not try to change repository Pages settings using the GitHub App.

### 2. Configure Supabase Auth redirects

In the Supabase project dashboard, open **Authentication → URL Configuration**:

- Set Site URL to `https://gargvishnu611.github.io/Boost-income-/`.
- Add `https://gargvishnu611.github.io/Boost-income-/` to the allowed redirect URLs (and the matching wildcard path if the dashboard requires it).

The front end requests an email confirmation redirect to the current website URL.

### 3. Configure outbound email

Set up a verified SMTP/email provider in Supabase Auth before inviting a large group. Configure sender identity, SPF/DKIM/DMARC as required by the provider, rate limits and support contact details. The contact inbox currently stores messages in the database; it does not send outbound mail.

### 4. App operator and reviewer access

Create the responsible adult operator account through the website. A trusted adult who can legally operate the business should own the legal entity, contracts, tax/banking and payment-provider onboarding. After verifying the account and identity, an authorised database owner can assign the initial role:

```sql
insert into public.account_roles (user_id, role, assigned_by)
select id, 'super_admin', id
from auth.users
where lower(email) = lower('ADULT_OPERATOR_EMAIL')
on conflict (user_id, role) do nothing;
```

Replace the placeholder with the adult operator's verified account email. Do not give staff roles to ordinary members. Reviewer and support roles should be granted separately using the same trusted administrative process.

### 5. Before paid tasks or crypto rewards

Do not switch feature flags on until all of these are completed:

1. Legal review of the exact operating model and participant eligibility for every country served.
2. Written business, privacy, task, acceptance, cancellation, appeal, refund and IP terms.
3. A regulated/approved payment partner that supports the intended merchant funding and worker payout flows, with successful sandbox reconciliation.
4. Signed and verified payment-provider webhooks, idempotency, refunds, dispute handling, reconciliation and accounting.
5. Independent security review, abuse controls, support staffing and operational incident runbooks.
6. For crypto, a separate review of VDA/FIU-IND obligations and the exact wallet, custody, transfer and token model; a security-reviewed payout service; testnet proof; and documented tax/accounting treatment.

The crypto tables are a ledger foundation only. There is no token transfer or wallet-signing code in the browser. Never put a Supabase service-role key, payment secret or blockchain signer in this repository or the web client.

## Security notes

- The browser includes only the Supabase project URL and publishable key. These are not service credentials; database grants and RLS are the actual access controls.
- All public-schema tables have RLS enabled. Do not disable RLS to make a client query work.
- Public RPCs that need to atomically create assignments or ledger events use restricted execution grants and validate the caller's authenticated identity.
- The database advisor flags these three intentionally callable `SECURITY DEFINER` RPCs because signed-in members can invoke them. They are limited to authenticated roles, explicitly check `auth.uid()`, and are used for constrained workflows. Re-review them whenever changed.
- Keep the service-role key server-side only.
- Store only public wallet addresses if a future wallet-linking workflow is added. Never store seed phrases or private keys.

See [the product blueprint](docs/PRODUCT-BLUEPRINT.md), [research and launch gates](docs/RESEARCH-AND-LAUNCH-GATES.md) and [operations runbook](docs/OPERATIONS-RUNBOOK.md).
