'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from '@/lib/supabase-server';

export async function signOutAction(): Promise<void> {
  try {
    const supabase = await createSupabaseServerClient({
      allowCookieMutations: true,
    });

    // Sign out from Supabase
    const { error } = await supabase.auth.signOut();

    if (error) {
      console.error('Sign out error:', error);
      // Even if there's an error, we should still redirect to clear the session
    }

    // Revalidate all paths to clear any cached data
    revalidatePath('/', 'layout');

    // Redirect to home page
    redirect('/');
  } catch (error) {
    console.error('Sign out action error:', error);
    // Even if there's an error, redirect to home
    redirect('/');
  }
}
