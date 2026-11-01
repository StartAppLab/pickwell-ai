'use client';

import { ChevronsUpDown, Plus } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useOrgContext } from '@/features/orgs/lib/org-context';

export function OrgSwitcher() {
  const { organizations, activeOrgId, setActiveOrg } = useOrgContext();
  const activeOrg = organizations.find((org) => org.id === activeOrgId);

  if (organizations.length === 0) {
    return (
      <Button
        variant='outline'
        size='sm'
        asChild>
        <Link href='/settings/organization'>Create organization</Link>
      </Button>
    );
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant='outline'
          size='sm'
          className='min-w-[180px] justify-between'
          data-testid='org-switcher-trigger'>
          <span className='truncate text-left'>
            {activeOrg?.name ?? 'Select organization'}
          </span>
          <ChevronsUpDown
            className='text-muted-foreground h-4 w-4'
            aria-hidden
          />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        align='start'
        className='w-64'>
        <DropdownMenuLabel>Organizations</DropdownMenuLabel>
        <DropdownMenuSeparator />
        {organizations.map((org) => (
          <DropdownMenuItem
            key={org.id}
            onSelect={() => setActiveOrg(org.id)}>
            <div className='flex flex-col'>
              <span className='text-foreground text-sm font-medium'>
                {org.name}
              </span>
              {org.slug ? (
                <span className='text-muted-foreground text-xs'>
                  {org.slug}
                </span>
              ) : null}
            </div>
          </DropdownMenuItem>
        ))}
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link
            href='/settings/organization'
            className='flex items-center gap-2'>
            <Plus className='h-4 w-4' />
            Manage organizations
          </Link>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
