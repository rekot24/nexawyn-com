# Nexawyn — Working Document
**Domain:** nexawyn.com ✅ Registered — Hostinger  
**Started:** September 6, 2026  
**Status:** Phase 1 Complete → Phase 2 Starting  
**Owner:** Joshua  
**GitHub:** Rekot24  

---

## The Name

**Nexawyn** — from *nexus* (connection, the central point everything links through) with *wyn* (win) built into the ending. The platform that connects everything — and wins doing it.

Nex · a · wyn. Three syllables. Clean. Memorable. Owned completely.

---

## The One-Sentence Version

A modular, intelligent field service platform built by a solo operator for solo operators — replacing HouseCallPro, QuickBooks, and disconnected tooling with one connected system that learns your business and gets smarter over time.

---

## The Problem

Solo and small field service operators are stuck between two bad options:

- **Overbuilt tools** (HouseCallPro, ServiceTitan, QuickBooks) — designed for larger operations, bloated with unused features, priced for companies with multiple techs
- **Manual work** — spreadsheets, memory, disconnected apps that don't talk to each other

The result: quoting falls through cracks, material costs are never tracked accurately, accounting is a separate painful task, and reporting is whatever the software decides to show you — not what you actually need to know.

**The specific pain points that started this:**
- HouseCallPro has no follow-up triggers after a site visit — quotes get forgotten
- Material costs have to be entered manually with static pricing — never accurate
- Job profitability requires manual calculation after the fact
- QuickBooks costs $50+/month and is only used because everything integrates with it — not because it's good
- Nothing connects the full loop: website → quote → job → materials → invoice → accounting → reporting

---

## The Vision

A single platform where every part of a field service business is connected:

```
Customer finds you online
      ↓
Books through your website
      ↓
Smart quote built from templates + live pricing
      ↓
Customer approves via SMS link
      ↓
Job scheduled automatically
      ↓
Materials tracked from Home Depot sync
      ↓
Parts ordering tracked — customer notified automatically
      ↓
Invoice generated from actual costs
      ↓
Payment collected via Stripe
      ↓
Accounting entries created automatically
      ↓
Bank reconciled via Stripe Financial Connections
      ↓
Reporting shows real profit, margin, trends
      ↓
System gets smarter with every job
```

No dead zones. No manual data entry. No disconnected tools.

---

## Core Modules

### 1. CRM — Customer Management
The foundation everything else connects to.

**What it tracks:**
- Customer contact info and history
- Multiple property addresses per customer (home, rental, office)
- Quick-reference notes (dog at property, prefers mornings, gate code)
- Every communication logged (SMS, email, call — inbound and outbound)
- Job history and lifetime value
- Referral source tracking

**Key insight:** Pull up any customer and see their entire relationship with your business — every job, every dollar, every interaction, every note.

**Database tables:** `customers`, `addresses`, `communications`

---

### 2. Job Management + Status Engine
Every job moves through defined states. Every state has triggers. Nothing falls through the cracks.

**Job status flow:**
```
inquiry_received
→ assessment_scheduled
→ assessment_complete
→ quote_in_progress     ← timer starts — alert if stalled 2hrs
→ quote_sent            ← auto follow-up SMS at 24hr, alert to you at 48hr
→ quote_approved        ← instant notification to you
→ quote_declined        ← follow-up logic
→ job_scheduled
→ job_in_progress
→ job_complete
→ invoice_sent
→ invoice_paid          ← loop closed
```

Every status change is logged in `job_status_history` — full audit trail forever.

**Key insight:** The status engine is what HouseCallPro gets wrong. After the site visit, HCP goes silent. Nexawyn starts working harder.

**Database tables:** `jobs`, `job_status_history`, `job_labor`

---

### 3. Smart Quoting System

Three layers that compound on each other over time.

**Layer 1 — Job Templates**
Pre-built quotes for repeating job types. Set up once, use forever.

```
Template: Bathroom Faucet Replacement
  Materials:
    □ Moen 1225 Cartridge        1x   $14.97  (live price)
    □ Supply lines 3/8"          2x    $4.48  (live price)
    □ Teflon tape                1x    $1.12  (live price)
  Labor:
    □ Assessment                0.5hr
    □ Removal                   0.5hr
    □ Installation              1.0hr
    □ Cleanup & test            0.25hr
  Markup: 20%
  Estimated total: auto-calculated
```

