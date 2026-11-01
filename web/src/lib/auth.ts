import type { Session, User } from '@supabase/supabase-js';
import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import type { Database } from '@/types/database';

export type Profile = Database['public']['Tables']['profiles']['Row'];

export interface AuthState {
  session: Session | null;
  user: User | null;
  profile: Profile | null;
}

export type AuthStateType = AuthState & {
  session: Session;
  user: User;
  profile: Profile | null;
};

export async function getAuthState(): Promise<AuthState> {
  try {
    const supabase = await createSupabaseServerClient();

    // First check if there's a session to avoid "Auth session missing" error
    const { data: sessionData, error: sessionError } =
      await supabase.auth.getSession();

    if (sessionError || !sessionData.session) {
      return { session: null, user: null, profile: null };
    }

    const session = sessionData.session;

    // Verify the user is still valid by calling getUser()
    const { data: userData, error: userError } = await supabase.auth.getUser();

    if (userError || !userData.user) {
      return { session: null, user: null, profile: null };
    }

    // Only fetch profile if we have a valid user
    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userData.user.id)
      .maybeSingle();

    return {
      session,
      user: userData.user,
      profile: profile ?? null,
    };
  } catch (error) {
    console.error('Auth state error:', error);
    return { session: null, user: null, profile: null };
  }
}

export async function requireAuthState(
  redirectTo = '/'
): Promise<
  AuthState & { session: Session; user: User; profile: Profile | null }
> {
  const state = await getAuthState();
  if (!state.user || !state.session) {
    redirect(redirectTo);
  }
  return state as AuthStateType;
}
