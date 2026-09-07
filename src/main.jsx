/**
 * main.jsx
 *
 * App entry point. Wires the root providers and mounts the app.
 * Order matters: ErrorBoundary wraps everything so no crash escapes.
 * SettingsProvider loads settings before any feature component renders.
 */

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { SettingsProvider } from './context/SettingsContext'
import { ErrorBoundary } from './components/ErrorBoundary'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ErrorBoundary>
      <SettingsProvider>
        <App />
      </SettingsProvider>
    </ErrorBoundary>
  </StrictMode>,
)