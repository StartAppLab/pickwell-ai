import { Languages, Palette, Globe } from 'lucide-react';
import { PageHeader } from '@/components/layout/page-header';
import { ThemeToggle } from '@/components/shared/theme-toggle';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

export default function PreferencesSettingsPage() {
  return (
    <>
      <PageHeader
        title='Preferences'
        subtitle='Personalize your interface and localization settings.'
        backHref='/settings'
      />
      <section className='grid gap-6 px-4 pb-12 lg:px-6'>
        {/* Appearance Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <Palette className='text-primary h-4 w-4' />
              <CardTitle>Appearance</CardTitle>
            </div>
            <CardDescription>
              Customize how StartAppLab looks on your device.
            </CardDescription>
          </CardHeader>
          <CardContent className='space-y-4'>
            <div className='border-border flex items-center justify-between rounded-lg border p-4'>
              <div className='space-y-0.5'>
                <Label className='text-base'>Theme Mode</Label>
                <p className='text-muted-foreground text-sm'>
                  Switch between light and dark themes.
                </p>
              </div>
              <ThemeToggle />
            </div>
          </CardContent>
        </Card>

        {/* Localization Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <Languages className='text-primary h-4 w-4' />
              <CardTitle>Localization</CardTitle>
            </div>
            <CardDescription>
              Set your preferred language and regional formatting.
            </CardDescription>
          </CardHeader>
          <CardContent className='grid gap-6 sm:grid-cols-2'>
            <div className='space-y-2'>
              <Label htmlFor='language'>Display Language</Label>
              <Select defaultValue='en'>
                <SelectTrigger
                  id='language'
                  className='w-full'>
                  <SelectValue placeholder='Select Language' />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value='en'>English (US)</SelectItem>
                  <SelectItem value='es'>Español</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className='space-y-2'>
              <Label htmlFor='timezone'>Timezone</Label>
              <Select defaultValue='utc'>
                <SelectTrigger
                  id='timezone'
                  className='w-full'>
                  <SelectValue placeholder='Select Timezone' />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value='utc'>UTC (Greenwich Mean Time)</SelectItem>
                  <SelectItem value='est'>
                    EST (Eastern Standard Time)
                  </SelectItem>
                  <SelectItem value='pst'>
                    PST (Pacific Standard Time)
                  </SelectItem>
                  <SelectItem value='cet'>
                    CET (Central European Time)
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Regional Defaults Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <Globe className='text-primary h-4 w-4' />
              <CardTitle>Regional Defaults</CardTitle>
            </div>
            <CardDescription>
              Manage how dates and numbers are displayed.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className='space-y-2'>
              <Label htmlFor='date-format'>Date Format</Label>
              <Select defaultValue='iso'>
                <SelectTrigger
                  id='date-format'
                  className='w-full sm:w-[200px]'>
                  <SelectValue placeholder='Select Format' />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value='iso'>YYYY-MM-DD</SelectItem>
                  <SelectItem value='us'>MM/DD/YYYY</SelectItem>
                  <SelectItem value='eu'>DD/MM/YYYY</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>
      </section>
    </>
  );
}
