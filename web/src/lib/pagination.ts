export interface PaginationMeta {
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export function createPaginationMeta(
  total: number,
  page: number,
  perPage: number
): PaginationMeta {
  const safePerPage = Math.max(perPage, 1);
  const totalPages = Math.max(Math.ceil(total / safePerPage), 1);
  const currentPage = Math.min(Math.max(page, 1), totalPages);

  return {
    total,
    page: currentPage,
    perPage: safePerPage,
    totalPages,
    hasNext: currentPage < totalPages,
    hasPrevious: currentPage > 1,
  };
}

export function paginate<T>(
  items: readonly T[],
  page: number,
  perPage: number
): { data: T[]; meta: PaginationMeta } {
  const meta = createPaginationMeta(items.length, page, perPage);
  const start = (meta.page - 1) * meta.perPage;
  const end = start + meta.perPage;
  return {
    data: items.slice(start, end),
    meta,
  };
}
