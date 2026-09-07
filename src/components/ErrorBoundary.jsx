/**
 * components/ErrorBoundary.jsx
 *
 * React Error Boundary — wraps the app root and catches any unhandled
 * component errors before they crash the whole page.
 *
 * Must be a class component — React requires it for error boundaries.
 * Displays a fallback UI instead of a blank screen.
 */

import { Component } from 'react'
import * as logger from '../lib/logger'

export class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, errorMessage: '' }
  }

  static getDerivedStateFromError(err) {
    return { hasError: true, errorMessage: err.message }
  }

  componentDidCatch(err, info) {
    // Log to Supabase so we know about crashes even when we weren't watching
    logger.error('ErrorBoundary', err.message, {
      stack: err.stack,
      componentStack: info.componentStack,
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
          <h2>Something went wrong.</h2>
          <p style={{ color: '#666' }}>
            The app ran into an unexpected error. Reload the page to try again.
          </p>
          {/* Show error detail in dev — in production this will be suppressed by debug flag */}
          <pre style={{ fontSize: '0.8rem', color: '#999', marginTop: '1rem' }}>
            {this.state.errorMessage}
          </pre>
          <button
            onClick={() => window.location.reload()}
            style={{ marginTop: '1rem', padding: '0.5rem 1rem', cursor: 'pointer' }}
          >
            Reload
          </button>
        </div>
      )
    }

    return this.props.children
  }
}