import {
  Smartphone,
  Monitor,
  Globe,
  Navigation,
  ExternalLink,
  Laptop,
} from 'lucide-react';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { ChartAreaInteractive } from '@/features/dashboard/components/chart-area-interactive';
import { cn } from '@/lib/utils';

export default function AnalyticsPage() {
  return (
    <>
      <PageHeader
        title='Analytics'
        subtitle='Deep dive into your workspace usage, audience demographics, and traffic sources.'
      />

      <section className='grid gap-8 px-4 pb-12 lg:px-6'>
        {/* Chart Area Interactive */}
        <div className='-mx-2'>
          <ChartAreaInteractive />
        </div>

        {/* Specialized Insights Grid */}
        <div className='grid gap-6 lg:grid-cols-3'>
          {/* Audience Segments (Device Distribution) */}
          <Card>
            <CardHeader>
              <div className='text-primary flex items-center gap-2'>
                <Smartphone className='h-4 w-4' />
                <CardTitle className='text-sm font-bold tracking-tight uppercase'>
                  Audience Segments
                </CardTitle>
              </div>
              <CardDescription className='text-xs'>
                Breakdown of user access by device category.
              </CardDescription>
            </CardHeader>
            <CardContent className='space-y-5'>
              {[
                {
                  label: 'Desktop',
                  value: '58.2%',
                  icon: Monitor,
                  color: 'bg-primary',
                },
                {
                  label: 'Mobile',
                  value: '34.1%',
                  icon: Smartphone,
                  color: 'bg-primary/60',
                },
                {
                  label: 'Tablet',
                  value: '7.7%',
                  icon: Laptop,
                  color: 'bg-muted',
                },
              ].map((device) => (
                <div
                  key={device.label}
                  className='space-y-2'>
                  <div className='flex items-center justify-between text-[11px]'>
                    <div className='flex items-center gap-2 font-semibold'>
                      <device.icon className='text-muted-foreground h-3.5 w-3.5' />
                      {device.label}
                    </div>
                    <span className='font-bold'>{device.value}</span>
                  </div>
                  <div className='bg-muted h-1.5 w-full overflow-hidden rounded-full'>
                    <div
                      className={`h-full ${device.color}`}
                      style={{ width: device.value }}
                    />
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Geographic Distribution */}
          <Card>
            <CardHeader>
              <div className='text-primary flex items-center gap-2'>
                <Globe className='h-4 w-4' />
                <CardTitle className='text-sm font-bold tracking-tight uppercase'>
                  Top Locations
                </CardTitle>
              </div>
              <CardDescription className='text-xs'>
                Geographic analysis of your top performing regions.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className='space-y-4'>
                {[
                  { country: 'United States', visitors: '45,231', share: 45 },
                  { country: 'United Kingdom', visitors: '12,892', share: 15 },
                  { country: 'Germany', visitors: '8,432', share: 10 },
                  { country: 'Canada', visitors: '7,120', share: 8 },
                ].map((item) => (
                  <div
                    key={item.country}
                    className='border-border/50 flex items-center justify-between border-b pb-2 last:border-0 last:pb-0'>
                    <div className='flex items-center gap-3'>
                      <div className='bg-muted flex h-7 w-7 items-center justify-center rounded text-[10px] font-bold'>
                        {item.country.substring(0, 2).toUpperCase()}
                      </div>
                      <span className='text-xs font-medium'>
                        {item.country}
                      </span>
                    </div>
                    <div className='text-right'>
                      <p className='text-sm font-bold'>{item.visitors}</p>
                      <p className='text-muted-foreground text-[9px] font-bold tracking-tighter uppercase'>
                        {item.share}% Share
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Traffic Sources / Acquisition */}
          <Card>
            <CardHeader>
              <div className='text-primary flex items-center gap-2'>
                <Navigation className='h-4 w-4' />
                <CardTitle className='text-sm font-bold tracking-tight uppercase'>
                  Acquisition
                </CardTitle>
              </div>
              <CardDescription className='text-xs'>
                Top referral sources bringing traffic to your workspace.
              </CardDescription>
            </CardHeader>
            <CardContent className='space-y-4'>
              {[
                {
                  source: 'Direct',
                  value: '42%',
                  textColor: 'text-green-500',
                  bgColor: 'bg-green-500',
                },
                {
                  source: 'Search',
                  value: '31%',
                  textColor: 'text-blue-500',
                  bgColor: 'bg-blue-500',
                },
                {
                  source: 'Social',
                  value: '18%',
                  textColor: 'text-yellow-500',
                  bgColor: 'bg-yellow-500',
                },
                {
                  source: 'Referral',
                  value: '9%',
                  textColor: 'text-primary',
                  bgColor: 'bg-primary',
                },
              ].map((item) => (
                <div
                  key={item.source}
                  className='flex items-center justify-between text-xs'>
                  <span className='text-muted-foreground font-medium'>
                    {item.source}
                  </span>
                  <div className='flex items-center gap-2'>
                    <div className={cn('h-2 w-2 rounded-full', item.bgColor)} />
                    <span className={cn('font-bold', item.textColor)}>
                      {item.value}
                    </span>
                  </div>
                </div>
              ))}
              <div className='pt-6'>
                <Button
                  variant='outline'
                  className='group h-8 w-full text-[10px] font-bold'
                  size='sm'>
                  EXPLORE REFERRAL LOG
                  <ExternalLink className='ml-2 h-3 w-3 transition-transform group-hover:translate-x-0.5' />
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>
    </>
  );
}