Templates are not rigid — every line is editable per job. Optional items can be checked/unchecked.

**Layer 2 — Living Materials Catalog**
Your personal catalog of parts you actually buy, linked to real Home Depot SKUs with live pricing.

- Items added automatically when you buy something new at HD (via sync)
- Items added when you search HD during quoting
- Items added manually one time, available forever
- Prices refresh on demand or on schedule
- Most-used items (`times_used` counter) surface first in search
- Price at time of quote **locked** to that job — future price changes don't affect past records

**Layer 3 — Template Intelligence**
After enough jobs, templates self-calibrate from real data:

```
Template: Bathroom Faucet Replacement
  Avg actual labor:     2.4hrs  (you estimated 2.25)
  Avg materials cost:   $31.18  (you estimated $24.44)
  Avg profit margin:    61%
  Jobs completed:       23
  ⚠ Material estimates run 28% low — suggested buffer applied
```

Your past jobs train your future quotes. The system gets smarter every week.

**Database tables:** `job_templates`, `template_materials`, `template_labor`, `job_materials`

---

### 4. Home Depot Integration

**Function 1 — Live product lookup (for quoting)**
Search HD catalog from inside the app. Live price and local store availability (within 50 miles) pull into the quote automatically. Uses third-party HD product API via RapidAPI (~$5/1,000 lookups).

**Function 2 — Purchase sync (for job costing)**
Automated import of Pro Xtra purchase history. Every HD transaction matched to a job by job name.

**Sync options:**
- Scheduled automatic sync (weekly or custom interval)
- Manual "Sync Now" button for on-demand pull
- Duplicate prevention via `hd_transaction_id` unique constraint — same purchase can never import twice

**What it shows after sync:**
```
Sync complete ✅
  47 purchases imported
  12 jobs updated
  Last synced: Today 2:34 PM
  Next auto-sync: Sunday 12:00 AM
```

**Result:** The system knows exactly what you spent on materials for every job — without any manual entry.

**Database tables:** `hd_purchases`, linked to `jobs` via `job_id`

---

### 5. Parts Tracking & Customer Communication
When a job requires a special order or shipped part, the system keeps the customer informed automatically — zero operator effort after the tracking number is entered.

**Operator flow:**
- Mark a material as "needs ordering" when adding to a job
- Enter tracking number when order is placed
- Everything else is automatic

**Automated customer notifications (via Twilio SMS):**
```
Order placed   → "I've ordered your part. Est. arrival Thursday. Track: [link]"
Part ships     → "Your part shipped! Arriving Thursday. Track here: [link]"
Part delivered → "Your part arrived. I'll reach out to schedule your install."
Part delayed   → "Quick update — slight delay, now arriving Friday. — Joshua"
```

**Customer-facing parts status page:**
```
Your Parts Status — Skilled Handyman
Moen Faucet Cartridge
●●●○○  In Transit
Est. arrival: Thursday Sept 11
[ Track Package → UPS ]
Once parts arrive, Joshua will contact you to schedule.
```

**Operator gets notified when part arrives** with a [ Schedule Install ] button — one tap to move the job forward.

**Tracking API:** UPS, FedEx, USPS all have free tracking APIs. System polls on a schedule, fires the right message at each status change.

**Database fields:** `needs_ordering`, `tracking_number`, `carrier`, `tracking_status`, `estimated_arrival`, `arrived_at` on `job_materials`

---

### 6. Payments — Stripe Integration
- Invoice auto-generated when job moves to `job_complete`
- Invoice number format: NXW-2026-0001
- Payment link sent to customer via Twilio SMS
- Customer pays online — no phone calls, no checks
- Stripe webhook fires on payment → job status moves to `invoice_paid` → accounting entry created automatically
- No manual steps anywhere in this flow

**Database tables:** `invoices`, entries created in `entries` table

---

### 7. Customer Communications — Twilio SMS
Every customer touchpoint automated but personal-feeling. All messages configurable. All outbound and inbound messages logged against the customer record.

**Automated message triggers:**
- Booking confirmation
- Assessment reminder (day before)
- Quote sent — with approval link
- 24hr follow-up if quote not approved
- Approval confirmation
- Job reminder (day before)
- "On my way" message
- Invoice link after job complete
- Review request after payment confirmed

**Database table:** `communications` (type, direction, body, status, sent_at)

---

