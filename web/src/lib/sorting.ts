export type SortDirection = 'asc' | 'desc';

export function compareValues(
  a: unknown,
  b: unknown,
  direction: SortDirection = 'asc'
): number {
  const multiplier = direction === 'asc' ? 1 : -1;

  if (a === b) return 0;
  if (a === null || a === undefined) return 1 * multiplier;
  if (b === null || b === undefined) return -1 * multiplier;

  if (typeof a === 'number' && typeof b === 'number') {
    return (a - b) * multiplier;
  }

  const aString = String(a).toLowerCase();
  const bString = String(b).toLowerCase();

  if (aString < bString) return -1 * multiplier;
  if (aString > bString) return 1 * multiplier;
  return 0;
}

export function sortBy<T>(
  items: readonly T[],
  selector: (item: T) => unknown,
  direction: SortDirection = 'asc'
): T[] {
  return [...items].sort((a, b) =>
    compareValues(selector(a), selector(b), direction)
  );
}
