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

### 6. Photo Documentation
Native job photo management — modeled after CompanyCam but fully integrated into the job record, status flow, and customer portal. The key differentiator: photos in Nexawyn know their context automatically. A photo taken during `assessment_complete` is an assessment photo. A photo taken during `job_in_progress` is a mid-job photo. That context is automatic — not manual tagging.

**Why photos matter in field service:**
- **CYA documentation** — timestamped proof of site condition before work begins. Protects against "you caused that damage" disputes.
- **Insurance job documentation** — before/during/after photo sets for adjuster review. Especially critical for water damage, fire, and restoration work.
- **Completion proof** — customer disputes the work was done. Timestamped photos from `job_complete` status are the answer.
- **Scope expansion** — damage found outside the original scope gets photographed, flagged, and quoted directly from the job record.

**Photo categories (auto-assigned by job status at time of capture):**

| Category | Status at capture | Who sees it |
|----------|-------------------|-------------|
| `assessment` | `assessment_complete` | Operator + customer (alongside quote) |
| `in_progress` | `job_in_progress` | Operator only |
| `completion` | `job_complete` | Operator + customer (with invoice) |
| `damage` | Any | Operator only (triggers scope expansion) |
| `document` | Any | Operator only |

**What native integration unlocks that CompanyCam can't do:**
- Assessment photos appear alongside the customer's quote — they see exactly what you saw. Builds trust, improves quote acceptance.
- Completion before/after pair auto-attaches to the invoice — no "let me send you the photos separately."
- Insurance job → full photo timeline with timestamps is exportable as a PDF report tied to the job record. One tap.
- Customer pulls up a past job in the portal — photos are right there in the job history. Not in a separate app.
- A year from now — you pull up a past job and the full photo record is there alongside every other job detail.

**Storage architecture decision:**

Photos are NOT stored in the Supabase database. The database stores the URL, metadata, and context. The actual image files live in Cloudflare R2.

```
Photo taken on phone
      ↓
Uploaded directly to Cloudflare R2
      ↓
URL + metadata written to job_photos table in Supabase
      ↓
Served via Cloudflare CDN to anyone authorized to view it
```

**Why Cloudflare R2 and not Supabase Storage:**
- Supabase Storage is fine for a single operator at low volume
- At SaaS scale (1,000 operators × 50 jobs/month × 10 photos = 500,000 photos/month), egress fees on any other provider become significant
- Cloudflare R2 has **zero egress fees** — photos can be viewed as many times as needed at no additional cost
- R2 uses the same S3-compatible API, so the migration path is straightforward when the time comes
- For Phase 2 (single operator): Supabase Storage is acceptable as a starting point
- For SaaS launch: migrate to R2 — schema change is zero because the `job_photos` table stores a `storage_url` field, not the file itself

**Database table:**
```sql
CREATE TABLE job_photos (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id           UUID REFERENCES jobs(id) ON DELETE CASCADE,
  storage_url      TEXT NOT NULL,          -- R2 URL (or Supabase Storage URL in early phase)
  thumbnail_url    TEXT,                   -- smaller version for gallery views
  category         TEXT NOT NULL,          -- assessment | in_progress | completion | damage | document
  status_at_capture TEXT,                  -- job status when photo was taken
  caption          TEXT,                   -- optional operator note
  geo_lat          NUMERIC(10,7),          -- GPS latitude at capture
  geo_lon          NUMERIC(10,7),          -- GPS longitude at capture
  taken_at         TIMESTAMPTZ NOT NULL,   -- device timestamp at capture
  uploaded_at      TIMESTAMPTZ DEFAULT now(),
  uploaded_by      UUID,                   -- operator_id for multi-user future
  file_size_bytes  INTEGER,
  mime_type        TEXT DEFAULT 'image/jpeg'
);

CREATE INDEX idx_job_photos_job    ON job_photos(job_id, taken_at);
CREATE INDEX idx_job_photos_cat    ON job_photos(job_id, category);
```

