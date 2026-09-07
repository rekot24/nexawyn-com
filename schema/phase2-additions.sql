-- ============================================================
-- Nexawyn — Phase 2 Schema Additions
-- New tables: users, user_roles, schedule_events
-- Run AFTER phase1-core-v2.sql is already in place.
-- September 7, 2026
-- ============================================================

-- Users — operator and technician accounts
-- Linked to Supabase Auth via auth_id (Supabase Auth UUID)
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id     UUID UNIQUE,          -- Supabase Auth user ID (wired when auth is live)
  full_name   TEXT NOT NULL,
  email       TEXT UNIQUE,
  phone       TEXT,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- User roles — role assignments per user
-- A user can have one role. Roles: owner | admin | technician
CREATE TABLE user_roles (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  role       TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'technician')),
  assigned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id)  -- one role per user for now; extend to multi-role later if needed
);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);

-- Schedule events — time blocks that point to a job
-- Many events can reference one job (solves the multi-day job problem)
-- Billing value lives on the job — never here
CREATE TABLE schedule_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id        UUID REFERENCES jobs(id) ON DELETE CASCADE,
  assigned_to   UUID REFERENCES users(id) ON DELETE SET NULL,
  starts_at     TIMESTAMPTZ NOT NULL,
  ends_at       TIMESTAMPTZ,
  notes         TEXT,           -- day-specific notes (different from job notes)
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_schedule_events_job      ON schedule_events(job_id);
CREATE INDEX idx_schedule_events_assigned ON schedule_events(assigned_to);
CREATE INDEX idx_schedule_events_starts   ON schedule_events(starts_at);

-- Wire operator_settings.operator_id to users now that the table exists
ALTER TABLE operator_settings
  ADD CONSTRAINT fk_operator_settings_user
  FOREIGN KEY (operator_id) REFERENCES users(id) ON DELETE CASCADE;

-- Wire job_status_history.changed_by to users
ALTER TABLE job_status_history
  ADD CONSTRAINT fk_job_status_history_user
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL;

-- Wire job_photos.uploaded_by to users
ALTER TABLE job_photos
  ADD CONSTRAINT fk_job_photos_user
  FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL;

-- Seed the owner user for Joshua (auth_id wired later when Supabase Auth is live)
INSERT INTO users (full_name, email) 
  VALUES ('Joshua', 'joshua@skilledhandymanservices.com');

INSERT INTO user_roles (user_id, role)
  SELECT id, 'owner' FROM users WHERE email = 'joshua@skilledhandymanservices.com';

-- Grant access to new tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;

-- On My Way feature settings
ALTER TABLE operator_settings
  ADD COLUMN on_my_way_enabled       BOOLEAN DEFAULT true,
  ADD COLUMN on_my_way_open_maps     BOOLEAN DEFAULT true,
  ADD COLUMN on_my_way_include_eta   BOOLEAN DEFAULT true,
  ADD COLUMN on_my_way_sms_template  TEXT DEFAULT 'Hi {customer_name}, I''m on my way! See you in about {eta}. — Joshua';

-- Material buy list feature settings
ALTER TABLE operator_settings
  ADD COLUMN local_hd_store_id TEXT;

-- Job flow completion review request feature settings
ALTER TABLE operator_settings
  ADD COLUMN review_request_enabled      BOOLEAN DEFAULT true,
  ADD COLUMN review_request_delay_hrs    INTEGER DEFAULT 1,
  ADD COLUMN review_request_sms_template TEXT,
  ADD COLUMN google_review_url           TEXT;