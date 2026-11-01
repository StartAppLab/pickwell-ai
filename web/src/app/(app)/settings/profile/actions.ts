'use server';

import type { SupabaseClient } from '@supabase/supabase-js';
import { z } from 'zod';
import { requireAuthState } from '@/lib/auth';
import { insertAuditLog } from '@/lib/db';
import { createSupabaseServerClient } from '@/lib/supabase-server';

const profileSchema = z.object({
  first_name: z.string().max(120).nullable().optional(),
  last_name: z.string().max(120).nullable().optional(),
  phone: z.string().max(30).nullable().optional(),
  role: z.string().max(60).nullable().optional(),
});

export interface ProfileState {
  error?: string;
  success?: string;
}

export async function updateProfileAction(
  _: ProfileState,
  formData: FormData
): Promise<ProfileState> {
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const parsed = profileSchema.parse({
    first_name: formData.get('first_name')?.toString().trim() || null,
    last_name: formData.get('last_name')?.toString().trim() || null,
    phone: formData.get('phone')?.toString().trim() || null,
    role: formData.get('role')?.toString().trim() || null,
  });

  const { error } = await (supabase as SupabaseClient)
    .from('profiles')
    .update({
      first_name: parsed.first_name ?? null,
      last_name: parsed.last_name ?? null,
      phone: parsed.phone ?? null,
      role: parsed.role ?? null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', user.id);

  if (error) {
    return { error: error.message };
  }

  await insertAuditLog(supabase, {
    userId: user.id,
    action: 'profile.updated',
  });

  return { success: 'Profile updated.' };
}
