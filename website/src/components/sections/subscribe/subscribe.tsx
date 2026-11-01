import { CheckArrowIcon } from '@/assets/icons/check-arrow-icon';
import { AppLogo } from '@/components/shared/app-logo';
import EmailCapture from '@/components/shared/email-capture';
import { cn } from '@/lib/utils';

export const sectionConfig = {
  actionButtonText: 'Subscribe to updates',
  benefits: [
    'Get notified about new features and improvements',
    'Early access to beta features and updates',
    'Tips and workflows for better note-taking',
    'Product updates and productivity insights',
  ],
  headline: {
    primary: 'Stay Updated',
    secondary: 'Get Notified',
  },
  subheadline: 'Be the first to know about new features, updates and more',
  emailInput: {
    placeholder: 'Enter your email for updates',
    ariaLabel: 'Email input for newsletter subscription',
    errorMessage: 'Please enter a valid email address',
    successMessage: "Thank you for subscribing! You'll receive updates soon.",
  },
};

interface SubscribeProps {
  isModal?: boolean;
}

export const Subscribe = ({ isModal = false }: SubscribeProps) => {
  return (
    <div
      className={cn(
        'relative',
        isModal
          ? 'flex flex-col lg:flex-row'
          : 'mx-auto flex max-w-5xl flex-col px-4 py-16 lg:flex-row lg:pt-40'
      )}>
      <div className='hidden w-full lg:block lg:w-1/2'>
        {/* Desktop Headline */}
        <h1
          className={cn(
            'text-foreground text-5xl font-semibold',
            isModal ? 'mt-6 mb-2' : 'mb-2'
          )}>
          {sectionConfig.headline.primary}
        </h1>
        <h2 className='text-primary text-5xl font-semibold'>
          {sectionConfig.headline.secondary}
        </h2>
        {/* Desktop Benefits */}
        <ul className='text-foreground mt-12 mb-6'>
          {sectionConfig.benefits.map((benefit, index) => (
            <li
              key={`benefit-${index}`}
              className='mb-4 flex items-center text-start'>
              <div className='shrink-0'>
                <CheckArrowIcon />
              </div>
              <span>{benefit}</span>
            </li>
          ))}
        </ul>
      </div>

      <div className='flex w-full flex-col items-center justify-center lg:w-1/2'>
        {/* Mobile Headline */}
        <div className={cn('block lg:hidden', isModal ? 'mb-6' : 'mt-16 mb-6')}>
          <h1 className='text-foreground text-center text-4xl font-semibold'>
            {sectionConfig.headline.primary}
          </h1>
          <h2 className='text-primary text-center text-4xl font-semibold'>
            {sectionConfig.headline.secondary}
          </h2>
        </div>

        {/* App Logo and Name */}
        <AppLogo className='mb-8 justify-start pr-6' />
        {/* Subheadline */}
        <h3 className='text-foreground mb-7 text-center text-2xl font-semibold'>
          {sectionConfig.subheadline}
        </h3>
        <div className='w-full max-w-md px-4'>
          <EmailCapture />
        </div>

        {/* Mobile Benefits */}
        <div className='mt-8 block w-full px-4 lg:hidden'>
          <ul className='text-foreground'>
            {sectionConfig.benefits.map((benefit, index) => (
              <li
                key={`benefit-${index}`}
                className='mb-4 flex items-center text-start'>
                <div className='shrink-0'>
                  <CheckArrowIcon />
                </div>
                <span>{benefit}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};
