import { CreditCardIcon, SettingsIcon, UserCircleIcon } from 'lucide-react';
import Link from 'next/link';
import { PageHeader } from '@/components/layout/page-header';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';

export default async function SettingsPage() {
  const settingsItems = [
    {
      title: 'Profile',
      description: 'Update your personal information and preferences',
      href: '/settings/profile',
      icon: UserCircleIcon,
    },
    {
      title: 'Organization',
      description: 'Manage your organization and team members',
      href: '/settings/organization',
      icon: SettingsIcon,
    },
    {
      title: 'Billing',
      description: 'Manage your subscription and billing information',
      href: '/settings/billing',
      icon: CreditCardIcon,
    },
    {
      title: 'Preferences',
      description: 'Theme, language, and other personal defaults',
      href: '/settings/preferences',
      icon: SettingsIcon,
    },
  ];

  return (
    <>
      <PageHeader
        title='Settings'
        subtitle='Manage your account settings and preferences.'
      />
      <section className='space-y-6 px-4 lg:px-6'>
        <div className='grid auto-rows-fr gap-6 md:grid-cols-2 lg:grid-cols-3'>
          {settingsItems.map((item) => (
            <Link
              key={item.title}
              href={item.href}
              className='flex h-full'>
              <Card className='hover:bg-muted h-full w-full transition-colors'>
                <CardHeader className='flex flex-row items-center gap-2 space-y-0 pb-2 sm:gap-3'>
                  <item.icon className='text-muted-foreground h-5 w-5' />
                  <CardTitle className='text-base'>{item.title}</CardTitle>
                </CardHeader>
                <CardContent className='space-y-4'>
                  <CardDescription className='text-sm'>
                    {item.description}
                  </CardDescription>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    </>
  );
}
