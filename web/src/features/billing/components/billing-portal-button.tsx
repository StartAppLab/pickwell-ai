'use client';

import { useState, useTransition } from 'react';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { Button } from '@/components/ui/button';
import { startCheckoutSession } from '@/features/billing/server/actions';

interface BillingPortalButtonProps {
  plan: 'pro' | 'enterprise';
  orgId?: string | null;
}

export function BillingPortalButton({ plan, orgId }: BillingPortalButtonProps) {
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const handleClick = () => {
    setError(null);
    startTransition(async () => {
      try {
        const { url } = await startCheckoutSession({ plan, orgId });
        window.location.href = url;
      } catch (err) {
        setError(
          err instanceof Error
            ? err.message
            : 'Unable to start checkout session.'
        );
      }
    });
  };

  return (
    <div className='space-y-2'>
      <Button
        variant='default'
        onClick={handleClick}
        disabled={isPending}>
        {isPending ? (
          <LoadingSpinner
            size='sm'
            text='Redirecting...'
          />
        ) : (
          'Upgrade plan'
        )}
      </Button>
      <FormMessage type='error'>{error}</FormMessage>
    </div>
  );
}
