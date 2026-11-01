import { User, Shield, Mail } from 'lucide-react';
import { ProfileForm } from './profile-form';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { requireAuthState } from '@/lib/auth';

export default async function ProfileSettingsPage() {
  const { profile, user } = await requireAuthState('/login');

  return (
    <>
      <PageHeader
        title='Profile'
        subtitle='Manage your personal information and account security settings.'
        backHref='/settings'
      />
      <section className='grid gap-6 px-4 pb-12 lg:px-6'>
        {/* Personal Information Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <User className='text-primary h-4 w-4' />
              <CardTitle>Personal Information</CardTitle>
            </div>
            <CardDescription>
              Update your personal details. This information will be visible to
              your team members.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ProfileForm
              initialValues={{
                first_name: profile?.first_name ?? null,
                last_name: profile?.last_name ?? null,
                phone: profile?.phone ?? null,
                role: profile?.role ?? null,
              }}
            />
          </CardContent>
        </Card>

        {/* Account Details Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <Shield className='text-primary h-4 w-4' />
              <CardTitle>Account Details</CardTitle>
            </div>
            <CardDescription>
              Your login credentials and account status.
            </CardDescription>
          </CardHeader>
          <CardContent className='space-y-6'>
            <div className='flex flex-col gap-4 border-b pb-4 sm:flex-row sm:items-center sm:justify-between'>
              <div className='space-y-0.5'>
                <div className='flex items-center gap-2 text-sm font-medium'>
                  <Mail className='text-muted-foreground h-4 w-4' />
                  <span>Email Address</span>
                </div>
                <p className='text-muted-foreground text-sm'>
                  Used for sign-in and system notifications.
                </p>
              </div>
              <p className='bg-muted rounded px-2 py-1 font-mono text-sm'>
                {user.email}
              </p>
            </div>

            <div className='flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between'>
              <div className='space-y-0.5'>
                <div className='flex items-center gap-2 text-sm font-medium'>
                  <Shield className='text-muted-foreground h-4 w-4' />
                  <span>Account Security</span>
                </div>
                <p className='text-muted-foreground text-sm'>
                  Manage your password and two-factor authentication.
                </p>
              </div>
              <Button
                variant='outline'
                size='sm'
                disabled>
                Changing Soon
              </Button>
            </div>
          </CardContent>
        </Card>
      </section>
    </>
  );
}
