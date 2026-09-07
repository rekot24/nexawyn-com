/**
 * hooks/useSettings.js
 *
 * Reads operator settings from SettingsContext.
 * Use this hook in any component that needs access to settings or
 * needs to update a setting. Never read from Supabase directly in a component.
 *
 * @returns {{
 *   settings: Object|null,
 *   loading: boolean,
 *   error: string|null,
 *   updateSetting: (key: string, value: any) => Promise<void>
 * }}
 */

import { useContext } from 'react'
import { SettingsContext } from '../context/SettingsContext'

export function useSettings() {
  const context = useContext(SettingsContext)

  if (!context) {
    throw new Error(
      'useSettings must be used inside SettingsProvider. ' +
      'Ensure SettingsProvider wraps the app root in main.jsx.'
    )
  }

  return context
}