**Access control (who sees what):**
- Operator sees all photos for all their jobs — always
- Customer sees `assessment` and `completion` photos only — surfaced in quote view and invoice view
- Insurance export — all photos for a job with timestamps, exported as a timestamped PDF report

**Database table:** `job_photos`

---

### 7. Settings Store & Feature Flags
The application-wide configuration layer. Every value that could change — timing defaults, business preferences, feature availability, plan tier access — lives here. Nothing meaningful is hardcoded in the app.

**Why this is a backbone component (not an afterthought):**
Without a settings store, changing a default requires a code deploy. With a settings store, the operator changes it in their settings UI and it takes effect instantly — no code touched. At SaaS scale, this is also what enables different operators to have different configurations, and different plan tiers to have different capabilities.

**Three tiers of configuration:**

**Tier 1 — Operator preferences** (operator-controlled via settings UI):
- Business name, logo, contact info
- Default labor rate and markup percentage
- Quote follow-up timing (default: 24hr first SMS, 48hr alert)
- SMS message templates — the exact wording of every automated message
- Invoice number prefix and format
- Timezone
- Notification preferences

**Tier 2 — Feature flags** (operator-visible; plan-gated in SaaS phase):
Every feature in the platform has a database-driven on/off switch. The feature checks its flag before rendering. If the flag is off, the feature doesn't appear — not disabled, just absent.

| Flag | Default | Notes |
|------|---------|-------|
| `photos_enabled` | `true` | Photo documentation module |
| `hd_sync_enabled` | `false` | Home Depot purchase sync |
| `parts_tracking_enabled` | `false` | Parts ordering + SMS tracking |
| `sms_followup_enabled` | `true` | Automated quote follow-up |
| `bank_link_enabled` | `false` | Stripe Financial Connections |
| `accounting_enabled` | `true` | Double-entry accounting module |
| `debug_enabled` | `false` | Debug output (dev use only) |

**Tier 3 — Plan tier config** (platform-controlled; determines what the operator can access):
- `plan_tier`: `solo` | `pro` | `crew` | `franchise`
- Plan tier is checked alongside feature flags — a feature must be both enabled AND unlocked for the operator's plan
- Changing a plan tier in the database instantly changes what the operator sees with no code deploy

**Database table:**
```sql
CREATE TABLE operator_settings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id     UUID REFERENCES operators(id) ON DELETE CASCADE,

  -- Tier 1: Operator preferences
  business_name         TEXT,
  labor_rate_default    NUMERIC(10,2) DEFAULT 75.00,
  markup_default        NUMERIC(5,4)  DEFAULT 0.20,
  quote_followup_hrs    INTEGER       DEFAULT 24,
  quote_alert_hrs       INTEGER       DEFAULT 48,
  invoice_prefix        TEXT          DEFAULT 'NXW',
  timezone              TEXT          DEFAULT 'America/Denver',
  sms_template_quote    TEXT,
  sms_template_followup TEXT,
  sms_template_reminder TEXT,

  -- Tier 2: Feature flags
  photos_enabled          BOOLEAN DEFAULT true,
  hd_sync_enabled         BOOLEAN DEFAULT false,
  parts_tracking_enabled  BOOLEAN DEFAULT false,
  sms_followup_enabled    BOOLEAN DEFAULT true,
  bank_link_enabled       BOOLEAN DEFAULT false,
  accounting_enabled      BOOLEAN DEFAULT true,
  debug_enabled           BOOLEAN DEFAULT false,

  -- Debug sub-flags
  debug_log_state_changes  BOOLEAN DEFAULT true,
  debug_log_api_calls      BOOLEAN DEFAULT false,
  debug_log_settings_reads BOOLEAN DEFAULT false,
  debug_log_render_cycles  BOOLEAN DEFAULT false,

  -- Tier 3: Plan config
  plan_tier     TEXT DEFAULT 'solo',

  updated_at    TIMESTAMPTZ DEFAULT now()
);
```

**How it works in the React app:**
Settings are fetched once on app load, stored in React Context (`SettingsContext`), and available to every component without prop drilling. When a setting changes in the UI, it writes to Supabase and updates the context — every component re-renders with the new value instantly. No page reload. No restart.

