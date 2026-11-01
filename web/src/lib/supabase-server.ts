import { createServerClient } from '@supabase/ssr';
import type { SupabaseClient } from '@supabase/supabase-js';
import { cookies } from 'next/headers';
import { supabaseAnonKey, supabaseUrl } from '@/lib/supabase-config';
import type { Database } from '@/types/database';

export type SupabaseServerClient = SupabaseClient<Database, 'public'>;
export type SupabaseServiceClient = SupabaseClient<Database, 'public'>;

interface ServerClientOptions {
  allowCookieMutations?: boolean;
}

export async function createSupabaseServerClient(
  options: ServerClientOptions = {}
): Promise<SupabaseServerClient> {
  const { allowCookieMutations = false } = options;
  const cookieStore = await cookies();

  return createServerClient<Database, 'public'>(supabaseUrl, supabaseAnonKey, {
    cookies: {
      get(name) {
        try {
          return cookieStore.get(name)?.value;
        } catch (error) {
          console.error('Cookie get error:', error);
          return undefined;
        }
      },
      set(name, value, options) {
        if (!allowCookieMutations) return;
        try {
          cookieStore.set({ name, value, ...options });
        } catch (error) {
          console.error('Cookie set error:', error);
        }
      },
      remove(name, options) {
        if (!allowCookieMutations) return;
        try {
          cookieStore.delete({ name, ...options });
        } catch (error) {
          console.error('Cookie delete error:', error);
        }
      },
    },
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  });
}

export function createSupabaseServiceRoleClient(): SupabaseServiceClient {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY has been removed.');
}

export function createSupabaseAdminClient(): SupabaseServiceClient {
  return createSupabaseServiceRoleClient();
}
