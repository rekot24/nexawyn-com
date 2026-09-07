-- ============================================================
-- Nexawyn — Full Schema Rebuild (UUID IDs throughout)
-- Drops all tables and recreates clean with UUID primary keys.
-- Safe to run: dev only, no real data.
-- September 7, 2026
-- ============================================================

-- ────────────────────────────────────────
-- STEP 1: Drop everything (children first)
-- ────────────────────────────────────────
DROP TABLE IF EXISTS job_photos          CASCADE;
DROP TABLE IF EXISTS operator_settings   CASCADE;
DROP TABLE IF EXISTS job_status_history  CASCADE;
DROP TABLE IF EXISTS hd_purchases        CASCADE;
DROP TABLE IF EXISTS entries             CASCADE;
DROP TABLE IF EXISTS accounts            CASCADE;
DROP TABLE IF EXISTS invoices            CASCADE;
DROP TABLE IF EXISTS job_labor           CASCADE;
DROP TABLE IF EXISTS job_materials       CASCADE;
DROP TABLE IF EXISTS jobs                CASCADE;
DROP TABLE IF EXISTS template_labor      CASCADE;
DROP TABLE IF EXISTS template_materials  CASCADE;
DROP TABLE IF EXISTS job_templates       CASCADE;
DROP TABLE IF EXISTS materials           CASCADE;
DROP TABLE IF EXISTS communications      CASCADE;
DROP TABLE IF EXISTS addresses           CASCADE;
DROP TABLE IF EXISTS customers           CASCADE;

-- ────────────────────────────────────────
-- STEP 2: Recreate all tables with UUID
-- ────────────────────────────────────────

-- Customers — core record everything links to
CREATE TABLE customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name       TEXT NOT NULL,
  phone           TEXT,
  email           TEXT,
  referral_source TEXT,
  notes           TEXT,
  lifetime_value  NUMERIC(10,2) DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Addresses — multiple properties per customer
CREATE TABLE addresses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id   UUID REFERENCES customers(id) ON DELETE CASCADE,
  label         TEXT,  -- home | rental | office | etc.
  line1         TEXT NOT NULL,
  line2         TEXT,
  city          TEXT,
  state         TEXT,
  zip           TEXT,
  is_primary    BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_addresses_customer ON addresses(customer_id);