See `snippets/useSettings.js` and `snippets/useFeatureFlags.js` in the dev-standards repo for the full implementation.

**Database table:** `operator_settings`

---

### 8. Payments — Stripe Integration
- Invoice auto-generated when job moves to `job_complete`
- Invoice number format: NXW-2026-0001
- Payment link sent to customer via Twilio SMS
- Customer pays online — no phone calls, no checks
- Stripe webhook fires on payment → job status moves to `invoice_paid` → accounting entry created automatically
- No manual steps anywhere in this flow

**Database tables:** `invoices`, entries created in `entries` table

---

### 9. Customer Communications — Twilio SMS
Every customer touchpoint automated but personal-feeling. All messages configurable via the settings store — the operator edits wording in their settings UI, changes take effect on the next send. All outbound and inbound messages logged against the customer record.

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

### 10. Accounting Engine
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

### 11. Reporting & Intelligence

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

### 12. Website Integration
The platform connects to your existing marketing site — it doesn't replace it.

**Three separate concerns, one database:**
```
nexawyn.com (future SaaS marketing site)
skilledhandymanservices.com     ← marketing, SEO, public
  /services, /about, /contact
  /book  → posts to Nexawyn API → job created in database

portal.nexawyn.com              ← customer-facing portal
  View quotes, approve, pay invoices, track parts, view photos

app.nexawyn.com                 ← internal operator dashboard
  Your full operations tool (password protected)
```

Marketing site stays lean, static, SEO-optimized (Jamstack). Portal and app are dynamic React applications. All three share one Supabase database.

---

### 13. UX Philosophy & Design Principles

The target user is a non-technical field worker — old-school handyman types who are
not comfortable with technology. The app must be learnable with zero training and
operable with gloves on, phone in one hand, standing in a driveway.

### Core principles
- **Big targets, obvious actions** — the most common next action should always be
  the most prominent thing on screen. No hunting through menus.
- **Status-driven UI** — job status IS the navigation. If a job is "En Route," the
  screen surfaces "Mark Arrived." The user should never have to think about what to
  do next.
- **Words, not icons alone** — label everything. "New Job" not ➕. "Take Photo" not 📷.
- **Minimal data entry** — every required field is friction. Ruthlessly question
  whether a field is needed now vs. optional/later.
- **Confirmation over correction** — make destructive actions hard to do by accident.

  ### Contextual Alerts
  Notifications and messages surface where the relevant job is — not only in a 
  separate inbox. If a customer sends a message, it appears as an inline alert 
  on their job card in the schedule view, showing a preview of the message.

  This prevents the HouseCallPro failure mode: a red badge on a bottom tab 
  that's easy to miss, with no visual connection to the job it affects.

  The app also has a dedicated Communications Center — a full inbox view across 
  all customers and jobs — accessible from the main nav. The contextual alert 
  gets your attention; the Communications Center gives you the full picture when 
  you want it.

  Rule: anything that requires operator awareness before arriving at a job must 
  be visible on the job card, not buried in a separate screen.
  - **Flagged notes** work the same way. Any note can be flagged as critical, which 
  pins it to the job card in the schedule view:

- **Job-level flags** — specific to this visit. Visible on the job card until 
  the job is closed.
- **Customer-level flags** — always true about this customer or property. 
  Visible on every job card for this customer, permanently. Examples: "Dog at 
  property," "Gate code 4491," "Never before 9am."

Rule: a flagged note is never more than one glance away when a job appears 
anywhere in the app.

Intuitive design is a core product differentiator, not a polish pass done at the end.

### On My Way
Tapping "On My Way" on a job card does three things simultaneously:
1. Sends the customer an SMS with an ETA pulled from Google Maps drive time
2. Opens Maps with the job address loaded and navigation started
3. Logs the communication against the job record automatically

The ETA is calculated at the moment of tap — so it reflects actual current 
drive time, not a guess.

**The stop-first rule:** "On My Way" is tapped when you are actually leaving 
for the job site — not before a supply run or any other stop. If you need to 
make a stop first, navigate there separately. Tap "On My Way" when you leave 
that stop headed to the customer. The ETA will be accurate.