### 8. Accounting Engine
Built on double-entry bookkeeping — the standard structure used by every accounting system since 1494, implemented directly in Supabase PostgreSQL.

**How entries are created (automatically):**
- Stripe payment received → income entry created
- HD sync imports materials → expense entry created
- Invoice sent → accounts receivable entry created
- All entries tied to a `job_id` — every dollar traceable to a job

**Chart of accounts (seeded in database):**
```
Assets:    Checking Account, Accounts Receivable
Income:    Revenue — Labor, Revenue — Materials
Expenses:  Materials — Home Depot, Materials — Lowes,
           Materials — Other, Vehicle & Fuel,
           Tools & Equipment, Software & Subscriptions,
           Stripe Fees, Marketing, Insurance
```

**Bank Link — Stripe Financial Connections**
The core reason people use QuickBooks is the bank link. Stripe Financial Connections eliminates that dependency.

What it provides:
- Live bank account balance in your dashboard
- Transaction history pulled automatically
- Automatic reconciliation against Stripe income entries
- Unmatched transactions flagged for manual review
- Cash flow view — in vs out in real time

Cost: ~$3/month at daily balance checks.

```
Dashboard live view:
  ├── Bank balance: $4,218.43
  ├── Pending Stripe payouts: $840.00
  ├── This week in: $1,240.00
  ├── This week out: $387.22
  └── Unmatched transactions: 3 ← needs attention
```

**Key insight:** QuickBooks becomes optional. Your Supabase database is the source of truth. Export a clean report for your CPA at tax time — not a $600/year dependency.

**Database tables:** `accounts`, `entries`

---

### 9. Reporting & Intelligence

**Standard reports:**
- Revenue by period (day, week, month, year)
- Jobs completed by type
- Profit margin by job type and template
- Material costs vs estimates — accuracy tracking
- Quote acceptance rate
- Customer lifetime value ranking

**Advanced intelligence (emerges from connected data):**
- Which job types generate the most profit
- Which templates consistently run over estimate and by how much
- Which neighborhoods/zip codes are most profitable
- Seasonal demand patterns — actual slow season vs guessed
- Material price drift over time — see inflation before it hits margins
- Real hourly rate vs target rate
- Customer follow-up timing based on booking history patterns

**Business cockpit — main dashboard view:**
```
September 2026
Revenue:      $6,240   ↑ 12% vs last Sept
Margin:         64%    ↑ 3pts
Jobs:            18    ─ same
Best job type:  Plumbing ($847 avg)

⚠ Material costs up 8% this month
⚠ 4 customers haven't booked in 6 months
✓ Quote acceptance rate: 84%
```

Alerts surface automatically. You don't hunt for problems — the system surfaces them.

---

### 10. Website Integration
The platform connects to your existing marketing site — it doesn't replace it.

**Three separate concerns, one database:**
```
nexawyn.com (future SaaS marketing site)
skilledhandymanservices.com     ← marketing, SEO, public
  /services, /about, /contact
  /book  → posts to Nexawyn API → job created in database

portal.nexawyn.com              ← customer-facing portal
  View quotes, approve, pay invoices, track parts

app.nexawyn.com                 ← internal operator dashboard
  Your full operations tool (password protected)
```

Marketing site stays lean, static, SEO-optimized (Jamstack). Portal and app are dynamic React applications. All three share one Supabase database.

---

## Technology Stack

| Layer | Tool | Cost |
|-------|------|------|
| Database | Supabase (PostgreSQL) | Free tier |
| Auth | Supabase Auth | Free tier |
| Frontend | React + Vite | Free |
| Hosting | Vercel | Free tier |
| SMS / Voice | Twilio | ~$1-2/mo + ~$0.01/msg |
| Payments | Stripe | 2.9% + 30¢/transaction |
| Bank link | Stripe Financial Connections | ~$3/mo |
| HD Product API | RapidAPI | ~$5/1,000 lookups |
| Parts tracking | UPS/FedEx/USPS APIs | Free |
| Email | SendGrid | Free tier |

**Estimated monthly infrastructure cost: $10–20**
**Current tooling being replaced: $115–145/month**
**Net savings from day one: ~$100/month**

---

## Database Schema

### Status: ✅ Phase 1 Complete — All tables built and running in Supabase

**Supabase project:** Nexawyn
**Region:** East US (Ohio)
**Instance:** us-east-2, 14g.nano
**Status:** Healthy

