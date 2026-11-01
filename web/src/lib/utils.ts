import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

export function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function slugify(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)+/g, '');
}

export function formatDate(
  iso: string | null | undefined,
  fallback = '—'
): string {
  if (!iso) return fallback;
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return fallback;
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

export function assertUnreachable(value: never): never {
  throw new Error(`Unhandled value: ${String(value)}`);
}

export function toNumber(value: string | number, defaultValue = 0): number {
  if (typeof value === 'number')
    return Number.isNaN(value) ? defaultValue : value;
  const parsed = Number.parseFloat(value);
  return Number.isNaN(parsed) ? defaultValue : parsed;
}

export function nullable<T>(value: T | null | undefined): T | null {
  return value ?? null;
}
