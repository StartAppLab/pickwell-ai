import { PageHeader } from '@/components/layout/page-header';
import { ChartAreaInteractive } from '@/features/dashboard/components/chart-area-interactive';
import { DataTable } from '@/features/dashboard/components/dashboard-table';
import { SectionCards } from '@/features/dashboard/components/section-cards';
import { requireAuthState } from '@/lib/auth';

export default async function AppHomePage() {
  const auth = await requireAuthState('/login');

  const name = auth.profile?.first_name || auth.user?.email || 'User';

  return (
    <>
      <PageHeader
        title={`Welcome back, ${name}!`}
        subtitle='Here’s what’s happening with your dashboard today.'
      />
      <SectionCards />
      <div className='px-4 lg:px-6'>
        <ChartAreaInteractive />
      </div>
      <DataTable data={[]} />
    </>
  );
}