### Tables (15 total — all created September 6, 2026)

| Table | Purpose |
|-------|---------|
| `customers` | Core customer records |
| `addresses` | Multiple properties per customer |
| `communications` | Every SMS, email, call logged |
| `materials` | Living HD-linked parts catalog |
| `job_templates` | Pre-built quote templates |
| `template_materials` | Parts list inside each template |
| `template_labor` | Labor lines inside each template |
| `jobs` | Core operational record |
| `job_materials` | Actual parts used per job (with parts ordering fields) |
| `job_labor` | Time breakdown per job |
| `invoices` | Customer invoices |
| `accounts` | Chart of accounts (seeded) |
| `entries` | Double-entry accounting transactions |
| `hd_purchases` | Home Depot Pro Xtra sync records |
| `job_status_history` | Full audit trail of every status change |

### Key Design Decisions
- `external_id UNIQUE` on entries — prevents duplicate imports from any source
- `total_price GENERATED` on job_materials — calculated column, never manually set
- `times_used` on materials and templates — self-sorts by what you actually use
- `unit_price` locked at quote time on job_materials — independent of future price changes
- All timestamps use `TIMESTAMPTZ` — timezone-aware
- Indexes on all foreign keys and status/date fields for query performance
- RLS (Row Level Security) enabled at project level

### Seeded Data
Chart of accounts pre-loaded:
- 2 asset accounts
- 2 income accounts  
- 9 expense accounts

---

## The Quote Flow — Primary Build Target (Phase 2)

**The dead zone HouseCallPro leaves:**
```
Site visit scheduled → [SILENCE] → Quote maybe gets built → Quote maybe gets sent
```

**What Nexawyn does instead:**
```
Site visit complete
  → Status auto-moves to "quote_in_progress"
  → Timer starts
  → 2hr no action → push notification to you
  → End of day no quote → escalated alert

You open the job
  → System suggests template based on job title/notes
  → Template pre-fills: all materials with live HD prices, all labor lines
  → You adjust anything specific to this job
  → Takes 5 minutes instead of 30

One tap → quote sent via SMS link to customer
  → Customer gets: "Hi Sarah, here's your quote — [view & approve]"

Customer hasn't responded in 24hrs
  → Auto SMS: "Just checking in on your quote, happy to answer questions"

Customer hasn't responded in 48hrs
  → Alert to you: "Sarah Mitchell — 48hrs no response" with [Call] button

Customer approves
  → You get instant notification
  → Job status → "quote_approved"
  → Prompt to schedule the job
```

---

## Build Phases

### Phase 1 — The Engine ✅ COMPLETE (September 6, 2026)
- [x] Platform named — Nexawyn
- [x] Domain registered — nexawyn.com (Hostinger)
- [x] Supabase project created — Nexawyn, East US Ohio
- [x] Core schema built and running — 15 tables
- [x] Chart of accounts seeded
- [x] RLS enabled
- [x] Schema saved — schema/phase1-core.sql
- [x] Working document created
- [x] CLAUDE.md project instructions written

### Phase 2 — Internal Dashboard (Current Phase)
- [ ] React + Vite project initialized
- [ ] Supabase client connected
- [ ] Job list view — organized by status
- [ ] Customer profile view
- [ ] Quote builder with template selection
- [ ] Material search (catalog + manual)
- [ ] Quote total calculation with markup
- [ ] SMS send via Twilio
- [ ] Job status update on user action
- [ ] Basic auth (Supabase Auth)

*(Ugly is fine. Working on real jobs is the goal.)*

### Phase 3 — Customer Portal
- [ ] Quote view page (SMS link destination)
- [ ] Online quote approval
- [ ] Invoice view page
- [ ] Stripe payment integration
- [ ] Parts status tracking page

### Phase 4 — Website Integration
- [ ] Booking form on skilledhandymanservices.com
- [ ] Form posts to Supabase via API
- [ ] New job created automatically in dashboard

### Phase 5 — Intelligence Layer
- [ ] HD catalog search integration (RapidAPI)
- [ ] HD Pro Xtra purchase sync (Puppeteer automation)
- [ ] Sync Now button + scheduled auto-sync
- [ ] Stripe webhook → auto accounting entries
- [ ] Stripe Financial Connections bank link
- [ ] Parts tracking API (UPS/FedEx/USPS)
- [ ] Automated parts SMS notifications
- [ ] Reporting dashboard
- [ ] Template self-calibration from job history
- [ ] Business cockpit with alerts

