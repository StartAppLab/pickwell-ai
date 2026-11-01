'use server';

import { z } from 'zod';
import { env } from '@/lib/env';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import { emailSchema, validateInput } from '@/lib/validation';

const signupSchema = z.object({
  email: emailSchema,
  password: z.string().min(6),
  confirmPassword: z.string().min(6),
});

export interface SignupState {
  error?: string;
  success?: string;
}

export async function signupAction(
  _: SignupState,
  formData: FormData
): Promise<SignupState> {
  let parsed;
  try {
    parsed = await validateInput(signupSchema, {
      email: formData.get('email'),
      password: formData.get('password'),
      confirmPassword: formData.get('confirmPassword'),
    });
  } catch (error) {
    return {
      error: error instanceof Error ? error.message : 'Invalid submission.',
    };
  }

  if (parsed.password !== parsed.confirmPassword) {
    return { error: 'Passwords do not match.' };
  }

  const supabase = await createSupabaseServerClient({
    allowCookieMutations: true,
  });
  const siteUrl = env.NEXT_PUBLIC_SITE_URL;
  const { error } = await supabase.auth.signUp({
    email: parsed.email,
    password: parsed.password,
    options: {
      emailRedirectTo: `${siteUrl.replace(/\/$/, '')}/auth/callback`,
    },
  });

  if (error) {
    return { error: error.message };
  }

  return { success: 'Check your inbox to confirm your account.' };
}
