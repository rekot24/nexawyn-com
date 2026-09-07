/**
 * lib/logger.js
 *
 * Unified logging layer. All debug output and persistent logging goes
 * through here — never raw console.log anywhere in the app.
 *
 * Two responsibilities:
 *   1. Debug output  — controlled by debug_enabled in operator_settings.
 *                      Visible in the browser console while you're watching.
 *   2. Persistent log — writes to Supabase app_logs table (when wired).
 *                      Available after the fact, even when you weren't watching.
 *
 * Log levels: debug | info | warning | error
 *   debug   — low-level detail, dev only, never in production
 *   info    — normal significant events (job status changed, quote sent)
 *   warning — something unexpected but recoverable
 *   error   — something failed; needs attention
 */

import { supabase } from './supabase'

/** @type {boolean} Set by SettingsContext once settings are loaded */
let debugEnabled = false

/**
 * Called by SettingsContext after settings load.
 * Allows the logger to respect the debug_enabled flag.
 * @param {boolean} enabled
 */
export function setDebugEnabled(enabled) {
  debugEnabled = enabled
}

/**
 * Core log function. All other methods call this.
 * @param {'debug'|'info'|'warning'|'error'} level
 * @param {string} module - which part of the app this came from (e.g. 'jobs', 'auth')
 * @param {string} message
 * @param {Object} [meta] - optional additional context
 */
function log(level, module, message, meta = {}) {
  // Debug output — only shown when debug_enabled is true
  if (level === 'debug' && !debugEnabled) return

  const entry = {
    level,
    module,
    message,
    meta,
    timestamp: new Date().toISOString(),
  }

  // Always output errors and warnings to console regardless of debug flag
  if (level === 'error') {
    console.error(`[${module}] ${message}`, meta)
  } else if (level === 'warning') {
    console.warn(`[${module}] ${message}`, meta)
  } else if (debugEnabled) {
    console.log(`[${level.toUpperCase()}][${module}] ${message}`, meta)
  }

  // Persistent logging to Supabase — info level and above
  // Skips debug entries (too noisy to store) and runs async (fire and forget)
  if (level !== 'debug') {
    supabase
      .from('app_logs')
      .insert(entry)
      .then(({ error }) => {
        // If the log insert itself fails, output to console only — never throw
        if (error && debugEnabled) {
          console.warn('[logger] Failed to persist log entry:', error.message)
        }
      })
  }
}

/**
 * Low-level detail. Only visible when debug_enabled is true.
 * Use for state changes, render cycles, settings reads.
 * @param {string} module
 * @param {string} message
 * @param {Object} [meta]
 */
export function debug(module, message, meta) {
  log('debug', module, message, meta)
}

/**
 * Normal significant events. Always persisted to Supabase.
 * Use for: job status changed, quote sent, invoice paid.
 * @param {string} module
 * @param {string} message
 * @param {Object} [meta]
 */
export function info(module, message, meta) {
  log('info', module, message, meta)
}

/**
 * Unexpected but recoverable. Always persisted.
 * Use for: RLS blocked a query, unexpected null from join.
 * @param {string} module
 * @param {string} message
 * @param {Object} [meta]
 */
export function warning(module, message, meta) {
  log('warning', module, message, meta)
}

/**
 * Something failed. Always persisted. Always visible in console.
 * Use for: Supabase call failed, auth check failed, unhandled exception.
 * @param {string} module
 * @param {string} message
 * @param {Object} [meta]
 */
export function error(module, message, meta) {
  log('error', module, message, meta)
}

export default { debug, info, warning, error, setDebugEnabled }