**Settings (all in operator_settings):**
- `on_my_way_enabled` — turn the feature on/off entirely
- `on_my_way_open_maps` — auto-launch navigation when tapped (default: on)
- `on_my_way_include_eta` — include drive time estimate in the SMS (default: on)
- `on_my_way_sms_template` — editable message wording; supports 
  `{customer_name}` and `{eta}` variables

Default message: "Hi {customer_name}, I'm on my way! See you in about 
{eta}. — Joshua"

---

### 14. Role-Based Permissions

The platform is designed for solo operators today but multi-user teams from day one.
Permissions are role-based and assigned per user. Solo operator = one user with all roles.

### Planned roles (initial)
| Role | What they can do |
|------|-----------------|
| Owner | Everything — full access |
| Admin | Everything except billing/account settings |
| Technician | View assigned jobs, update job status, take photos, add field notes |

### Design rules
- Role permissions must be in the schema from day one — this touches nearly every table
- Features not permitted for a role are hidden entirely, not just disabled
- A solo operator with all roles sees all features with no friction

### Feature store concept
As the platform grows, features can be toggled per role. Examples:
- Quoting / estimating → Owner or Admin only
- Invoicing → Owner or Admin only
- Schedule visibility → scoped to own assignments for Technician
- End-of-day admin → Owner or Admin only

---

### 15. Job & Schedule Data Model

### Core principle: Jobs and schedule events are separate entities

A job is the contract — it holds the customer, scope, total value, photos, notes,
and billing. It is the single source of truth.

A schedule event is a time block — it points to a job and says "we are working on
this job on this day, these hours, this person." Many events can point to one job.

This avoids the HouseCallPro anti-pattern where multi-day jobs require duplicated
job records or fragmented billing across schedule pages.

### Relationship

- `schedule_events` table has a `job_id` foreign key
- Invoice and billing value live on the `jobs` record — never on a schedule event
- Photos, notes, and job history live on `jobs` — accessible from any schedule event
  that references that job
- A multi-day job = one job record + multiple schedule_events rows

---

### 16. Materials Buy List

The job screen includes a Materials tab showing all parts on the job as a 
checklist. This doubles as a buy list for pre-job supply runs.

**Per-item display (when HD integration is active):**
- Item name and quantity needed
- In-stock status at operator's local Home Depot
- Aisle and bay location
- Low stock warning (fewer than 3 remaining)
- Out of stock flag

**Checklist behavior:**
- Checking an item marks it as acquired in `job_materials`
- Unchecked items are still needed — checked items are done
- List persists — if you close and reopen, state is saved

**Multi-job buy list:**
When heading to Home Depot before multiple jobs, the operator can generate a 
combined buy list across all jobs scheduled for the day. Items are grouped by 
aisle so the trip is a single efficient pass through the store.

**Settings:**
- `local_hd_store_id` — operator's primary Home Depot store (set once in 
  settings; used for stock and aisle lookups)

**Role access:**
- Owner / Admin — full materials view including costs and markup
- Technician — checklist view only; no pricing visible

---

### 17. On-Site Workflow & Job Interruptions

**Status-driven screen shifts:**
When "Mark Arrived" is tapped, the job moves to `job_in_progress` and the 
screen shifts — primary actions become photo capture and job controls. 
Pre-job prep elements fade back.

**Pause Job flow:**
Tapping "Pause Job" prompts the operator to select a reason before leaving 
the site. Reason is required — the job record always reflects what happened 
and why.

| Reason | What happens next |
|--------|------------------|
| Need materials / supply run | Opens buy list; optionally launches Maps to nearest HD |
| Forgot a tool — returning shortly | Logs pause with timestamp; job stays in_progress |
| Rescheduling — returning another day | Prompts for return date; creates new schedule_event on same job |
| Scope change — need to update quote | Opens scope change flow (see below) |
| Customer stopped the job | Prompts for note; flags job for follow-up; logs with timestamp |
| Other | Free text note logged to job record with timestamp |

