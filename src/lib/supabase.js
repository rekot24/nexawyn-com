import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://oafdugxjshzwxleismwc.supabase.co/'
const supabaseAnonKey = 'sb_publishable_R34o-J1_Fu4hWn-UhBBOXA_M-iF6beP'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)