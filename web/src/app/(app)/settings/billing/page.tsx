import { CreditCard, TrendingUp, Zap, Info, CheckCircle2 } from 'lucide-react';
import { PageHeader } from '@/components/layout/page-header';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { BillingPortalButton } from '@/features/billing/components/billing-portal-button';
import { PLAN_DEFINITIONS } from '@/features/billing/lib/plan-gate';
import { getPlan, setFlag } from '@/features/billing/server/actions';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import type { Database } from '@/types/database';

export default async function BillingSettingsPage() {
  const [{ summary, definition }, flags] = await Promise.all([
    getPlan({}),
    fetchFlags(),
  ]);

  return (
    <>
      <PageHeader
        title='Billing'
        subtitle='Manage your subscription, workspace limits, and feature access.'
        backHref='/settings'
      />
      <section className='grid gap-6 px-4 pb-12 lg:px-6'>
        <div className='grid gap-6 lg:grid-cols-[1fr,1.2fr]'>
          {/* Plan Summary Card */}
          <Card className='flex flex-col'>
            <CardHeader>
              <div className='flex items-center gap-2'>
                <CreditCard className='text-primary h-4 w-4' />
                <CardTitle>Plan Summary</CardTitle>
              </div>
              <CardDescription>
                Your workspace is currently on the{' '}
                <span className='text-foreground font-medium'>
                  {definition.name}
                </span>{' '}
                plan.
              </CardDescription>
            </CardHeader>
            <CardContent className='flex-1 space-y-6'>
              <div className='grid grid-cols-2 gap-4'>
                <div className='border-border bg-muted/30 rounded-xl border p-4'>
                  <p className='text-muted-foreground text-xs font-medium tracking-wider uppercase'>
                    Status
                  </p>
                  <p className='mt-1 text-lg font-bold capitalize'>
                    {summary.status}
                  </p>
                </div>
                <div className='border-border bg-muted/30 rounded-xl border p-4'>
                  <p className='text-muted-foreground text-xs font-medium tracking-wider uppercase'>
                    Credits
                  </p>
                  <p className='mt-1 text-lg font-bold'>{summary.credits}</p>
                </div>
              </div>

              <div className='space-y-3'>
                <p className='text-foreground text-sm font-semibold'>
                  Included features:
                </p>
                <div className='grid gap-3'>
                  {PLAN_DEFINITIONS[summary.plan].features.map((feature) => (
                    <div
                      key={feature}
                      className='flex items-start gap-2.5'>
                      <CheckCircle2 className='text-primary mt-0.5 h-4 w-4' />
                      <span className='text-muted-foreground text-sm'>
                        {feature}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              <div className='pt-2'>
                <BillingPortalButton
                  plan={summary.plan === 'enterprise' ? 'enterprise' : 'pro'}
                />
              </div>
            </CardContent>
          </Card>

          {/* Upgrade Paths Card */}
          <Card className='flex flex-col'>
            <CardHeader>
              <div className='flex items-center gap-2'>
                <TrendingUp className='text-primary h-4 w-4' />
                <CardTitle>Available Plans</CardTitle>
              </div>
              <CardDescription>
                Scale your workspace with increased limits and exclusive tools.
              </CardDescription>
            </CardHeader>
            <CardContent className='flex-1 space-y-4'>
              {Object.values(PLAN_DEFINITIONS).map((plan) => {
                const isCurrent = plan.id === summary.plan;
                return (
                  <div
                    key={plan.id}
                    className={`border-border relative rounded-xl border p-4 transition-all ${
                      isCurrent ? 'bg-primary/5 ring-primary/20 ring-1' : ''
                    }`}>
                    {isCurrent && (
                      <Badge
                        className='absolute top-4 right-4'
                        variant='secondary'>
                        Current
                      </Badge>
                    )}
                    <div className='flex items-center justify-between'>
                      <div className='space-y-1'>
                        <h4 className='text-foreground font-bold'>
                          {plan.name}
                        </h4>
                        <p className='text-muted-foreground text-sm'>
                          {plan.limits.credits ?? 'Unlimited'} Credits included
                        </p>
                      </div>
                      <div className='text-right'>
                        <p className='text-foreground text-xl font-bold'>
                          ${plan.price}
                        </p>
                        <p className='text-muted-foreground text-xs capitalize'>
                          per {plan.interval}
                        </p>
                      </div>
                    </div>
                  </div>
                );
              })}
            </CardContent>
          </Card>
        </div>

        {/* Feature Flags Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center gap-2'>
              <Zap className='text-primary h-4 w-4' />
              <CardTitle>Feature Flags</CardTitle>
            </div>
            <CardDescription>
              Toggle developmental features and staging modules for this
              workspace.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {flags.length === 0 ? (
              <div className='flex flex-col items-center justify-center py-12 text-center'>
                <Info className='text-muted-foreground mb-3 h-8 w-8' />
                <p className='text-muted-foreground text-sm font-medium'>
                  No feature flags configured for this environment.
                </p>
              </div>
            ) : (
              <div className='border-border overflow-hidden rounded-xl border'>
                <table className='w-full text-left text-sm'>
                  <thead className='bg-muted/50 border-border border-b'>
                    <tr className='text-muted-foreground text-xs font-semibold tracking-wider uppercase'>
                      <th className='px-6 py-4'>Feature Key</th>
                      <th className='px-6 py-4'>Current State</th>
                      <th className='px-6 py-4 text-right'>System Action</th>
                    </tr>
                  </thead>
                  <tbody className='divide-border bg-card divide-y'>
                    {flags.map((flag) => (
                      <tr
                        key={flag.id}
                        className='hover:bg-muted/30 transition-colors'>
                        <td className='px-6 py-4'>
                          <code className='bg-muted text-foreground rounded px-1.5 py-0.5 font-mono font-medium'>
                            {flag.key}
                          </code>
                        </td>
                        <td className='px-6 py-4'>
                          <Badge
                            className='w-16 justify-center'
                            variant={flag.enabled ? 'default' : 'outline'}>
                            {flag.enabled ? 'Live' : 'Hidden'}
                          </Badge>
                        </td>
                        <td className='px-6 py-4 text-right'>
                          <form action={toggleFlagAction}>
                            <input
                              type='hidden'
                              name='key'
                              value={flag.key}
                            />
                            <input
                              type='hidden'
                              name='enabled'
                              value={flag.enabled ? 'false' : 'true'}
                            />
                            <Button
                              type='submit'
                              variant='outline'
                              size='sm'
                              className='h-8'>
                              {flag.enabled ? 'Disable' : 'Enable'}
                            </Button>
                          </form>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      </section>
    </>
  );
}

async function fetchFlags(): Promise<
  Database['public']['Tables']['feature_flags']['Row'][]
> {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase
    .from('feature_flags')
    .select('*')
    .order('key');
  if (error) {
    throw new Error(`Unable to load feature flags: ${error.message}`);
  }
  return data ?? [];
}

async function toggleFlagAction(formData: FormData) {
  'use server';

  const key = formData.get('key')?.toString();
  const enabledRaw = formData.get('enabled')?.toString();
  if (!key || typeof enabledRaw !== 'string') {
    throw new Error('Invalid flag submission.');
  }

  const enabled = enabledRaw === 'true';
  await setFlag({ key, enabled });
}
