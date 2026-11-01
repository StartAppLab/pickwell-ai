'use server';

import { z } from 'zod';
import { env } from '@/lib/env';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import { emailSchema, validateInput } from '@/lib/validation';

const schema = z.object({ email: emailSchema });

export interface ForgotPasswordState {
  error?: string;
  success?: string;
}

export async function requestResetAction(
  _: ForgotPasswordState,
  formData: FormData
): Promise<ForgotPasswordState> {
  let parsed;
  try {
    parsed = await validateInput(schema, { email: formData.get('email') });
  } catch (error) {
    return {
      error: error instanceof Error ? error.message : 'Invalid submission.',
    };
  }

  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.resetPasswordForEmail(parsed.email, {
    redirectTo: `${env.NEXT_PUBLIC_SITE_URL}/dashboard`,
  });

  if (error) {
    return { error: error.message };
  }

  return { success: 'Check your inbox for password reset instructions.' };
}
