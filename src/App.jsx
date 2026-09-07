/**
 * App.jsx
 *
 * Root application component.
 * Temporary connection test — will be replaced with routing and layout
 * once the Phase 2 feature build begins.
 */

import { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'
import { useSettings } from './hooks/useSettings'
import * as logger from './lib/logger'

/**
 * App — root component, currently showing connection status.
 * @returns {JSX.Element}
 */
function App() {
  const { settings, loading: settingsLoading } = useSettings()
  const [dbConnected, setDbConnected] = useState(false)
  const [loading, setLoading]         = useState(true)
  const [error, setError]             = useState(null)

  useEffect(() => {
    testConnection()
  }, [])

  /**
   * Verifies the Supabase connection by querying the customers table.
   * Temporary — removed once real views are built.
   */
  async function testConnection() {
    setLoading(true)
    setError(null)
    try {
      const { error: sbError } = await supabase
        .from('customers')
        .select('count')

      if (sbError) throw sbError

      setDbConnected(true)
      logger.info('app', 'Supabase connection verified')
    } catch (err) {
      setError(err.message)
      logger.error('app', 'Supabase connection failed', { message: err.message })
    } finally {
      setLoading(false)
    }
  }

  if (settingsLoading) return <p style={{ padding: '2rem' }}>Loading settings...</p>

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Nexawyn</h1>
      <p>Business: {settings?.business_name ?? '—'}</p>
      <p>Plan: {settings?.plan_tier ?? '—'}</p>
      {loading     && <p>Checking database connection...</p>}
      {dbConnected && <p style={{ color: 'green' }}>✅ Supabase connected</p>}
      {error       && <p style={{ color: 'red' }}>❌ {error}</p>}
    </div>
  )
}

export default App