# CLAUDE.md

> This file is read automatically at the start of every Claude session in this project.
> Follow all standing instructions below without being prompted.

---

## Project summary

Nexawyn is a modular field service platform built by a solo operator for solo operators. It replaces HouseCallPro, QuickBooks, and disconnected tooling with one connected system that handles CRM, quoting, job management, invoicing, photo documentation, accounting, and reporting. The forcing function is Skilled Handyman Services CR — this is the day-one production user.

## Standards

This project follows https://github.com/Rekot24/dev-standards  
Read **web-app-framework.md** before making any architectural decisions.  
If asked to do something that conflicts with those standards, flag it before proceeding.

## Tech stack

| Layer | Tool | Cost |
|-------|------|------|
| Database | Supabase (PostgreSQL) — project: Nexawyn, region: East US (Ohio) | Free tier |
| Auth | Supabase Auth | Free tier |
| Frontend | React + Vite | Free |
| Hosting | Vercel | Free tier |
| SMS | Twilio (Phase 2+) | ~$1–2/mo + ~$0.01/msg |
| Payments | Stripe (Phase 3+) | 2.9% + 30¢/transaction |
| Bank link | Stripe Financial Connections (Phase 5+) | ~$3/mo |
| HD Product API | RapidAPI (Phase 5+) | ~$5/1,000 lookups |
| Photo storage | Supabase Storage → Cloudflare R2 at SaaS scale | ~$0.015/GB, zero egress |
| Email | SendGrid (Phase 2+) | Free tier |

## Architecture

Key files and what each one does — one line each. Update as the project grows.

- `src/lib/supabase.js` — single Supabase client instance, imported everywhere; never instantiate elsewhere
- `src/lib/logger.js` — unified logging layer; never use console.log directly *(to be created)*
- `src/constants/index.js` — all named values: timing defaults, limits, format strings *(to be created)*
- `src/constants/jobStatuses.js` — all 11 job status strings in one place *(to be created)*
- `src/context/SettingsContext.jsx` — React Context for operator settings; wraps app root *(to be created)*
- `src/hooks/useSettings.js` — read/write operator settings from any component *(to be created)*
- `src/hooks/useFeatureFlags.js` — feature flag and plan tier checks *(to be created)*
- `src/components/ErrorBoundary.jsx` — catches thrown errors at app root, shows fallback UI *(to be created)*

## Key decisions

- 2026-09-06 — Supabase (Postgres) as database. Single source of truth; RLS; real-time; free tier; scales to SaaS.
- 2026-09-06 — React + Vite frontend. Fast builds; component model fits modular approach.
- 2026-09-06 — Vercel hosting. Deploys on git push; free tier; zero config.
- 2026-09-06 — Double-entry accounting in Supabase. Eliminates QuickBooks dependency; source of truth is ours.
- 2026-09-07 — Photos stored as URLs in Supabase, files in object storage. Decouples schema from storage backend — swap storage provider without schema migration.
- 2026-09-07 — Cloudflare R2 as photo storage at SaaS scale. Zero egress fees; S3-compatible API. Supabase Storage acceptable for Phase 2 only.
- 2026-09-07 — Settings store as first-class backbone component. All configurable values in database; app reads at runtime; enables plan-tier gating at SaaS launch.
- 2026-09-07 — Feature flags for every module. No feature runs unconditionally; plan-tier gating built in from day one.
- 2026-09-07 — dev-standards repo updated to include web stack. web-app-framework.md is the reference for this project.

## Tried and rejected

- 2026-09-07 — Imported logger into SettingsContext before logger was initialized — caused silent render failure with blank screen; removed logger imports from SettingsContext until a clean initialization order is established

## Current state

- Working: Supabase connected, operator_settings loading, full scaffold wired and confirmed
- In progress: Phase 2 feature build — job list view is next
- Known broken: logger.js not yet wired back into SettingsContext (simplified version in place)

## Session log

### 2026-09-07
- Introduced dev-standards repo; web-app-framework.md adopted as the reference for this project
- Full audit of repo against dev-standards completed — 13 deviations documented
- Standards compliance items 1–5 resolved: credentials moved to env vars, CLAUDE.md created, README replaced, ROADMAP.md created
- Rebuilt entire Phase 1 schema with UUID IDs throughout (was bigint) — all 17 tables plus app_logs
- Added GRANT ALL to anon + authenticated roles — required for SQL-created tables; added to dev-standards
- Wired full Phase 2 scaffold: SettingsContext, useSettings, useFeatureFlags, logger.js, ErrorBoundary, constants/index.js, constants/jobStatuses.js
- RLS temporarily disabled on all tables for dev build phase — tracked in ROADMAP.md known issues
- App confirmed working: Business, Plan, and Supabase connection all rendering correctly

### 2026-09-06
- Platform named — Nexawyn; domain registered — nexawyn.com (Hostinger)
- Supabase project created — Nexawyn, East US (Ohio); Phase 1 core schema (15 tables) built and running
- Chart of accounts seeded; RLS enabled
- React + Vite project initialized; Supabase JS client installed and connection confirmed
- Working document (NEXAWYN.md) created

---

## Standing instructions

These apply every session without being included in the prompt:

1. Read this file fully before touching any code.
2. Read **web-app-framework.md** from https://github.com/Rekot24/dev-standards before any architectural work.
3. When a new technical decision arises, present the professional options with tradeoffs before recommending. The goal is the right long-term choice, not just what works today.
4. Before building anything, explain what you are going to do and why. Wait for confirmation.
5. Flag anything that conflicts with dev-standards before proceeding — do not comply silently.
6. No magic numbers or magic strings — all named values go in `src/constants/index.js` with a comment.
7. No raw `console.log` for debugging — all output goes through `src/lib/logger.js`.
8. Every function and hook gets a JSDoc comment before implementation is written.
9. All async functions follow the standard try/catch/finally pattern from web-app-framework.md Layer 6.
10. Every feature checks its flag in operator_settings before rendering — no feature runs unconditionally.
11. Loading, error, and empty states are built for every data-fetching component — never skipped.
12. No hardcoded values in components — all from `src/constants/` or operator settings.
13. Any schema change must be discussed before implementation — always flag as a migration required.
14. Any paid API or service must have its cost stated before it is integrated.
15. At the end of every session, before closing:
    - Add a dated entry to the session log summarizing what was done and decided
    - Update current state (working / in progress / known broken)
    - Add any new architectural choices to key decisions
    - Add anything tried and abandoned to tried and rejected
    - Commit the updated CLAUDE.md as the final commit: `docs: update CLAUDE.md session log [YYYY-MM-DD]`