All pause reasons log to `job_status_history` with timestamp. The job never 
returns to blank — there is always a record of what happened and when.

**Scope change flow:**
When scope change is selected, operator first answers:
Is this additional work part of today's job?

[ Yes — adding to current work order ]
[ No — this is a separate job ]

**Yes — same work order:**
- **Add to this job now** — opens quote editor on the current job. New line 
  items, materials, and labor added. Updated quote sent to customer for 
  approval before work resumes. Fully documented and approved on site.
- **Take photos and quote later** — opens camera in scope photo mode. Operator 
  shoots and adds a voice or text note. Job flagged as "scope addition pending" 
  until the updated quote is built and sent.

**No — separate job:**
Creates a new job record linked to the same customer, pre-populated with 
customer info and property address. Drops into the assessment/quote flow for 
the new job. The original job continues unaffected. One job, one invoice, 
one scope — no blended work orders.

Neither path forces a decision under pressure. The operator picks what fits 
the moment — both are fully documented.

- **Add to this job now** — opens quote editor on the job. New line items, 
  materials, and labor are added. Updated quote sent to customer for approval 
  before work resumes. Fully documented and approved on site.
- **Take photos and quote later** — opens camera in scope photo mode. Operator 
  shoots what's needed and adds a voice or text note. Job is flagged as 
  "scope addition pending" and surfaces on the home screen as a contextual 
  alert until the quote is built and sent.

Neither path forces a decision under pressure. The operator picks what fits 
the moment — both are fully documented.

**Scope addition pending flag:**
A job with an unresolved scope addition shows a contextual alert on its job 
card everywhere it appears:
Flag clears when the updated quote is sent.

---

### 18. Job Close-Out Workflow

Close-out is gated behind a checklist. "Mark Complete" does not activate until 
the checklist is cleared. This builds consistent habits and protects the 
operator from leaving a job with missing documentation or uncollected payment.

**Static close-out checklist (every job):**
- [ ] Before/site condition photos taken
- [ ] Completion photos taken
- [ ] Site cleaned up — no debris or tools left behind
- [ ] Customer walkthrough done
- [ ] Ask for Google review (QR code shown on screen)
- [ ] Payment collected or invoice sent

**Intelligent checklist (job-type specific):**
Over time, the system learns close-out steps specific to each job type based 
on the template used. Steps are suggested automatically and refined as the 
operator adds or removes them across completed jobs. Same self-calibrating 
intelligence as quote templates — gets smarter with use.

Example additions by job type:
- Faucet replacement → "Run water 2 minutes — confirm no leaks"
- Drywall patch → "Confirm texture match approved by customer"
- Electrical work → "Test all switches and outlets in affected area"

**Google Review QR code:**
When the checklist is complete and "Mark Complete" is tapped, a QR code 
appears on screen linking directly to the operator's Google Business review 
page. Operator hands phone to customer — they scan and review on the spot. 
QR code also appears on the invoice (digital and printed) for customers 
paying later.

**Payment close-out — three paths:**

| Option | What happens |
|--------|-------------|
| Paying now — Stripe | Payment link opens on screen or fires via SMS; job moves to `invoice_paid` on completion |
| Paying by check | Payment logged as received; check number recorded; invoice marked paid |
| Send invoice — pay later | SMS fires with payment link; job moves to `invoice_sent`; follow-up triggers activate |

All three paths close the job record cleanly with no ambiguity about payment status.

**Review request automation:**
After `invoice_paid` is confirmed (any payment method), an automated SMS fires 
after a configurable delay (default: 1 hour):
"Hi {customer_name}, thanks so much for the work today! If you have a moment, 
a Google review means the world to a small business. [link]"

Settings:
- `review_request_enabled` — toggle on/off
- `review_request_delay_hrs` — delay after payment confirmed (default: 1hr)
- `review_request_sms_template` — editable message wording
- `google_review_url` — operator's Google Business review link (set once in settings)

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
| **Photo storage (Phase 2)** | **Supabase Storage** | **Free tier (temp)** |
| **Photo storage (SaaS)** | **Cloudflare R2 + CDN** | **~$0.015/GB, zero egress** |

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

