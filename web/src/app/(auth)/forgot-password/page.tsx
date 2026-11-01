import { redirect } from 'next/navigation';
import { ForgotPasswordForm } from './forgot-password-form';
import { AppLogo } from '@/components/shared/app-logo';
import { BackButton } from '@/components/shared/back-button';
import { getAuthState } from '@/lib/auth';

export default async function ForgotPasswordPage() {
  const { user } = await getAuthState();
  if (user) {
    redirect('/dashboard');
  }

  return (
    <div className='bg-muted flex min-h-svh flex-col items-center justify-center gap-6 p-6 md:p-10'>
      <div className='flex w-full max-w-sm flex-col gap-6'>
        <BackButton
          href='/login'
          className='self-start'
        />
        <AppLogo className='self-center' />
        <ForgotPasswordForm />
      </div>
    </div>
  );
}
