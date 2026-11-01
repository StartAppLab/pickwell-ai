import Link from 'next/link';
import { redirect } from 'next/navigation';
import { AppLogo } from '@/components/shared/app-logo';
import { ThemeToggle } from '@/components/shared/theme-toggle';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';

type LandingPageSearchParams = Record<string, string | string[] | undefined>;

const landingPageConfig = {
  hero: {
    headline: 'Launch your SaaS faster than ever',
    subheadline:
      'Opinionated Next.js boilerplate with Supabase auth, organization management, billing primitives, and feature flags. Swap in your domain models without rewriting the foundation.',
    cta: [
      { text: 'Get Started Free', href: '/signup', variant: 'default' },
      { text: 'Sign In', href: '/login', variant: 'outline' },
    ],
  },
  features: {
    title: 'Everything you need to build and scale',
    subtitle:
      'Pre-built components and patterns that handle the complex parts, so you can focus on what makes your product unique.',
    items: [
      {
        title: 'Teams & Roles',
        copy: 'Members, admins, and owners with organization-aware routing and defaults.',
        icon: '👥',
        tags: ['Organizations', 'Permissions'],
      },
      {
        title: 'Billing Primitives',
        copy: 'Plan metadata, usage counters, credit wallets, and webhook sink ready for providers.',
        icon: '💳',
        tags: ['Lemon Squeezy', 'Usage Tracking'],
      },
      {
        title: 'Guards & Flags',
        copy: 'Plan-based gates, credit checks, and remote feature flags to ship safely.',
        icon: '🚦',
        tags: ['Feature Flags', 'Access Control'],
      },
      {
        title: 'Authentication',
        copy: 'Complete auth system with email, OAuth providers, and session management.',
        icon: '🔐',
        tags: ['Supabase', 'OAuth'],
      },
      {
        title: 'Modern Stack',
        copy: 'Next.js, Tailwind CSS, and shadcn/ui components.',
        icon: '⚡',
        tags: ['Next.js', 'Tailwind'],
      },
      {
        title: 'Developer Experience',
        copy: 'Hot reload, type safety, and comprehensive tooling for rapid development.',
        icon: '🛠️',
        tags: ['TypeScript', 'ESLint'],
      },
    ],
  },
  cta: {
    title: 'Ready to build something amazing?',
    subtitle:
      'Join thousands of developers who are shipping faster with StartAppLab.',
    action: { text: 'Start Building Today', href: '/signup' },
  },
};

export default async function LandingPage({
  searchParams,
}: {
  searchParams: Promise<LandingPageSearchParams>;
}) {
  const resolvedSearchParams = await searchParams;
  const code = resolvedSearchParams?.code;
  if (code) {
    const params = new URLSearchParams();

    // Add all search params
    for (const [key, value] of Object.entries(resolvedSearchParams)) {
      if (Array.isArray(value)) {
        if (value.length > 0) {
          params.set(key, value[0] ?? '');
        }
      } else if (typeof value === 'string' && value.length > 0) {
        params.set(key, value);
      }
    }

    // Ensure code is set
    if (!params.has('code')) {
      const firstCode = Array.isArray(code) ? code[0] : code;
      if (firstCode) {
        params.set('code', firstCode);
      }
    }

    const search = params.toString();
    redirect(`/auth/callback${search ? `?${search}` : ''}`);
  }

  // -----------------------------------------------------------------------------
  // SKIP LANDING PAGE
  // -----------------------------------------------------------------------------
  // If you are building an internal tool or dashboard and want to skip the
  // landing page, set this to `true`.
  const shouldSkipLanding = true;

  if (shouldSkipLanding) {
    redirect('/login');
  }

  return (
    <main className='bg-background min-h-screen'>
      {/* Header */}
      <header className='fixed top-0 right-0 left-0 z-50 flex w-full flex-col items-center justify-center py-6'>
        <div className='flex w-11/12 items-center justify-between xl:w-10/12 2xl:w-[1280px]'>
          <AppLogo className='self-center' />
          <ThemeToggle />
        </div>
      </header>

      {/* Hero Section */}
      <section className='bg-background flex min-h-screen w-full items-center justify-center pt-20 pb-10 lg:py-0 xl:py-48'>
        <div className='flex w-full max-w-7xl flex-col items-center gap-8 px-4'>
          <div className='flex w-full max-w-4xl flex-col items-center text-center'>
            <div className='mb-4'>
              <div className='block-subtitle'>Built with StartAppLab</div>
            </div>
            <h1 className='headline mt-8'>{landingPageConfig.hero.headline}</h1>
            <p className='subheadline mt-6 max-w-2xl'>
              {landingPageConfig.hero.subheadline}
            </p>
            <div className='mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center'>
              {landingPageConfig.hero.cta.map((cta) => (
                <Button
                  key={cta.text}
                  asChild
                  size='lg'
                  variant={cta.variant as 'default' | 'outline'}
                  className='h-12 px-8 text-lg'>
                  <Link href={cta.href}>{cta.text}</Link>
                </Button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className='section-style bg-muted/30'>
        <div className='section-size'>
          <div className='mb-16 text-center'>
            <h2 className='block-title mb-4'>
              {landingPageConfig.features.title}
            </h2>
            <p className='subheadline mx-auto max-w-2xl'>
              {landingPageConfig.features.subtitle}
            </p>
          </div>
          <div className='grid gap-8 md:grid-cols-2 lg:grid-cols-3'>
            {landingPageConfig.features.items.map((feature) => (
              <Card
                key={feature.title}
                className='clickable-card flex h-full flex-col overflow-hidden'>
                <CardHeader>
                  <div className='flex items-center gap-3'>
                    <div
                      className='text-primary border-border flex h-10 w-10 items-center justify-center rounded-lg border'
                      aria-hidden='true'>
                      {feature.icon}
                    </div>
                    <CardTitle className='content-title'>
                      {feature.title}
                    </CardTitle>
                  </div>
                </CardHeader>
                <CardContent className='flex flex-1 flex-col'>
                  <CardDescription className='content-text-muted flex-1'>
                    {feature.copy}
                  </CardDescription>
                  <div className='mt-4 flex flex-wrap gap-2'>
                    {feature.tags.map((tag) => (
                      <Badge
                        key={tag}
                        variant='secondary'
                        className='text-xs font-normal'>
                        {tag}
                      </Badge>
                    ))}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className='section-style'>
        <div className='section-size px-4 text-center'>
          <div className='bg-primary/5 rounded-2xl border p-12 lg:p-16'>
            <h2 className='block-big-title mb-6'>
              {landingPageConfig.cta.title}
            </h2>
            <p className='subheadline mx-auto mb-8 max-w-2xl'>
              {landingPageConfig.cta.subtitle}
            </p>
            <Button
              asChild
              size='lg'
              className='h-12 px-8 text-lg'>
              <Link href={landingPageConfig.cta.action.href}>
                {landingPageConfig.cta.action.text}
              </Link>
            </Button>
          </div>
        </div>
      </section>
    </main>
  );
}
