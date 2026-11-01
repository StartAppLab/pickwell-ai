import { redirect } from 'next/navigation';
import { LoginForm } from './login-form';
import { LoginShowcase } from './login-showcase';
import { AppLogo } from '@/components/shared/app-logo';
import { ThemeToggle } from '@/components/shared/theme-toggle';
import { getAuthState } from '@/lib/auth';

export const dynamic = 'force-dynamic';

type LoginPageSearchParams =
  | Promise<Record<string, string | string[] | undefined>>
  | Record<string, string | string[] | undefined>;

export default async function LoginPage({
  searchParams,
}: {
  searchParams?: LoginPageSearchParams;
}) {
  const { user } = await getAuthState();
  if (user) {
    redirect('/dashboard');
  }

  const resolvedSearchParams = searchParams ? await searchParams : {};
  const errorParam = resolvedSearchParams?.error;
  const initialError = Array.isArray(errorParam) ? errorParam[0] : errorParam;

  return (
    <div className='bg-muted grid min-h-screen grid-cols-1 lg:grid-cols-2'>
      <div className='hidden overflow-hidden lg:flex'>
        <LoginShowcase />
      </div>
      <div className='relative flex items-center justify-center p-6'>
        {/* Theme Toggle */}
        <div className='absolute top-6 right-6'>
          <ThemeToggle />
        </div>

        <div className='w-full max-w-sm'>
          <div className='flex flex-col gap-6'>
            <AppLogo className='self-center' />
            <LoginForm initialError={initialError ?? null} />
          </div>
        </div>
      </div>
    </div>
  );
}
