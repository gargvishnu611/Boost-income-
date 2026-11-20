# Supabase project

Project: `qojxvskkcmtbzbplylgv`  
Region: `ap-south-1` (Mumbai)

The canonical versioned database migrations live in `migrations/`. They were applied to the connected Supabase project and are also committed here:

- `20261120055548_aarvix_marketplace_foundation.sql`
- `20261120055629_tighten_workflow_grants_and_indexes.sql`
- `20261120134214_aarvix_member_workflows_and_demo_content.sql`
- `20261120134628_contact_message_identity_integrity.sql`
- `20261120134902_review_and_revisions_workflow.sql`
- `20261120135649_server_verified_learning_quizzes.sql`

## Security design

- All 27 tables in `public` have Row Level Security enabled.
- User profile, application, submission, ledger and support access is owner-scoped or role-scoped.
- The browser uses a publishable API key only. Never add a `service_role` secret to the static website.
- XP, contribution credits, cash payables and crypto reward allocations use separate ledgers.
- Database RPCs that create assignments, submit work, award daily XP or review work enforce the signed-in caller and restricted roles.
- Paid task and crypto reward feature flags default to disabled.
- The seeded work items are practice tasks and must never be described as paid jobs.

When changing policies or `SECURITY DEFINER` functions, review the code, run Supabase security/performance advisors, test both allowed and denied access, and commit a new migration. Never disable RLS to fix a frontend access error.