### Tables (21 total — Phase 1: 15 built Sept 6, 2026 | Phase 2 additions: 6)

| Table | Purpose | Phase |
|-------|---------|-------|
| `customers` | Core customer records | 1 ✅ |
| `addresses` | Multiple properties per customer | 1 ✅ |
| `communications` | Every SMS, email, call logged | 1 ✅ |
| `materials` | Living HD-linked parts catalog | 1 ✅ |
| `job_templates` | Pre-built quote templates | 1 ✅ |
| `template_materials` | Parts list inside each template | 1 ✅ |
| `template_labor` | Labor lines inside each template | 1 ✅ |
| `jobs` | Core operational record | 1 ✅ |
| `job_materials` | Actual parts used per job (with parts ordering fields) | 1 ✅ |
| `job_labor` | Time breakdown per job | 1 ✅ |
| `invoices` | Customer invoices | 1 ✅ |
| `accounts` | Chart of accounts (seeded) | 1 ✅ |
| `entries` | Double-entry accounting transactions | 1 ✅ |
| `hd_purchases` | Home Depot Pro Xtra sync records | 1 ✅ |
| `job_status_history` | Full audit trail of every status change | 1 ✅ |
| `job_photos` | Photo records (URL + metadata + context) | 2 ✅ |
| `operator_settings` | Settings store: preferences, feature flags, plan tier | 2 ✅ |
| `app_logs` | Debug and event logging | 2 ✅ |
| `users` | Operator and technician accounts (linked to Supabase Auth) | 2 ✅ |
| `user_roles` | Role assignments per user (owner, admin, technician) | 2 ✅ |
| `schedule_events` | Time blocks pointing to jobs — supports multi-day jobs | 2 ✅ |

### Key Design Decisions
- `external_id UNIQUE` on entries — prevents duplicate imports from any source
- `total_price GENERATED` on job_materials — calculated column, never manually set
- `times_used` on materials and templates — self-sorts by what you actually use
- `unit_price` locked at quote time on job_materials — independent of future price changes
- All timestamps use `TIMESTAMPTZ` — timezone-aware
- Indexes on all foreign keys and status/date fields for query performance
- RLS (Row Level Security) enabled at project level
- `storage_url` on job_photos stores a URL — file lives in storage (Supabase Storage now, R2 at scale). Schema never changes when storage backend changes.
- `operator_settings` row auto-created on first login with all defaults — app never needs to handle a missing row
- `customers.notes` supports flagged entries — a `pinned_note` field surfaces on every job card for that customer. Job-level flagged notes live on `jobs` as a `flagged_note` field — visible on the job card until the job closes.

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
**Schema additions required before build begins:**
- [ ] Add `job_photos` table to Supabase
- [ ] Add `operator_settings` table to Supabase — auto-seed defaults on first login

**App build:**
- [ ] React + Vite project initialized ✅ (done)
- [ ] Supabase client connected ✅ (done)
- [ ] RLS temporarily disabled on dev tables (Option B — re-enable with auth)
- [ ] SettingsContext + useSettings hook wired at app root
- [ ] useFeatureFlags hook created
- [ ] logger.js wired to Supabase
- [ ] Job list view — organized by status
- [ ] Customer profile view
- [ ] Quote builder with template selection
- [ ] Material search (catalog + manual)
- [ ] Quote total calculation with markup
- [ ] SMS send via Twilio
- [ ] Job status update on user action
- [ ] Basic photo capture and attach to job (assessment + completion)
- [ ] Basic auth (Supabase Auth)

*(Ugly is fine. Working on real jobs is the goal.)*

### Phase 3 — Customer Portal
- [ ] Quote view page (SMS link destination)
- [ ] Assessment photos shown alongside quote line items
- [ ] Online quote approval
- [ ] Invoice view page with completion photos
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
- [ ] Photo export — PDF report with timestamps (for insurance jobs)
- [ ] Migrate photo storage from Supabase Storage → Cloudflare R2
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
| CompanyCam | $49 | Photos only — siloed, no job context, no customer integration |
| ServiceTitan | $300+ | Enterprise-only, built for multi-tech crews |
| **Nexawyn** | **$29** | **Purpose-built, connected, intelligent, learns your business** |

