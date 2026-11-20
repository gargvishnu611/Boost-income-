# AARVIX Product Blueprint
**Product promise:** Make your useful work count.  
**Product model:** A global work marketplace plus a learning and verified-contribution ecosystem.

## 1. Product roles

### Member / contributor
- Discover eligible, currently funded work.
- See the client, scope, deliverables, eligibility, time estimate, exact reward, currency, review deadline, revisions and payout method before applying.
- Apply, accept a milestone, submit proof/files, view review history, request clarification, revise once where permitted, and appeal a rejection.
- Maintain a skills profile, portfolio, course progress, badges and verified contribution record.
- Opt in to a public shareable snapshot and revoke it at any time.

### Client / business
- Create a business workspace and complete verification.
- Create a campaign with a defined deliverable, acceptance checklist, skill requirements, country eligibility, deadline, exact budget and total fees.
- Fund a campaign through an approved marketplace/payment provider before a paid task can become claimable.
- Review submissions, approve, request changes with reasons, reject with evidence, and respond to disputes.
- View campaign spend and invoices/receipts supplied by the provider.

### AARVIX operations / reviewer
- Separate reviewer, support, finance and super-admin permissions.
- Verify business profiles and campaign scope/funding.
- Moderate task content, submissions, reports, appeals and public snapshots.
- Issue decisions with reason codes and evidence.
- Review payment-provider events and reconcile paid work.
- Maintain tamper-evident audit records. No staff member can silently edit a member's ledger.

## 2. Earning architecture

Keep three ledgers separate:
1. **XP ledger:** non-cash learning and platform progress.
2. **Contribution ledger:** approved work, skills, quality and community contributions. It is a reputation record, not a cash substitute.
3. **Fiat payable ledger:** only accepted deliverables tied to a funded campaign and a provider-confirmed payable amount.

No points-to-cash formula, guaranteed conversion, guaranteed task volume or token-price promise.

### Earning categories
- Client projects: writing, design, translation, research, video editing, coding, software testing, accessibility reviews and data organization.
- Sponsored campaigns: clearly scoped surveys, product feedback and research participation.
- Bounties: specific bug reports, feature work, documentation, translations or design deliverables.
- Competitions: published judging criteria, deadlines, prize amount and winner selection.
- Learning and community: courses, quizzes, peer support and open contributions; normally XP or contribution credit only.
- Referral: one level only; only for a verified, meaningful conversion, from a pre-approved marketing budget. Never reward recruitment alone.

### Campaign funding and payment safety
- A paid task is not published as claimable until a signed payment-provider webhook confirms the required campaign funding.
- AARVIX stores a provider reference and accounting records; it does not pretend its database balance is money in escrow.
- Use an authorised marketplace/payment partner that supports the actual fund flow, merchant onboarding, refunds, disputes and payouts. Do not operate an in-house escrow or payment-aggregator system without legal classification and required authorisation.
- Payment is released by the approved provider or directly by the client under the approved operating model.
- Platform fees, taxes, currency conversion and payout fees are disclosed before work is accepted.
- Never use one member's or new member's deposits to pay another member.

## 3. Task lifecycle

draft → moderation → awaiting funding → funded/open → in progress → submitted → quality review → client review → changes requested / accepted / rejected → payable → payout processing → paid

Additional terminal states: cancelled, expired, disputed, refunded.

Every paid task must publish:
- Legal client identity / verified business status where appropriate.
- Task scope and excluded work.
- Objective acceptance checklist and required proof.
- Exact compensation and currency.
- Expected effort range and deadline.
- Eligibility, country restrictions and skill requirements.
- Funding status and funding provider reference (never sensitive credentials).
- Review deadline, allowed revision count and appeal window.
- IP ownership / license terms and data handling instructions.
- Cancellation, refund and dispute process.

Suggested default policy to review with counsel and pilot users:
- One clearly described revision request for fixable defects.
- Review target published per campaign; operational default 5 business days.
- Rejection must include an evidence-based reason code.
- 7 calendar days to appeal a rejection.
- High-value or safety-sensitive work requires a second reviewer.
These are proposed AARVIX product rules, not statutory requirements.

## 4. Learning and reputation

- Learning paths: Digital basics, writing, design, coding, AI/data quality, research methods, privacy and professional communication.
- Each module has an author, reviewer, version, learning objective, content source/licence, quiz and last-reviewed date.
- XP is earned for completed modules and quizzes, with rate limits and server validation.
- Contribution quality is assessed against task-specific criteria; do not use one opaque score to determine cash pay.
- Public badges require a defined achievement and audit trail.

## 5. Public contribution snapshots

- Private by default; member must explicitly opt in.
- Member chooses which approved projects, skills, badges and totals to display.
- Never expose email, legal name (unless user opts in), payment details, private submissions, client-confidential work, reviewer notes, private messages, authentication IDs or wallet material.
- Use an unguessable public token, expiry/revocation, rate limits and a preview before publishing.
- Client-confidential contributions are never shareable without explicit client permission.

## 6. Support and disputes

