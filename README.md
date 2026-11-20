# AARVIX — Make your useful work count

AARVIX is a responsive, single-page contribution and work-rewards website prototype.

## Website
- GitHub repository: https://github.com/gargvishnu611/Boost-income-
- Expected GitHub Pages URL: https://gargvishnu611.github.io/Boost-income-/

## Included experiences
- Responsive landing page and navigation
- How it works and five contribution/earning paths
- Searchable demo task marketplace with task requirements and proof submission
- Learning modules and quiz with local demo XP
- Member dashboard preview and local contribution history
- Local admin review preview for demo submissions
- Local contact form and inbox preview
- Contribution snapshot preview
- Clear separation of XP, contribution credits and real-money work

## Important demo limits
This is a **frontend demo**, not a live earning platform. Demo submissions, messages, check-ins and balances are stored in the current browser's localStorage only. They are not synced between devices and are not reviewed or delivered to the AARVIX team.

- XP and contribution credits have no cash value.
- Sample tasks and learning modules are examples, not real job offers.
- No client/sponsor campaign is currently funded.
- There are no cash payouts, deposits, withdrawals, wallet connections or token transactions.
- ARVX is planned only; it has not launched.
- Member sign-in is a coming-soon modal. The dashboard is a local preview, not secure authentication.
- The admin screen is a local demo and is not protected by staff authentication. Do not use it to administer live users or money.
- Contact messages are saved only in this browser; email delivery is not connected.
- Contribution snapshot links are previews, not a real public hosting service.

## Deployment
The repository includes a GitHub Actions workflow that copies `index.html` to the Pages artifact and deploys it. If GitHub Pages is not enabled, open **Settings → Pages** and choose **GitHub Actions** as the deployment source. Then check **Actions** for the workflow result.

## Before launch
Build and test real member authentication, server-side task submissions and verification, an immutable points ledger, spam protection, file safety, real contact inbox/email delivery, public snapshot hosting/revocation, access-controlled admin tools, privacy controls and security monitoring. Only advertise paid tasks after campaign funds have cleared and written payment terms are approved.

Never expose Supabase service-role keys in browser code or GitHub. A Supabase schema and backend integration must be reviewed and tested before storing real member data. Obtain appropriate adult, legal, tax and regulatory guidance before contracts, payment processing or any token feature.
