import { z } from 'zod';

/**
 * Validates environment variables at runtime.
 * This ensures that the application doesn't start with missing or invalid configuration.
 *
 * Client-side variables must be prefixed with NEXT_PUBLIC_.
 */
const envSchema = z.object({
  // --- Public / Client-side ---
  NEXT_PUBLIC_SUPABASE_URL: z.string().url({
    message: 'NEXT_PUBLIC_SUPABASE_URL must be a valid URL',
  }),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1, {
    message: 'NEXT_PUBLIC_SUPABASE_ANON_KEY is required',
  }),
  NEXT_PUBLIC_SITE_URL: z.string().url().default('http://localhost:3000'),
});

const processEnv = {
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
};

// Validates all variables (since we only have public ones now, we can validate everywhere)
const parsed = envSchema.safeParse(processEnv);

if (!parsed.success) {
  const errors = parsed.error.flatten().fieldErrors;
  const errorMsg = Object.entries(errors)
    .map(([key, val]) => `${key}: ${val?.join(', ')}`)
    .join('\n');

  console.error('❌ Invalid environment variables:\n', errorMsg);

  // In production, we might want to fail the build or crash the process
  // In development, we show a clear error
  if (process.env.NODE_ENV === 'production' && typeof window === 'undefined') {
    throw new Error(`Invalid environment variables:\n${errorMsg}`);
  }
}

export const env = (parsed.success ? parsed.data : processEnv) as z.infer<
  typeof envSchema
>;