- Real contact inbox stored in the database, then delivered to staff notification email once a provider is configured.
- Member and client messages are private and scoped to the relevant task/campaign.
- Include report, appeal, refund and dispute forms with status tracking.
- Every decision has a timestamp, actor, reason and evidence reference.
- No automated rejection or payout freeze without a review path.

## 7. Sitemap and main app surfaces

### Public
Home, How It Works, Earn, Browse Work, Learning, For Businesses, Community, About, Trust & Safety, Fees, FAQ, Contact, Privacy, Terms, Cookies and Accessibility.

### Member
Overview, Find Work, Applications, My Work, Submissions, Earnings & Payouts, XP & Contributions, Learning, Skills & Portfolio, Referrals, Messages, Notifications, Public Profile, Security and Privacy.

### Client
Business verification, Workspace, Create Campaign, Funding Status, Applicants, Workroom, Submissions & Review, Budget & Invoices, Disputes, Team and Settings.

### Operations
User/business verification, task moderation, campaign funding checks, submission review, appeals, fraud queue, contact inbox, snapshot moderation, provider reconciliation, payouts and audit logs.

## 8. Core database domains

- Identity: profiles, account_roles, organisations, organisation_members, verification_cases.
- Marketplace: campaigns, tasks, milestones, eligibility_rules, applications, assignments, submissions, submission_files, review_decisions, revision_requests, disputes.
- Funds: provider_accounts, funding_events, campaign_budgets, provider_transactions, payable_ledger, payout_requests, payout_events, refunds, fee_rules, invoices.
- Reputation: xp_ledger, contribution_ledger, skills, member_skills, courses, lessons, quizzes, quiz_attempts, badges, member_badges.
- Community: referrals, referral_attributions, messages, support_tickets, notifications, reports.
- Privacy: public_snapshots, snapshot_fields, consent_records, data_requests, retention_jobs.
- Governance: audit_events, staff_roles, moderation_actions, risk_events, feature_flags.

## 9. Security model

- Supabase Auth for verified member/client sessions.
- Row Level Security on every exposed table, with least-privilege grants and explicit allow/deny policies.
- Private server-side schema for payment events, provider secrets, staff-only notes and ledger mutation functions.
- Edge Functions or trusted server code for every privileged action.
- Browser never writes cash payable entries or admin decisions directly.
- Append-only monetary and point ledgers; corrections are reversing entries, not silent edits.
- Signed webhook verification, idempotency keys and reconciliation.
- Input validation, upload allowlists, virus scanning, size/type limits, rate limits, CAPTCHA and anti-automation safeguards.
- Auditable access, backups, monitoring, incident response and data deletion/retention workflow.
- No service-role key in browser bundles or GitHub.

## 10. Visual and interaction system

- Identity: charcoal/navy, vivid warm yellow, off-white and muted steel.
- Typography: geometric display headings, highly readable sans-serif body.
- Motif: hexagon/diamond contribution mark, orbital rings, measured grid, thin technical lines.
- 3D: one purposeful hero scene with a custom geometric AARVIX object, a few floating task primitives and restrained lighting. Use 3D sparingly in app dashboards; data and readability take priority.
- Charts: actual account/campaign data only; sample data labelled as illustrative.
- Responsive: mobile-first, collapsible nav, touch-sized controls, keyboard navigation, focus states, reduced-motion mode and fallback when WebGL is unavailable.
- Performance goals: Core Web Vitals good thresholds—LCP ≤2.5s, INP ≤200ms, CLS ≤0.1. Lazy-load 3D, cap pixel ratio, reduce particles on mobile and stop animation when tab/scene is not visible.

## 11. Launch sequence

### Stage A — Product foundation
Brand, sitemap, responsive 3D public site, user journeys, terms/privacy drafts for lawyer review, task policy, operations model, database schema and design system.

### Stage B — Real platform backend
Dedicated Supabase project, email verification, role-based access, member/client dashboards, tasks, submissions, reviewer workflow, XP/contribution ledgers, public snapshots, support inbox, audit and RLS tests.

### Stage C — Commercial readiness
Adult-owned legal entity and contracts, client onboarding, payment-provider approval, KYC, tax handling, country/payment availability matrix, funding webhooks, refund/dispute design, verified campaigns and actual client funds.

### Stage D — Controlled launch
Invite-only pilot with a small number of verified clients and paid tasks, payment reconciliation, quality and appeal monitoring, security test, performance test and only then public expansion.

### Stage E — ARVX research and launch assessment
Independent legal/tax/regulatory assessment, token utility proven by product usage, supply/distribution governance, smart-contract audit, AML perimeter assessment and market-risk disclosure. No token sale or public trading promise in the initial work marketplace.

## 12. What "launch-ready" means

The site is not launch-ready merely because its screens work. Launch gate requires:
- Production auth, verified support inbox and tested RLS.
- No fake tasks or fabricated balances.
- Client-funded tasks that can actually be fulfilled.
- Contract, terms, privacy notice, grievance contact, refunds and dispute policy reviewed.
- A payment provider and a lawful settlement flow approved for each launch country.
- Real payout tests with reconciled provider events.
- Security, access, privacy, abuse and recovery tests.
- Named adult/legal operator responsible for business and payment contracts.
