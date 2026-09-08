-- ============================================================
-- Phase 3 Schema Additions — Business/Tenant Model
-- Adds: businesses, business_members, quotes, quote_line_items
-- Adds: business_id to all operational tables
-- Adds: schedule_event_type + status, job status DB constraint
-- Adds: review request settings, close-out checklist settings
-- Run AFTER phase2-additions.sql is already in place.
-- September 7, 2026
-- ============================================================

-- ────────────────────────────────────────
-- 1. BUSINESSES — the tenant entity
-- Each business owns all its operational data.
-- Solo operator = one business, one user.
-- SaaS = many businesses, isolated from each other.
-- ────────────────────────────────────────
CREATE TABLE businesses (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  slug         TEXT UNIQUE,          -- url-safe identifier e.g. skilled-handyman
  phone        TEXT,
  email        TEXT,
  address      TEXT,
  city         TEXT,
  state        TEXT,
  zip          TEXT,
  plan_tier    TEXT DEFAULT 'solo',  -- solo | pro | crew | franchise
  is_active    BOOLEAN DEFAULT true,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- ────────────────────────────────────────
-- 2. BUSINESS MEMBERS — users linked to businesses with a role
-- Role lives here (business-scoped), not globally on the user.
-- One user can belong to multiple businesses in future.
-- ────────────────────────────────────────
CREATE TABLE business_members (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id   UUID REFERENCES businesses(id) ON DELETE CASCADE,
  user_id       UUID REFERENCES users(id) ON DELETE CASCADE,
  role          TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'technician')),
  is_active     BOOLEAN DEFAULT true,
  joined_at     TIMESTAMPTZ DEFAULT now(),
  UNIQUE (business_id, user_id)  -- one membership per user per business
);
CREATE INDEX idx_business_members_business ON business_members(business_id);
CREATE INDEX idx_business_members_user     ON business_members(user_id);

-- ────────────────────────────────────────
-- 3. ADD business_id TO ALL OPERATIONAL TABLES
-- This is what isolates each business's data from others.
-- Required for RLS policies at SaaS scale.
-- ────────────────────────────────────────
ALTER TABLE customers        ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE addresses        ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE communications   ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE jobs             ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE job_templates    ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE materials        ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE job_materials    ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE job_labor        ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE invoices         ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE accounts         ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE entries          ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE hd_purchases     ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE job_status_history ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE job_photos       ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE schedule_events  ADD COLUMN business_id UUID REFERENCES businesses(id);
ALTER TABLE operator_settings ADD COLUMN business_id UUID REFERENCES businesses(id);

CREATE INDEX idx_customers_business     ON customers(business_id);
CREATE INDEX idx_jobs_business          ON jobs(business_id);
CREATE INDEX idx_invoices_business      ON invoices(business_id);
CREATE INDEX idx_job_photos_business    ON job_photos(business_id);
CREATE INDEX idx_schedule_events_biz    ON schedule_events(business_id);

-- ────────────────────────────────────────
-- 4. QUOTES — first-class entity with immutable snapshots
-- A sent quote is a historical record. Editing job materials
-- after a quote is sent cannot alter what the customer approved.
-- ────────────────────────────────────────
CREATE TABLE quotes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID REFERENCES businesses(id),
  job_id          UUID REFERENCES jobs(id) ON DELETE CASCADE,
  customer_id     UUID REFERENCES customers(id),
  version         INTEGER DEFAULT 1,      -- increments on each revision
  status          TEXT NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft','sent','approved','declined','superseded')),
  subtotal        NUMERIC(10,2),
  markup_amount   NUMERIC(10,2),
  tax             NUMERIC(10,2) DEFAULT 0,
  total           NUMERIC(10,2),
  notes           TEXT,
  sent_at         TIMESTAMPTZ,
  approved_at     TIMESTAMPTZ,
  declined_at     TIMESTAMPTZ,
  decline_reason  TEXT,
  approved_by     TEXT,                   -- customer name or 'verbal'
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_quotes_job      ON quotes(job_id);
CREATE INDEX idx_quotes_business ON quotes(business_id);
CREATE INDEX idx_quotes_status   ON quotes(status);