-- Communications — every SMS, email, call logged
CREATE TABLE communications (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id  UUID REFERENCES customers(id) ON DELETE CASCADE,
  job_id       UUID,  -- FK added after jobs table exists (see below)
  type         TEXT NOT NULL,       -- sms | email | call
  direction    TEXT NOT NULL,       -- inbound | outbound
  body         TEXT,
  status       TEXT,               -- sent | delivered | failed | received
  sent_at      TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_communications_customer ON communications(customer_id);

-- Materials — living HD-linked parts catalog
CREATE TABLE materials (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  sku             TEXT,             -- Home Depot SKU
  unit            TEXT DEFAULT 'each',
  current_price   NUMERIC(10,2),
  last_price_check TIMESTAMPTZ,
  times_used      INTEGER DEFAULT 0,
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Job templates — pre-built quote templates
CREATE TABLE job_templates (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  times_used  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Template materials — parts list inside each template
CREATE TABLE template_materials (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id  UUID REFERENCES job_templates(id) ON DELETE CASCADE,
  material_id  UUID REFERENCES materials(id),
  quantity     NUMERIC(10,2) DEFAULT 1,
  is_optional  BOOLEAN DEFAULT false
);
CREATE INDEX idx_template_materials_template ON template_materials(template_id);

-- Template labor — labor lines inside each template
CREATE TABLE template_labor (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id  UUID REFERENCES job_templates(id) ON DELETE CASCADE,
  description  TEXT NOT NULL,
  hours        NUMERIC(5,2),
  is_optional  BOOLEAN DEFAULT false
);
CREATE INDEX idx_template_labor_template ON template_labor(template_id);

-- Jobs — core operational record
CREATE TABLE jobs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID REFERENCES customers(id),
  address_id      UUID REFERENCES addresses(id),
  title           TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'inquiry_received',
  notes           TEXT,
  template_id     UUID REFERENCES job_templates(id),
  labor_rate      NUMERIC(10,2),
  markup_pct      NUMERIC(5,4),
  scheduled_at    TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_jobs_customer ON jobs(customer_id);
CREATE INDEX idx_jobs_status   ON jobs(status);

-- Now add the job_id FK to communications
ALTER TABLE communications
  ADD CONSTRAINT fk_communications_job
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE SET NULL;
CREATE INDEX idx_communications_job ON communications(job_id);

-- Job materials — actual parts used per job
CREATE TABLE job_materials (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id        UUID REFERENCES jobs(id) ON DELETE CASCADE,
  material_id   UUID REFERENCES materials(id),
  name          TEXT NOT NULL,         -- snapshot at time of quote
  quantity      NUMERIC(10,2) DEFAULT 1,
  unit_price    NUMERIC(10,2) NOT NULL, -- locked at quote time
  total_price   NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  markup_pct    NUMERIC(5,4),
  needs_ordering   BOOLEAN DEFAULT false,
  tracking_number  TEXT,
  carrier          TEXT,
  tracking_status  TEXT,
  estimated_arrival TIMESTAMPTZ,
  arrived_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_job_materials_job ON job_materials(job_id);

-- Job labor — time breakdown per job
CREATE TABLE job_labor (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id       UUID REFERENCES jobs(id) ON DELETE CASCADE,
  description  TEXT NOT NULL,
  hours        NUMERIC(5,2),
  rate         NUMERIC(10,2),
  created_at   TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_job_labor_job ON job_labor(job_id);

-- Invoices — customer invoices
CREATE TABLE invoices (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id         UUID REFERENCES jobs(id),
  customer_id    UUID REFERENCES customers(id),
  invoice_number TEXT UNIQUE,
  status         TEXT DEFAULT 'draft',  -- draft | sent | paid | void
  subtotal       NUMERIC(10,2),
  tax            NUMERIC(10,2) DEFAULT 0,
  total          NUMERIC(10,2),
  sent_at        TIMESTAMPTZ,
  paid_at        TIMESTAMPTZ,
  stripe_payment_intent_id TEXT,
  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_invoices_job      ON invoices(job_id);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);

-- Accounts — chart of accounts
CREATE TABLE accounts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  type         TEXT NOT NULL,  -- asset | income | expense | liability
  code         TEXT UNIQUE,
  description  TEXT,
  created_at   TIMESTAMPTZ DEFAULT now()
);

-- Entries — double-entry accounting transactions
CREATE TABLE entries (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id       UUID REFERENCES jobs(id) ON DELETE SET NULL,
  account_id   UUID REFERENCES accounts(id),
  type         TEXT NOT NULL,       -- debit | credit
  amount       NUMERIC(10,2) NOT NULL,
  description  TEXT,
  external_id  TEXT UNIQUE,         -- prevents duplicate imports from any source
  entry_date   TIMESTAMPTZ DEFAULT now(),
  created_at   TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_entries_job     ON entries(job_id);
CREATE INDEX idx_entries_account ON entries(account_id);
CREATE INDEX idx_entries_date    ON entries(entry_date);

-- HD purchases — Home Depot Pro Xtra sync records
CREATE TABLE hd_purchases (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id            UUID REFERENCES jobs(id) ON DELETE SET NULL,
  hd_transaction_id TEXT UNIQUE,    -- prevents duplicate imports
  purchased_at      TIMESTAMPTZ,
  store_number      TEXT,
  total_amount      NUMERIC(10,2),
  items             JSONB,           -- raw line items from HD
  synced_at         TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_hd_purchases_job ON hd_purchases(job_id);

-- Job status history — full audit trail of every status change
CREATE TABLE job_status_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id      UUID REFERENCES jobs(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status   TEXT NOT NULL,
  changed_at  TIMESTAMPTZ DEFAULT now(),
  changed_by  UUID,   -- operator_id when auth is wired
  notes       TEXT
);
CREATE INDEX idx_job_status_history_job ON job_status_history(job_id);

-- Job photos — photo records (URL + metadata + context)
CREATE TABLE job_photos (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id            UUID REFERENCES jobs(id) ON DELETE CASCADE,
  storage_url       TEXT NOT NULL,
  thumbnail_url     TEXT,
  category          TEXT NOT NULL,  -- assessment | in_progress | completion | damage | document
  status_at_capture TEXT,           -- job status when photo was taken
  caption           TEXT,
  geo_lat           NUMERIC(10,7),
  geo_lon           NUMERIC(10,7),
  taken_at          TIMESTAMPTZ NOT NULL,
  uploaded_at       TIMESTAMPTZ DEFAULT now(),
  uploaded_by       UUID,
  file_size_bytes   INTEGER,
  mime_type         TEXT DEFAULT 'image/jpeg'
);
CREATE INDEX idx_job_photos_job ON job_photos(job_id, taken_at);
CREATE INDEX idx_job_photos_cat ON job_photos(job_id, category);

-- Operator settings — settings store: preferences, feature flags, plan tier
CREATE TABLE operator_settings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id     UUID,  -- will reference operators table when auth is wired

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

  -- Debug sub-flags (only active when debug_enabled is true)
  debug_log_state_changes  BOOLEAN DEFAULT true,
  debug_log_api_calls      BOOLEAN DEFAULT false,
  debug_log_settings_reads BOOLEAN DEFAULT false,
  debug_log_render_cycles  BOOLEAN DEFAULT false,

  -- Tier 3: Plan config
  plan_tier    TEXT DEFAULT 'solo',  -- solo | pro | crew | franchise

  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- ────────────────────────────────────────
-- STEP 3: Seed chart of accounts
-- ────────────────────────────────────────
INSERT INTO accounts (name, type, code, description) VALUES
  -- Assets
  ('Checking Account',       'asset',   '1001', 'Primary business checking account'),
  ('Accounts Receivable',    'asset',   '1002', 'Money owed by customers'),
  -- Income
  ('Revenue — Labor',        'income',  '4001', 'Income from labor charges'),
  ('Revenue — Materials',    'income',  '4002', 'Income from materials markup'),
  -- Expenses
  ('Materials — Home Depot', 'expense', '5001', 'Parts and materials purchased at Home Depot'),
  ('Materials — Lowes',      'expense', '5002', 'Parts and materials purchased at Lowes'),
  ('Materials — Other',      'expense', '5003', 'Parts and materials from other suppliers'),
  ('Vehicle & Fuel',         'expense', '5004', 'Fuel, mileage, and vehicle costs'),
  ('Tools & Equipment',      'expense', '5005', 'Tool purchases and equipment costs'),
  ('Software & Subscriptions','expense','5006', 'Business software and subscription costs'),
  ('Stripe Fees',            'expense', '5007', 'Payment processing fees'),
  ('Marketing',              'expense', '5008', 'Advertising and marketing costs'),
  ('Insurance',              'expense', '5009', 'Business insurance premiums');

-- ────────────────────────────────────────
-- STEP 4: Seed default operator settings row
-- ────────────────────────────────────────
INSERT INTO operator_settings (business_name) VALUES ('Skilled Handyman Services');