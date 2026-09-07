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

export const SettingsContext = createContext(null)

export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState(null)
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState(null)

  useEffect(() => {
    fetchSettings()
  }, [])

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
      console.log('Settings loaded:', data)
    } catch (err) {
      setError(err.message)
      console.error('SETTINGS FETCH FAILED:', err)
    } finally {
      setLoading(false)
    }
  }

  async function updateSetting(key, value) {
    if (!settings?.id) return
    try {
      const { error: sbError } = await supabase
        .from('operator_settings')
        .update({ [key]: value, updated_at: new Date().toISOString() })
        .eq('id', settings.id)

      if (sbError) throw sbError
      setSettings(prev => ({ ...prev, [key]: value }))
    } catch (err) {
      setError(err.message)
      console.error('SETTINGS UPDATE FAILED:', err)
    }
  }

  return (
    <SettingsContext.Provider value={{ settings, loading, error, updateSetting }}>
      {children}
    </SettingsContext.Provider>
  )
}