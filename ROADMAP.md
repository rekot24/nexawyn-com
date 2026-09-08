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

## Phase 2 — Foundation & Security ✅ Schema Complete | App Build In Progress

### Schema work ✅ Complete
- [x] Add `job_photos` table to Supabase
- [x] Add `business_settings` table to Supabase (renamed from operator_settings)
- [x] Add `app_logs` table to Supabase
- [x] Add `users` table to Supabase
- [x] Add `schedule_events` table to Supabase
- [x] Phase 2 schema saved — schema/phase2-additions.sql
- [x] Add `businesses` + `business_members` tables — tenant entity
- [x] Add `business_id` to all operational tables — data isolation
- [x] Add `quotes` + `quote_line_items` — first-class immutable entity
- [x] Add `invoice_line_items` — immutable snapshot at issuance
- [x] Add job status CHECK constraint at database level
- [x] Add `event_type` and `event_status` to `schedule_events`
- [x] Add `flagged_note` to jobs, `pinned_note` to customers
- [x] Add `scope_addition_pending` flag to jobs
- [x] Rename `operator_settings` → `business_settings`
- [x] Drop orphaned `user_roles` table (superseded by `business_members`)
- [x] Phase 3 schema saved — schema/phase3-additions.sql
- [x] Phase 3b cleanup saved — schema/phase3b-cleanup.sql
- [x] Seed Skilled Handyman Services as first business
- [x] Link Joshua as owner via `business_members`

### Standards compliance
- [x] dev-standards adopted — web-app-framework.md is the reference
- [x] CLAUDE.md created
- [x] README.md written
- [x] ROADMAP.md created
- [x] Credentials moved to env vars (supabase.js)
- [ ] Create folder structure: src/constants/, src/context/, src/hooks/, src/styles/
- [ ] src/constants/index.js — timing defaults, limits, format strings
- [ ] src/constants/jobStatuses.js — all 13 job status strings (includes job_paused, quote_declined)
- [ ] src/lib/logger.js — unified logging layer
- [ ] src/hooks/useSettings.js — settings hook (fetches by active business_id, never first row)
- [ ] src/hooks/useFeatureFlags.js — feature flag hook
- [ ] src/hooks/useRole.js — role/permissions hook (centralized; enforced server-side too)
- [ ] src/context/SettingsContext.jsx — wired at app root
- [ ] src/context/AuthContext.jsx — active user + active business context
- [ ] src/components/ErrorBoundary.jsx — wired at app root

### Auth & security (complete before any production UI)
- [ ] Implement Supabase Auth
- [ ] Link `users.auth_id` to Supabase Auth UUID
- [ ] Add auth session provider at app root
- [ ] Add active-user context
- [ ] Add active-business context — settings and data scoped to business_id
- [ ] Remove first-row assumptions from settings lookup
- [ ] Re-enable RLS on all tables
- [ ] Create business-scoped RLS policies (users see only their business data)
- [ ] Create role-aware RLS policies where needed
- [ ] Test owner, admin, technician permission levels
- [ ] Confirm one business cannot query another business's data
- [ ] Confirm customer-facing public links use narrowly scoped access

### Status transition integrity
- [ ] Create single app service responsible for all status transitions
- [ ] Every status change writes to `job_status_history` — no exceptions
- [ ] Define and enforce allowed status transitions
- [ ] Prevent components from directly mutating job status — all changes through service

### Feature flags vs permissions (keep these distinct)
- [ ] Feature flag = capability is available/enabled for this business
- [ ] Plan entitlement = business has purchased/unlocked capability
- [ ] Permission = this user's role may perform this action
- [ ] Never use feature flags as an authorization mechanism

### Core app build (after auth is wired)
- [ ] Job list view — organized by status, contextual alerts on cards
- [ ] Customer profile view — with pinned notes visible
- [ ] Today's schedule view — jobs in order with flagged alerts inline
- [ ] Job screen — full view scoped by role
- [ ] Quote builder with template selection
- [ ] Material search (catalog + manual)
- [ ] Quote total calculation with markup
- [ ] Quote sent → immutable quote_line_items snapshot written
- [ ] Job status updates — through single service, history always written
- [ ] Basic photo capture and attach to job (assessment + completion)
- [ ] On My Way — SMS with ETA + auto-launch maps
- [ ] Pause Job flow — reason required, routes by type
- [ ] Scope change flow — same work order vs new job decision
- [ ] Close-out checklist — gates Mark Complete
- [ ] Google Review QR code on close-out
- [ ] Payment close-out — Stripe / check / send invoice paths
- [ ] SMS send via Twilio
- [ ] Materials buy list with HD stock/aisle data (when HD integration active)

---

## Phase 3 — Customer Portal

- [ ] Quote view page (SMS link destination)
- [ ] Assessment photos shown alongside quote line items
- [ ] Online quote approval — records approved_at and approved_by
- [ ] Quote decline flow — records declined_at and reason
- [ ] Invoice view page with completion photos
- [ ] Stripe payment integration
- [ ] Parts status tracking page
- [ ] Customer-facing links use narrowly scoped RLS — no general anon access

---

## Phase 4 — Website Integration

