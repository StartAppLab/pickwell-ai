import { z } from 'zod';

export const uuidSchema = z.string().uuid({ message: 'Expected valid UUID' });
export const slugSchema = z
  .string()
  .min(3)
  .max(64)
  .refine(
    (val) => {
      // Must start and end with alphanumeric
      if (!/^[a-z0-9]/.test(val) || !/[a-z0-9]$/.test(val)) return false;
      // Only contains lowercase letters, numbers, and hyphens
      for (const char of val) {
        if (!/[a-z0-9-]/.test(char)) return false;
      }
      // No consecutive hyphens
      if (val.includes('--')) return false;
      return true;
    },
    {
      message: 'Use lowercase letters, numbers, and hyphens.',
    }
  );
export const emailSchema = z.string().email();

export type Validated<TSchema extends z.ZodTypeAny> = z.infer<TSchema>;

export async function validateInput<TSchema extends z.ZodTypeAny>(
  schema: TSchema,
  input: unknown
): Promise<Validated<TSchema>> {
  const result = await schema.safeParseAsync(input);
  if (!result.success) {
    throw new Error(
      result.error.issues.map((issue) => issue.message).join(', ')
    );
  }
  return result.data;
}