-- Quote line items — immutable snapshot of what was sent
-- Written once when quote is sent. Never updated.
CREATE TABLE quote_line_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id     UUID REFERENCES quotes(id) ON DELETE CASCADE,
  type         TEXT NOT NULL CHECK (type IN ('material','labor','fee','discount')),
  description  TEXT NOT NULL,
  quantity     NUMERIC(10,2) DEFAULT 1,
  unit_price   NUMERIC(10,2),
  total        NUMERIC(10,2),
  sort_order   INTEGER DEFAULT 0
);
CREATE INDEX idx_quote_line_items_quote ON quote_line_items(quote_id);

-- ────────────────────────────────────────
-- 5. INVOICE LINE ITEMS — immutable snapshot
-- Invoices already exist. Adding line item snapshots so
-- issued invoices are never recalculated from mutable job data.
-- ────────────────────────────────────────
CREATE TABLE invoice_line_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id   UUID REFERENCES invoices(id) ON DELETE CASCADE,
  type         TEXT NOT NULL CHECK (type IN ('material','labor','fee','discount')),
  description  TEXT NOT NULL,
  quantity     NUMERIC(10,2) DEFAULT 1,
  unit_price   NUMERIC(10,2),
  total        NUMERIC(10,2),
  sort_order   INTEGER DEFAULT 0
);
CREATE INDEX idx_invoice_line_items_invoice ON invoice_line_items(invoice_id);

-- Add void/refunded states to invoices
ALTER TABLE invoices
  ADD COLUMN voided_at    TIMESTAMPTZ,
  ADD COLUMN void_reason  TEXT,
  ADD COLUMN refunded_at  TIMESTAMPTZ;

-- ────────────────────────────────────────
-- 6. JOB STATUS — database-level constraint
-- JS constants are not enough. The DB enforces valid values.
-- ────────────────────────────────────────
ALTER TABLE jobs
  ADD CONSTRAINT chk_job_status CHECK (status IN (
    'inquiry_received',
    'assessment_scheduled',
    'assessment_complete',
    'quote_in_progress',
    'quote_sent',
    'quote_approved',
    'quote_declined',
    'job_scheduled',
    'job_in_progress',
    'job_paused',
    'job_complete',
    'invoice_sent',
    'invoice_paid'
  ));

-- Add flagged notes and scope addition flag to jobs
ALTER TABLE jobs
  ADD COLUMN flagged_note        TEXT,      -- job-level pinned alert
  ADD COLUMN scope_addition_pending BOOLEAN DEFAULT false;

-- Add pinned note to customers
ALTER TABLE customers
  ADD COLUMN pinned_note TEXT;              -- always visible on every job card

-- ────────────────────────────────────────
-- 7. SCHEDULE EVENTS — add event_type and status
-- ────────────────────────────────────────
ALTER TABLE schedule_events
  ADD COLUMN event_type  TEXT DEFAULT 'work'
             CHECK (event_type IN ('assessment','work','return_visit','follow_up')),
  ADD COLUMN event_status TEXT DEFAULT 'scheduled'
             CHECK (event_status IN ('scheduled','completed','cancelled','no_show'));

-- ────────────────────────────────────────
-- 8. SEED — Skilled Handyman Services as first business
-- ────────────────────────────────────────
INSERT INTO businesses (name, slug, plan_tier)
  VALUES ('Skilled Handyman Services', 'skilled-handyman', 'solo');

-- Link Joshua's user to the business as owner
INSERT INTO business_members (business_id, user_id, role)
  SELECT
    b.id,
    u.id,
    'owner'
  FROM businesses b, users u
  WHERE b.slug = 'skilled-handyman'
    AND u.email = 'joshua@skilledhandymanservices.com';

-- Stamp business_id on the existing operator_settings seed row
UPDATE operator_settings
  SET business_id = (SELECT id FROM businesses WHERE slug = 'skilled-handyman')
  WHERE business_name = 'Skilled Handyman Services';

-- Grant access to new tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;