'use client';

import {
  type ColumnDef,
  type PaginationState,
  type SortingState,
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
} from '@tanstack/react-table';
import * as React from 'react';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { cn } from '@/lib/utils';

export interface DataTableProps<TData> {
  columns: ColumnDef<TData, unknown>[];
  data: TData[];
  pageSize?: number;
  initialSorting?: SortingState;
  className?: string;
  emptyState?: React.ReactNode;
}

export function DataTable<TData>({
  columns,
  data,
  pageSize = 10,
  initialSorting,
  className,
  emptyState,
}: DataTableProps<TData>) {
  const [sorting, setSorting] = React.useState<SortingState>(
    initialSorting ?? []
  );
  const [pagination, setPagination] = React.useState<PaginationState>({
    pageIndex: 0,
    pageSize,
  });

  // eslint-disable-next-line react-hooks/incompatible-library
  const table = useReactTable({
    data,
    columns,
    state: { sorting, pagination },
    onSortingChange: setSorting,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    manualPagination: false,
  });

  const rows = table.getRowModel().rows;

  return (
    <div className={cn('space-y-4', className)}>
      <div className='overflow-x-auto'>
        <table className='w-full min-w-[600px] border-collapse text-left text-sm'>
          <thead>
            {table.getHeaderGroups().map((headerGroup) => (
              <tr
                key={headerGroup.id}
                className='border-border text-muted-foreground border-b text-xs tracking-wide uppercase'>
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className='px-4 py-3 font-medium'>
                    {header.isPlaceholder ? null : (
                      <button
                        type='button'
                        onClick={header.column.getToggleSortingHandler()}
                        className={cn(
                          'flex items-center gap-1',
                          header.column.getCanSort()
                            ? 'cursor-pointer select-none'
                            : 'cursor-default'
                        )}>
                        {flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                        {header.column.getCanSort() ? (
                          <SortIcon
                            direction={
                              header.column.getIsSorted() as SortIndicator
                            }
                          />
                        ) : null}
                      </button>
                    )}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr>
                <td
                  colSpan={columns.length}
                  className='text-muted-foreground px-4 py-6 text-center text-sm'>
                  {emptyState ?? 'No records found.'}
                </td>
              </tr>
            ) : (
              rows.map((row) => (
                <tr
                  key={row.id}
                  className='border-border hover:bg-muted border-b'>
                  {row.getVisibleCells().map((cell) => (
                    <td
                      key={cell.id}
                      className='text-foreground px-4 py-3'>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <Separator />

      <div className='text-muted-foreground flex flex-col items-center justify-between gap-3 text-sm md:flex-row'>
        <div>
          Page {table.getState().pagination.pageIndex + 1} of{' '}
          {table.getPageCount()}
        </div>
        <div className='flex items-center gap-2'>
          <Button
            variant='outline'
            size='sm'
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}>
            Previous
          </Button>
          <Button
            variant='outline'
            size='sm'
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}>
            Next
          </Button>
        </div>
      </div>
    </div>
  );
}

type SortIndicator = false | 'asc' | 'desc';

function SortIcon({ direction }: { direction: SortIndicator }) {
  if (!direction) return null;
  return (
    <span className='text-muted-foreground text-xs'>
      {direction === 'asc' ? '▲' : '▼'}
    </span>
  );
}
