# AARVIX — Make your useful work count

A mobile-first contribution and work-rewards platform prototype.

## Website
The site is prepared for GitHub Pages at:
https://gargvishnu611.github.io/Boost-income-/

## Project status
This first version is a frontend demo. Demo activity is stored in the current browser only. It does not create real member accounts, deliver email, publish public snapshots to a server, provide funded work, or issue cash/crypto rewards.

- XP and contribution credits are experimental demo values with no cash value.
- All sample tasks and lessons are clearly marked as examples.
- Cash tasks must only be published after a client or sponsor has funded the campaign.
- ARVX is not launched. Deposits, withdrawals, payouts, wallet connections and token transactions are disabled.

## Source package
The complete React/Vite source is stored in `aarvix-platform-source.zip`. The GitHub Actions workflow extracts the package, installs dependencies, builds the site and deploys the static output to GitHub Pages.

## If Pages is not enabled yet
Open **Settings → Pages** and choose **GitHub Actions** as the build and deployment source. Then check the Actions tab for the deployment result.

## Local setup
1. Download and extract `aarvix-platform-source.zip`.
2. Open the `aarvix-platform` folder.
3. Run `npm install`, then `npm run dev`.

## Supabase
The package includes a starter schema in `supabase/schema.sql`. It is not connected to this public demo deployment. Do not add service-role keys to frontend code or GitHub. Review and test database policies before any live member or payment feature.

## Safety before launch
Real authentication, server-side task review, email delivery, secure file uploads, public snapshot hosting, abuse controls, payment operations, legal terms, privacy processes and security testing must be completed before accepting members or money.
