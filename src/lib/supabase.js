import { createClient } from '@supabase/supabase-js'

// Supabase credentials are loaded from environment variables.
// Never hardcode these — add them to .env.local (never committed).
// Required: VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY
// Find them in your Supabase project under Settings → API.
const supabaseUrl     = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. ' +
    'Ensure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are set in .env.local'
  )
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)