**What $29 replaces:** $115–195/month of disconnected tools (including CompanyCam).

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
- Restoration companies ← direct Bio-One experience (insurance photo documentation is critical here)

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

## Architecture Decisions Log

| Date | Decision | Reasoning |
|------|----------|-----------|
| Sept 6, 2026 | Supabase (Postgres) as database | Single source of truth; RLS; real-time; free tier; scales |
| Sept 6, 2026 | React + Vite frontend | Fast builds; component model fits modular approach |
| Sept 6, 2026 | Vercel hosting | Deploys on git push; free tier; zero config |
| Sept 6, 2026 | Double-entry accounting in Supabase | Eliminates QuickBooks dependency; source of truth is ours |
| Sept 7, 2026 | Photos stored as URLs in Supabase, files in object storage | Decouples schema from storage backend — swap storage provider without schema migration |
| Sept 7, 2026 | Cloudflare R2 as photo storage (at scale) | Zero egress fees at SaaS scale; S3-compatible API; Supabase Storage acceptable for Phase 2 only |
| Sept 7, 2026 | Settings store as first-class backbone component | All configurable values in database; app reads at runtime; operator controls without code deploys; enables plan-tier gating at SaaS launch |
| Sept 7, 2026 | Feature flags for every module | No feature runs unconditionally; enables safe partial rollout; plan-tier gating built in from day one |
| Sept 7, 2026 | dev-standards updated to include web stack | All architectural patterns documented in Rekot24/dev-standards; web-app-framework.md is the reference for this project |
| Sept 7, 2026 | Jobs and schedule_events are separate tables | Billing and job context live on jobs; schedule_events are time blocks with a job_id FK — solves HouseCallPro multi-day job fragmentation |
| Sept 7, 2026 | Role-based permissions in schema from day one | user_roles table built in Phase 2; features hidden (not just disabled) for unauthorized roles; solo operator = owner role with full access |
| Sept 7, 2026 | One role per user (UNIQUE constraint on user_id) | Simple and clean for now; constraint dropped if multi-role is needed later |
| Sept 7, 2026 | Materials buy list pulls live HD stock and aisle data | Same API used for live pricing (RapidAPI) returns stock status and location — no additional integration needed |

---

## Project Folder Structure

```
nexawyn/
  ├── CLAUDE.md                    ← Claude project instructions
  ├── field-service-platform.md   ← this working document
  ├── ROADMAP.md                  ← living roadmap (future)
  ├── schema/
  │   └── phase1-core.sql         ← full Phase 1 schema (run Sept 6, 2026)
  ├── src/                        ← React app (Phase 2)
  │   ├── constants/              ← named constants (no magic numbers)
  │   ├── context/                ← React Context providers
  │   ├── hooks/                  ← useSettings, useFeatureFlags, useJobs, etc.
  │   ├── components/             ← UI components by domain
  │   ├── lib/                    ← supabase.js, logger.js, formatters.js
  │   └── styles/                 ← tokens.css, globals.css
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
- [x] Initialize React + Vite project
- [x] Install Supabase JS client
- [x] Connect app to Supabase (connection confirmed)
- [x] Update dev-standards repo with web stack framework
- [x] Add `job_photos` table to Supabase schema
- [x] Add `operator_settings` table to Supabase schema
- [x] Add `users` and `user_roles` tables to Supabase schema
- [x] Add `schedule_events` table to Supabase schema
- [ ] Wire SettingsContext and useSettings at app root
- [ ] Wire useFeatureFlags hook
- [ ] Wire logger.js to Supabase
- [ ] Disable RLS on dev tables (Option B) and build job list screen

**The rule:** Build for Skilled Handyman Services first. If it works for one real business, everything else follows.

---

*This is a living document. Update it as decisions are made, phases complete, and the build progresses. Last updated: September 7, 2026 — UX philosophy, role-based permissions, job/schedule data model, and Phase 2 schema additions complete.*