### Phase 6 — SaaS Product (Future)
- [ ] Nexawyn brand marketing site
- [ ] Multi-tenancy (each operator isolated)
- [ ] Self-serve onboarding flow
- [ ] Stripe subscription billing
- [ ] Operator-facing reporting
- [ ] Franchise dashboard layer

---

## Market Opportunity

**Primary target:** Solo field service operators — handymen, plumbers, electricians, HVAC, painters. ~5 million in the US. Underserved by every major platform.

**Competitive displacement:**

| Competitor | Monthly Cost | Core Problem |
|------------|-------------|--------------|
| HouseCallPro | $65 | Overbuilt for solo, dead zone after site visit, no material tracking |
| QuickBooks | $50 | Disconnected from operations, bloated, forced dependency |
| Jobber | $70 | Same problems as HCP |
| ServiceTitan | $300+ | Enterprise-only, built for multi-tech crews |
| **Nexawyn** | **$29** | **Purpose-built, connected, intelligent, learns your business** |

**What $29 replaces:** $115–145/month of disconnected tools.

**Pricing tiers:**

| Tier | Price | Who |
|------|-------|-----|
| Solo | $29/mo | One operator, up to 50 jobs/month |
| Pro | $59/mo | Unlimited jobs, advanced reporting, customer portal |
| Crew | $99/mo | Multiple techs, job assignment, dispatch |
| Franchise | Custom | Multi-location, franchisor dashboard, network benchmarking |

**Conservative growth projections:**

| Customers | MRR | ARR |
|-----------|-----|-----|
| 100 | $2,900 | $34,800 |
| 500 | $14,500 | $174,000 |
| 1,000 | $29,000 | $348,000 |

Infrastructure cost at 1,000 customers: ~$300/month. Margins are extraordinary.

---

## Unfair Advantages

1. **You are the customer** — built from lived experience, not market research or guessing
2. **Forcing function exists** — Skilled Handyman Services needs this now. Day one user is yourself
3. **Domain expertise** — you speak the language of every potential customer fluently
4. **Data analyst background** — schema design, reporting, and automation thinking are native
5. **Multi-business operator experience** — Bio-One (franchise owner), SERVPRO (FBC), Skilled Handyman
6. **Franchise network access** — direct line into SERVPRO network and franchise operator community
7. **Sales credibility** — solo operator selling to solo operators. Not a software company guessing at pain

---

## Expansion Path

**Vertical expansion** (same engine, trade-specific templates and catalog categories):
- Plumbing companies
- HVAC contractors
- Electrical contractors
- Landscaping
- Cleaning services
- Pest control
- Pool service
- Restoration companies ← direct Bio-One experience

**Franchise market (high value):**
- Franchisor dashboard — aggregate performance across all franchisees
- Royalty calculation from actual verified revenue data
- Network-wide materials pricing (negotiated bulk rates)
- Franchisee benchmarking against network averages
- Brand compliance tracking

**Data network effect (the long-term moat):**
At scale, aggregate data across thousands of operators becomes a product in itself:
- Market pricing benchmarks by region and trade
- Material cost trend forecasting
- Demand patterns by season and geography
- Margin benchmarking by job type

---

## Project Folder Structure

```
nexawyn/
  ├── CLAUDE.md                    ← Claude project instructions
  ├── field-service-platform.md   ← this working document
  ├── schema/
  │   └── phase1-core.sql         ← full Phase 1 schema (run Sept 6, 2026)
  ├── src/                        ← React app (Phase 2)
  └── docs/                       ← additional documentation
```

---

## Immediate Next Steps

- [x] Name the platform — Nexawyn
- [x] Register nexawyn.com
- [x] Create Supabase organization and project
- [x] Build and run Phase 1 core schema (15 tables)
- [x] Save schema to project folder
- [x] Write CLAUDE.md project instructions
- [x] Update working document
- [ ] Move project to Claude Projects with both docs uploaded
- [ ] Initialize React + Vite project in /src
- [ ] Install Supabase JS client
- [ ] Connect app to Supabase
- [ ] Build first screen — job list by status

**The rule:** Build for Skilled Handyman Services first. If it works for one real business, everything else follows.

---

*This is a living document. Update it as decisions are made, phases complete, and the build progresses. Last updated: September 6, 2026 — Phase 1 complete.*
