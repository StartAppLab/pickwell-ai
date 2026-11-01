'use client';

import { type SupabaseClient, createClient } from '@supabase/supabase-js';
import { supabaseAnonKey, supabaseUrl } from '@/lib/supabase-config';
import type { Database } from '@/types/database';

let browserClient: SupabaseClient<Database, 'public'> | null = null;

export function createSupabaseBrowserClient(): SupabaseClient<
  Database,
  'public'
> {
  if (!browserClient) {
    browserClient = createClient<Database>(supabaseUrl, supabaseAnonKey, {
      auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true,
      },
    });
  }

  return browserClient;
}
