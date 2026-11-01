import { useEffect, useState } from 'react';
import CookieManager from '@/components/sections/cookies/cookie-manager';
import { Button } from '@/components/ui/button';
import { trackButtonClick } from '@/lib/analytics';

export const CookieBanner = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Check if user has already accepted cookies
    const hasAccepted = CookieManager.hasAccepted();
    if (!hasAccepted) {
      // Show the banner after a short delay
      const timer = window.setTimeout(() => {
        setIsVisible(true);
      }, 1000);
      return () => window.clearTimeout(timer);
    }
  }, []);

  const acceptCookies = async () => {
    CookieManager.setConsent('accepted');
    await trackButtonClick('cookie_consent_accept');
    setIsVisible(false);
  };

  const declineCookies = async () => {
    await trackButtonClick('cookie_consent_decline');
    CookieManager.setConsent('rejected');
    setIsVisible(false);
  };

  if (!isVisible) return null;

  return (
    <div className='cookie-banner border-border bg-background fixed inset-x-0 bottom-0 z-50 border-t shadow-lg'>
      <div className='container mx-auto p-4 md:px-6'>
        <div className='flex flex-col items-start justify-between gap-4 md:flex-row md:items-center'>
          <div className='flex-1'>
            <p className='text-sm md:text-base'>
              We use cookies to enhance your experience on our app. By
              continuing to use this app, you agree to our{' '}
              <a
                href='/cookies'
                className='text-primary font-medium underline underline-offset-4'>
                Cookie Policy
              </a>
              .
            </p>
          </div>
          <div className='flex flex-wrap gap-2'>
            <Button
              variant='outline'
              size='sm'
              className='whitespace-nowrap'
              onClick={declineCookies}>
              Decline
            </Button>
            <Button
              variant='default'
              size='sm'
              className='whitespace-nowrap'
              onClick={acceptCookies}>
              Accept All
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};
