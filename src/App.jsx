import { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'

function App() {
  const [connected, setConnected] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    async function testConnection() {
      const { data, error } = await supabase.from('customers').select('count')
      if (error) {
        setError(error.message)
      } else {
        setConnected(true)
      }
    }
    testConnection()
  }, [])

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Nexawyn</h1>
      {connected && <p style={{ color: 'green' }}>✅ Supabase connected</p>}
      {error && <p style={{ color: 'red' }}>❌ {error}</p>}
      {!connected && !error && <p>Connecting...</p>}
    </div>
  )
}

export default App