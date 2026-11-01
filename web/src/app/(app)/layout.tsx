import type { Metadata } from 'next';
import { AppSidebar } from '@/components/layout/app-sidebar';
import { SiteHeader } from '@/components/layout/site-header';
import { SidebarInset, SidebarProvider } from '@/components/ui/sidebar';
import { OrgProvider } from '@/features/orgs/lib/org-context';
import { loadOrgContext } from '@/features/orgs/server/actions';
import { requireAuthState } from '@/lib/auth';

export const metadata: Metadata = {
  title: 'Dashboard • StartAppLab',
};

export const dynamic = 'force-dynamic';

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const auth = await requireAuthState('/login');
  const orgContext = await loadOrgContext();

  const name = auth.profile?.first_name || auth.user?.email || 'User';
  const user = {
    name: name,
    email: auth.user?.email || 'user@example.com',
    ...(auth.profile?.avatar_url && { avatar: auth.profile.avatar_url }),
  };

  return (
    <OrgProvider
      initialOrganizations={orgContext.organizations}
      initialActiveOrgId={orgContext.activeOrgId}
      initialDefaultOrgId={orgContext.defaultOrgId}>
      <SidebarProvider
        style={
          {
            '--sidebar-width': 'calc(var(--spacing) * 72)',
            '--header-height': 'calc(var(--spacing) * 12)',
          } as React.CSSProperties
        }>
        <AppSidebar
          variant='inset'
          user={user}
        />
        <SidebarInset>
          <SiteHeader />
          <div className='flex flex-1 flex-col'>
            <div className='@container/main flex flex-1 flex-col gap-2'>
              <div className='flex flex-col gap-4 py-4 md:gap-6 md:py-6'>
                {children}
              </div>
            </div>
          </div>
        </SidebarInset>
      </SidebarProvider>
    </OrgProvider>
  );
}
