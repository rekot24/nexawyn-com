/**
 * constants/index.js
 * 
 * Single source of truth for all named values in the app.
 * No magic numbers or magic strings anywhere else.
 * If a value might need to change, it lives here with a comment explaining it.
 */

// ─── Quote & follow-up timing ───────────────────────────────────────────────

/** Hours after quote is sent before first automated follow-up SMS fires */
export const QUOTE_FOLLOWUP_HOURS = 24

/** Hours after quote is sent before operator gets an alert (no response) */
export const QUOTE_ALERT_HOURS = 48

/** Hours a quote can sit in 'quote_in_progress' before operator is nudged */
export const QUOTE_STALE_HOURS = 2

// ─── Invoice formatting ──────────────────────────────────────────────────────

/** Prefix for all invoice numbers — NXW-2026-0001 */
export const INVOICE_PREFIX = 'NXW'

// ─── Job defaults ────────────────────────────────────────────────────────────

/** Default labor rate in dollars per hour */
export const DEFAULT_LABOR_RATE = 75.00

/** Default markup on materials as a decimal (0.20 = 20%) */
export const DEFAULT_MARKUP = 0.20

// ─── Plan tiers ──────────────────────────────────────────────────────────────

/** All valid plan tier values — must match operator_settings.plan_tier in Supabase */
export const PLAN_TIERS = {
  SOLO:      'solo',
  PRO:       'pro',
  CREW:      'crew',
  FRANCHISE: 'franchise',
}

// ─── Photo categories ────────────────────────────────────────────────────────

/** Valid values for job_photos.category — must match database constraint */
export const PHOTO_CATEGORIES = {
  ASSESSMENT:  'assessment',
  IN_PROGRESS: 'in_progress',
  COMPLETION:  'completion',
  DAMAGE:      'damage',
  DOCUMENT:    'document',
}

// ─── UI timing ───────────────────────────────────────────────────────────────

/** Milliseconds before a toast notification auto-dismisses */
export const TOAST_DURATION_MS = 4000

/** Milliseconds to debounce search input before firing a query */
export const SEARCH_DEBOUNCE_MS = 300