- [ ] Booking form on skilledhandymanservices.com
- [ ] Form posts to Supabase via API
- [ ] New job created automatically in dashboard

---

## Phase 5 — Intelligence & Automation Layer

### Workflow automation
- [ ] Automatic quote follow-up SMS at 24hr
- [ ] Stale quote alert to operator at 48hr
- [ ] Contextual alerts wired — messages surface on job cards
- [ ] Communications Center — full inbox view across all jobs
- [ ] Parts tracking API (UPS/FedEx/USPS)
- [ ] Automated parts SMS notifications to customer
- [ ] Review request SMS auto-fires after invoice_paid

### Home Depot integration
- [ ] HD catalog search integration (RapidAPI) — live price + stock + aisle
- [ ] Materials buy list with HD aisle/stock data
- [ ] Multi-job combined buy list (grouped by aisle)
- [ ] HD Pro Xtra purchase sync (Puppeteer automation)
- [ ] Sync Now button + scheduled auto-sync

### Accounting automation
- [ ] Stripe webhook → auto accounting entries on payment
- [ ] HD sync → auto expense entries on import
- [ ] Stripe Financial Connections bank link
- [ ] Job profitability view — revenue, materials, labor, margin per job

### Reporting & intelligence
- [ ] Reporting dashboard — revenue, margin, jobs by period
- [ ] Estimated vs actual labor analysis
- [ ] Estimated vs actual material analysis
- [ ] Template self-calibration from job history
- [ ] Business cockpit with automatic exception alerts
- [ ] Intelligent close-out checklist — job-type specific steps refined over time

### Photo & documentation
- [ ] Photo export — PDF report with timestamps (insurance jobs)
- [ ] Migrate photo storage from Supabase Storage → Cloudflare R2
- [ ] Private photos served via signed URLs (not public bucket)

---

## Phase 6 — SaaS Product (Future)

- [ ] Nexawyn brand marketing site
- [ ] Self-serve onboarding flow — new business signup
- [ ] Stripe subscription billing — plan tiers enforced via plan_tier field
- [ ] Multi-business isolation confirmed via RLS (structure already in place)
- [ ] Operator-facing reporting
- [ ] Franchise dashboard layer — aggregate across franchisees
- [ ] Network benchmarking (anonymized)

---

## Deferred / Future Considerations

These are real and valid — not forgotten, just not blocking MVP.

- **Photo storage abstraction** — add `storage_provider` + `storage_key` fields alongside `storage_url` for cleaner provider independence. Low priority until R2 migration.
- **Adapter pattern for integrations** — isolate HD, Twilio, Stripe, maps, and package tracking behind provider interfaces so swapping vendors doesn't touch core logic. Implement when a second provider becomes relevant.
- **Full accounting depth** — reconciliation, equity accounts, owner draws, chargebacks, sales tax, cash vs accrual, year-end controls. Core job profitability comes first.
- **`operator_settings` rename in app code** — all references in React app need updating to `business_settings` when settings hook is built.

---

## Nexawyn 0.1 — Definition of Done

The first milestone is one complete working loop on real Skilled Handyman jobs:

```
Inquiry → Customer + Job → Assessment → Quote → Customer Approval
→ Schedule → Work + Photos + Materials → Invoice → Stripe Payment → Paid / Closed
```

**0.1 does NOT require:**
- Home Depot automation
- Full accounting replacement
- SaaS onboarding
- Franchise reporting
- Template intelligence
- Advanced reporting

**Validate 0.1 by answering yes to all:**
- Can Joshua create a customer and job without another system?
- Can he schedule and manage work through Nexawyn?
- Can he create and send an accurate quote?
- Can the customer securely approve it?
- Can Josh document the job from his phone?
- Can he see what materials are needed?
- Can he complete the job and invoice it?
- Can the customer pay it?
- Does Nexawyn preserve the full historical record?
- Is the workflow secure and business-scoped?
- Does Nexawyn reliably surface what should happen next?

**After 0.1:** Run 5 real jobs. Record every moment you leave the app to do something elsewhere. Record every screen that takes too many taps. Re-prioritize from real usage before expanding.

---

## Known Issues / Tech Debt

- RLS disabled on all tables for dev build — must re-enable with auth-based policies before real data
- `business_settings.operator_id` FK to users exists but unpopulated — wire when Supabase Auth is live
- `job_status_history.changed_by` and `job_photos.uploaded_by` FKs to users exist but unpopulated until auth is wired
- `user_roles` table dropped — role assignment now lives in `business_members`
- All `business_id` columns are nullable — backfill and add NOT NULL constraints when auth is wired
- Job status constants file needs updating to 13 statuses (includes `job_paused` and `quote_declined`)

---

## Ideas to Revisit

- Template intelligence: after enough jobs, templates self-calibrate from actual labor/material data
- Business cockpit alerts: surface problems automatically rather than requiring operator to hunt
- Data network effect: aggregate anonymized data across operators at scale becomes a product in itself
- Franchise dashboard: royalty calculation from verified revenue, network benchmarking, brand compliance
- **Core product principle:** *Nexawyn knows what should happen next.* Every feature decision should be tested against this.
