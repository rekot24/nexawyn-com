/**
 * context/SettingsContext.jsx
 *
 * Loads operator settings from Supabase once on app start.
 * Makes settings available to every component without prop drilling.
 * Also wires the logger's debug flag once settings are known.
 *
 * Wrap the app root with <SettingsProvider> in main.jsx.
 * Read settings in any component via useSettings().
 */

import { createContext, useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { setDebugEnabled } from '../lib/logger'
import * as logger from '../lib/logger'

export const SettingsContext = createContext(null)

/**
 * SettingsProvider — fetches operator settings and holds them in context.
 * @param {{ children: React.ReactNode }} props
 */
export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState(null)
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState(null)

  useEffect(() => {
    fetchSettings()
  }, [])

  /**
   * Loads the operator settings row from Supabase.
   * Expects exactly one row (the dev default row seeded at schema build time).
   * When auth is wired, this will filter by operator_id.
   */
  async function fetchSettings() {
    setLoading(true)
    setError(null)
    try {
      const { data, error: sbError } = await supabase
        .from('operator_settings')
        .select('*')
        .limit(1)
        .single()

      if (sbError) throw sbError

      setSettings(data)

      // Wire the logger's debug flag now that settings are loaded
      setDebugEnabled(data.debug_enabled ?? false)

      logger.info('settings', 'Operator settings loaded', { plan_tier: data.plan_tier })
    } catch (err) {
      setError(err.message)
      logger.error('settings', 'Failed to load operator settings', { message: err.message })
    } finally {
      setLoading(false)
    }
  }

  /**
   * Updates a single setting in Supabase and refreshes local state.
   * @param {string} key - column name in operator_settings
   * @param {any} value
   */
  async function updateSetting(key, value) {
    if (!settings?.id) return
    setError(null)
    try {
      const { error: sbError } = await supabase
        .from('operator_settings')
        .update({ [key]: value, updated_at: new Date().toISOString() })
        .eq('id', settings.id)

      if (sbError) throw sbError

      // Update local state immediately — no refetch needed
      setSettings(prev => ({ ...prev, [key]: value }))

      // Re-wire debug flag if it was the one that changed
      if (key === 'debug_enabled') setDebugEnabled(value)

      logger.info('settings', `Setting updated: ${key}`, { key, value })
    } catch (err) {
      setError(err.message)
      logger.error('settings', `Failed to update setting: ${key}`, { message: err.message })
    }
  }

  return (
    <SettingsContext.Provider value={{ settings, loading, error, updateSetting }}>
      {children}
    </SettingsContext.Provider>
  )
}