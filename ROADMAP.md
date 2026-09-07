# Nexawyn — Roadmap

Living document. Completed items stay checked — history matters.

---

## Phase 1 — The Engine ✅ Complete (September 6, 2026)

- [x] Platform named — Nexawyn
- [x] Domain registered — nexawyn.com (Hostinger)
- [x] Supabase project created — Nexawyn, East US (Ohio)
- [x] Core schema built and running — 15 tables
- [x] Chart of accounts seeded
- [x] RLS enabled
- [x] Schema saved — schema/phase1-core.sql
- [x] Working document created (NEXAWYN.md)
- [x] CLAUDE.md project instructions written
- [x] React + Vite project initialized
- [x] Supabase JS client installed and connection confirmed

---

## Phase 2 — Internal Dashboard (Current)

### Pre-build setup (standards compliance)
- [x] dev-standards adopted — web-app-framework.md is the reference
- [x] CLAUDE.md created
- [x] README.md written
- [x] ROADMAP.md created
- [x] Credentials moved to env vars (supabase.js)
- [ ] Add `job_photos` table to Supabase
- [ ] Add `operator_settings` table to Supabase
- [ ] Create folder structure: src/constants/, src/context/, src/hooks/, src/styles/
- [ ] src/constants/index.js — timing defaults, limits, format strings
- [ ] src/constants/jobStatuses.js — all 11 job status strings
- [ ] src/lib/logger.js — unified logging layer
- [ ] src/hooks/useSettings.js — operator settings hook
- [ ] src/hooks/useFeatureFlags.js — feature flag hook
- [ ] src/context/SettingsContext.jsx — wired at app root
- [ ] src/components/ErrorBoundary.jsx — wired at app root

### Feature build
- [ ] Job list view — organized by status
- [ ] Customer profile view
- [ ] Quote builder with template selection
- [ ] Material search (catalog + manual)
- [ ] Quote total calculation with markup
- [ ] SMS send via Twilio
- [ ] Job status update on user action
- [ ] Basic photo capture and attach to job (assessment + completion)
- [ ] Basic auth (Supabase Auth)

---

## Phase 3 — Customer Portal

- [ ] Quote view page (SMS link destination)
- [ ] Assessment photos shown alongside quote line items
- [ ] Online quote approval
- [ ] Invoice view page with completion photos
- [ ] Stripe payment integration
- [ ] Parts status tracking page

---

## Phase 4 — Website Integration

- [ ] Booking form on skilledhandymanservices.com
- [ ] Form posts to Supabase via API
- [ ] New job created automatically in dashboard

---

## Phase 5 — Intelligence Layer

- [ ] HD catalog search integration (RapidAPI)
- [ ] HD Pro Xtra purchase sync (Puppeteer automation)
- [ ] Sync Now button + scheduled auto-sync
- [ ] Stripe webhook → auto accounting entries
- [ ] Stripe Financial Connections bank link
- [ ] Parts tracking API (UPS/FedEx/USPS)
- [ ] Automated parts SMS notifications
- [ ] Photo export — PDF report with timestamps (insurance jobs)
- [ ] Migrate photo storage from Supabase Storage → Cloudflare R2
- [ ] Reporting dashboard
- [ ] Template self-calibration from job history
- [ ] Business cockpit with alerts

---

## Phase 6 — SaaS Product (Future)

- [ ] Nexawyn brand marketing site
- [ ] Multi-tenancy (each operator isolated)
- [ ] Self-serve onboarding flow
- [ ] Stripe subscription billing
- [ ] Operator-facing reporting
- [ ] Franchise dashboard layer

---

## Known issues / tech debt

- `operator_settings` table not yet created — required before any Phase 2 feature build
- `job_photos` table not yet created — required before Phase 2 photo feature
- RLS disabled on all tables for dev build — must re-enable with proper auth-based policies before any real data or SaaS launch (Phase 2 prerequisite)

## Ideas to revisit

- Template intelligence: after enough jobs, templates self-calibrate from actual labor/material data
- Business cockpit alerts: surface problems automatically rather than requiring operator to hunt
- Data network effect: aggregate anonymized data across operators at scale becomes a product in itself
- Franchise dashboard: royalty calculation from verified revenue, network benchmarking, brand compliance