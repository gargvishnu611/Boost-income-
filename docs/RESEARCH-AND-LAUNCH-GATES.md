# AARVIX Research and Launch Notes
Research checked on 20 November 2026. This is product research, not legal, tax or financial advice.

## Marketplace patterns used

### Upwork — funded milestones
Upwork's fixed-price flow requires the client to fund a milestone/project before work begins; the worker submits work for review, and the client can approve or request changes. AARVIX should adopt the principle of visible funding before paid work starts and a traceable review/dispute process.
- https://support.upwork.com/hc/en-us/articles/211063718-How-payments-for-milestones-and-fixed-price-contracts-work
- https://support.upwork.com/hc/en-us/articles/211063748-How-Fixed-Price-Payment-Protection-works-for-freelancers-on-Upwork

### Prolific — task transparency and participant trust
Prolific shows participants the reward, estimated time and task requirements before they opt in; it uses waitlisting/account verification and describes privacy protections. AARVIX should show eligibility, expected time, reward, data use and opt-in choice before a member starts.
- https://www.prolific.com/participants-how-it-works
- https://www.prolific.com/participants

### Toloka — quality, review and appeal
Toloka's quality-control documentation uses training, exams, control tasks and multi-layer checks. Its worker documentation describes review history, rejection reasons and a challenge/appeal path. AARVIX should explain the acceptance criteria and review/appeal steps before work starts.
- https://github.com/Toloka/docs/blob/main/en/guide/concepts/quality-control-overview.md
- https://github.com/Toloka/docs-tolokers/blob/main/en/common/priemka.md

### Gitcoin — clear bounties
Gitcoin's published bounty mechanism emphasises a defined task, deliverables, scope, reward, contributor execution, review and payment release. This is the model for AARVIX's bug bounties, documentation, translations and project tasks.
- https://gitcoin.co/mechanisms/bounties

### Clickworker — payable versus completed
Clickworker separates completed earnings from the payable amount and describes quality review delays and minimum payout requirements. AARVIX should not call work "paid" simply because it was submitted or shown as an estimate; only a reconciled payment event is paid.
- https://support-workplace.clickworker.com/support/solutions/articles/80000672346-what-payment-options-do-i-have-
- https://support-workplace.clickworker.com/support/solutions/articles/80000672354-what-does-account-balance-payable-mean

## Design and performance references
- Three.js WebGL renderer documentation: https://threejs.org/docs/pages/WebGLRenderer
- Three.js guidance for optimizing lots of objects: https://threejs.org/manual/pages/optimize-lots-of-objects.html
- Google Core Web Vitals: https://developers.google.com/search/docs/appearance/core-web-vitals
- MDN reduced-motion accessibility: https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Media_queries/Using_for_accessibility

Design decision: use an original 3D geometric hero and data-informed app visuals, but lazy-load and scale down 3D on mobile. Do not sacrifice readable interfaces, battery life or load performance for animation.

## India-facing legal and operational launch gates

### Payment collection and payouts
The RBI Master Direction on Regulation of Payment Aggregators (2025; page updated 11 November 2026) covers authorisation, merchant due diligence, dispute management, fraud/security, KYC and escrow. It states that a non-bank entity operating as a payment aggregator must seek authorisation, be incorporated in India under the Companies Act and satisfy applicable net-worth conditions; non-bank PAs must maintain relevant escrow accounts. Whether AARVIX's exact fund flow makes it a PA must be determined by qualified counsel and the RBI-regulated payment partner. The safe architecture is to use an approved marketplace/payment provider and not have AARVIX itself hold customer money as informal escrow.
- https://www.rbi.org.in/Scripts/BS_ViewMasDirections.aspx?id=12896
- https://www.rbi.org.in/scripts/FS_PressRelease.aspx?prid=61218

### Virtual digital assets
FIU-IND's AML/CFT/CPF Guidelines updated 8 January 2026 state that a VDA service provider carrying on the notified activities on behalf of another person in the course of business must register with FIU-IND as a reporting entity. The listed activities include VDA/fiat exchange, VDA/VDA exchange, VDA transfer, safekeeping/administration and certain financial services connected with an issuer's offer or sale. The token feature must remain disabled until its exact activity perimeter and obligations are reviewed.
- https://fiuindia.gov.in/pdfs/downloads/VDA08012026.pdf

### Personal data and children
The Digital Personal Data Protection Rules, 2025 were notified with staggered commencement dates: Rules 1, 2 and 17–21 commence on publication; Rule 4 after one year; Rules 3, 5–16, 22 and 23 after eighteen months. The child-consent rule 10 specifies verifiable parent consent for processing a child's personal data. AARVIX should launch paid marketplace participation as 18+ initially, collect minimal personal data and build consent/privacy processes before broader age eligibility. This is a conservative product setting, not a claim that every rule is already in force on the same date.
- https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf

### Contracting and operator responsibility
Section 11 of the Indian Contract Act, 1872 says contract competence depends on attaining the age of majority, sound mind and not being disqualified by law. Since the founder is under 18, an adult guardian/responsible adult and qualified professional should handle the legal entity, client contracts, banking/payment-provider onboarding and binding business commitments.
- https://www.indiacode.nic.in/handle/123456789/12845
- https://thc.nic.in/Central%20Governmental%20Acts/Indian%20Contract%20Act%2C%201872.pdf

## Supabase security
Supabase's current RLS guide says every table in an exposed schema should have RLS enabled, and table grants must be limited as well as policies. It recommends testing allow and deny behavior. Service-role keys bypass RLS and must stay server-side.
- https://supabase.com/docs/guides/database/postgres/row-level-security

## Non-negotiable AARVIX rules
- No un-funded paid tasks.
- No fake earnings, fabricated balances, false testimonials or guaranteed token conversion.
- No reward for recruitment alone or multi-level referral schemes.
- No user-editable cash balances.
- No public personal data by default.
- No AARVIX-run escrow, custody, token swap or trading until regulatory/legal classification and provider approvals.
