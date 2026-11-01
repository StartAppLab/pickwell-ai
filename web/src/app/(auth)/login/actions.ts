'use server';

import { redirect } from 'next/navigation';
import { z } from 'zod';
import { env } from '@/lib/env';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import { emailSchema, validateInput } from '@/lib/validation';

const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(6),
});

export interface LoginState {
  error?: string;
  success?: string;
}

export async function loginAction(
  _: LoginState,
  formData: FormData
): Promise<LoginState> {
  const supabase = await createSupabaseServerClient({
    allowCookieMutations: true,
  });

  let parsed;
  try {
    parsed = await validateInput(loginSchema, {
      email: formData.get('email'),
      password: formData.get('password'),
    });
  } catch (error) {
    return {
      error: error instanceof Error ? error.message : 'Invalid submission.',
    };
  }

  const { error } = await supabase.auth.signInWithPassword({
    email: parsed.email,
    password: parsed.password,
  });

  if (error) {
    return { error: error.message };
  }

  redirect('/dashboard');
}

export async function googleSignInAction() {
  const supabase = await createSupabaseServerClient({
    allowCookieMutations: true,
  });

  try {
    const origin = env.NEXT_PUBLIC_SITE_URL;
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${origin}/auth/callback`,
      },
    });

    if (error) {
      return { error: error.message };
    }

    return { success: true };
  } catch (error) {
    return {
      error:
        error instanceof Error
          ? error.message
          : 'Unable to sign in with Google right now.',
    };
  }
}

export async function appleSignInAction() {
  const supabase = await createSupabaseServerClient({
    allowCookieMutations: true,
  });

  try {
    const origin = env.NEXT_PUBLIC_SITE_URL;
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'apple',
      options: {
        redirectTo: `${origin}/auth/callback`,
      },
    });

    if (error) {
      return { error: error.message };
    }

    return { success: true };
  } catch (error) {
    return {
      error:
        error instanceof Error
          ? error.message
          : 'Unable to sign in with Apple right now.',
    };
  }
}

export async function githubSignInAction() {
  const supabase = await createSupabaseServerClient({
    allowCookieMutations: true,
  });

  try {
    const origin = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000';
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'github',
      options: {
        redirectTo: `${origin}/auth/callback`,
      },
    });

    if (error) {
      return { error: error.message };
    }

    return { success: true };
  } catch (error) {
    return {
      error:
        error instanceof Error
          ? error.message
          : 'Unable to sign in with GitHub right now.',
    };
  }
}
