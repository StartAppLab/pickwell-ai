import {
  Search,
  Book,
  MessageSquare,
  Mail,
  ExternalLink,
  LifeBuoy,
  ShieldQuestion,
  Rocket,
} from 'lucide-react';
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
import { Input } from '@/components/ui/input';

const FAQS = [
  {
    question: 'How do I manage my organization?',
    answer:
      'You can manage your organization by navigating to the Organization Settings page. There, you can create new workspaces, invite team members, and switch between different active contexts.',
    category: 'Account',
  },
  {
    question: 'How does billing and credits work?',
    answer:
      'StartAppLab uses a credit-based system. Each plan includes a specific number of monthly credits. You can track your usage and upgrade your plan in the Billing Settings section.',
    category: 'Billing',
  },
  {
    question: 'Can I integrate with custom data sources?',
    answer:
      'Yes! StartAppLab is built to be flexible. You can connect your own domain models and external APIs using our standard Next.js and Supabase patterns.',
    category: 'Technical',
  },
];

export default function HelpPage() {
  return (
    <>
      <PageHeader
        title='Help & Support'
        subtitle='Find answers to common questions and learn how to get the most out of StartAppLab.'
      />

      <section className='grid gap-8 px-4 pb-12 lg:px-6'>
        {/* Search Hero Area */}
        <div className='bg-primary/5 border-primary/10 relative overflow-hidden rounded-2xl border p-8 text-center'>
          <div className='relative z-10 mx-auto max-w-2xl space-y-4'>
            <h2 className='text-foreground text-2xl font-bold tracking-tight'>
              How can we help you today?
            </h2>
            <div className='relative'>
              <Search className='text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2' />
              <Input
                placeholder='Search for guides, FAQs, or technical documentation...'
                className='bg-background h-12 pl-10 shadow-sm'
              />
            </div>
            <div className='flex flex-wrap justify-center gap-2 pt-2'>
              <span className='text-muted-foreground text-xs font-medium'>
                Popular topics:
              </span>
              <Badge
                variant='secondary'
                className='hover:bg-muted cursor-pointer'>
                Billing
              </Badge>
              <Badge
                variant='secondary'
                className='hover:bg-muted cursor-pointer'>
                API Keys
              </Badge>
              <Badge
                variant='secondary'
                className='hover:bg-muted cursor-pointer'>
                Team Access
              </Badge>
            </div>
          </div>
          {/* Subtle background decoration */}
          <div className='bg-primary/10 absolute -top-8 -right-8 h-32 w-32 rounded-full blur-3xl' />
          <div className='bg-primary/10 absolute -bottom-8 -left-8 h-32 w-32 rounded-full blur-3xl' />
        </div>

        <div className='grid gap-6 lg:grid-cols-3'>
          {/* Quick Links */}
          <div className='space-y-6 lg:col-span-2'>
            <div className='flex items-center gap-2 px-1'>
              <ShieldQuestion className='text-primary h-5 w-5' />
              <h3 className='text-lg font-bold'>Frequently Asked Questions</h3>
            </div>
            <div className='grid gap-4'>
              {FAQS.map((faq, index) => (
                <Card
                  key={index}
                  className='hover:bg-muted/30 cursor-pointer transition-colors'>
                  <CardHeader className='pb-3'>
                    <div className='flex items-center justify-between'>
                      <CardTitle className='text-base'>
                        {faq.question}
                      </CardTitle>
                      <Badge
                        variant='outline'
                        className='text-[10px] uppercase'>
                        {faq.category}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className='text-muted-foreground text-sm leading-relaxed'>
                      {faq.answer}
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
            <Button
              variant='link'
              className='text-primary px-1'>
              View all 20+ helper articles
              <ExternalLink className='ml-2 h-4 w-4' />
            </Button>
          </div>

          {/* Contact & Resources */}
          <div className='space-y-6'>
            {/* Documentation Card */}
            <Card className='border-primary/20 bg-primary/5'>
              <CardHeader>
                <div className='flex items-center gap-2'>
                  <Book className='text-primary h-4 w-4' />
                  <CardTitle className='text-base'>Documentation</CardTitle>
                </div>
                <CardDescription>
                  Deep dive into our technical guides and API references.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <Button
                  className='w-full justify-between'
                  variant='secondary'>
                  Read Docs
                  <Book className='h-4 w-4' />
                </Button>
              </CardContent>
            </Card>

            {/* Support Channels */}
            <Card>
              <CardHeader>
                <div className='flex items-center gap-2'>
                  <LifeBuoy className='text-primary h-4 w-4' />
                  <CardTitle className='text-base'>Support Channels</CardTitle>
                </div>
                <CardDescription>
                  Talk to a human or join our growing community.
                </CardDescription>
              </CardHeader>
              <CardContent className='space-y-3'>
                <Button
                  className='w-full justify-start gap-2'
                  variant='outline'>
                  <Mail className='h-4 w-4' />
                  Email Support
                </Button>
                <Button
                  className='w-full justify-start gap-2'
                  variant='outline'>
                  <MessageSquare className='h-4 w-4' />
                  Join Discord Community
                </Button>
              </CardContent>
            </Card>

            {/* Quick Tips */}
            <Card className='bg-muted/30'>
              <CardHeader>
                <div className='flex items-center gap-2'>
                  <Rocket className='text-primary h-4 w-4' />
                  <CardTitle className='text-base'>Did you know?</CardTitle>
                </div>
              </CardHeader>
              <CardContent>
                <p className='text-muted-foreground text-xs leading-relaxed'>
                  You can invite your entire team at once using our bulk invite
                  tool in the Organization Settings.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>
    </>
  );
}
