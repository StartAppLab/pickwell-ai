import { createClient } from '@supabase/supabase-js';

// Retrieve Supabase config from environment variables
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

// Validate required configuration values
if (!supabaseUrl || !supabaseAnonKey) {
  const missingKeys = [];
  if (!supabaseUrl) missingKeys.push('PUBLIC_SUPABASE_URL');
  if (!supabaseAnonKey) missingKeys.push('PUBLIC_SUPABASE_ANON_KEY');

  throw new Error(
    `Missing Supabase environment variables: ${missingKeys.join(', ')}`
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
