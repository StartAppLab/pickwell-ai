'use client';

import { useState, useTransition } from 'react';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { Button } from '@/components/ui/button';

interface SSOButtonProps {
  provider: 'google' | 'apple' | 'github';
  action: () => Promise<{ error?: string; success?: string | boolean }>;
  label?: string;
  icon?: React.ReactNode;
  className?: string;
}

export function SSOButton({
  provider,
  action,
  label,
  icon,
  className,
}: SSOButtonProps) {
  const defaultIcons = {
    google: <i className='ci ci-google' />,
    apple: <i className='ci ci-apple' />,
    github: <i className='ci ci-github' />,
  };

  const defaultLabels = {
    google: 'Continue with Google',
    apple: 'Continue with Apple',
    github: 'Continue with GitHub',
  };

  const buttonIcon =
    icon ||
    (() => {
      switch (provider) {
        case 'google':
          return defaultIcons.google;
        case 'apple':
          return defaultIcons.apple;
        case 'github':
          return defaultIcons.github;
        default:
          return null;
      }
    })();

  const buttonLabel =
    label ||
    (() => {
      switch (provider) {
        case 'google':
          return defaultLabels.google;
        case 'apple':
          return defaultLabels.apple;
        case 'github':
          return defaultLabels.github;
        default:
          return '';
      }
    })();

  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  const handleClick = () => {
    setError(null);
    startTransition(async () => {
      const result = await action();
      if (result?.error) {
        setError(result.error);
      }
    });
  };

  return (
    <div className={`space-y-1 ${className || ''}`}>
      <Button
        type='button'
        variant='outline'
        className='w-full'
        onClick={handleClick}
        disabled={pending}>
        {pending ? (
          <LoadingSpinner
            size='sm'
            text='Connecting...'
          />
        ) : (
          <>
            {buttonIcon}
            {buttonLabel}
          </>
        )}
      </Button>
      <FormMessage type='error'>{error}</FormMessage>
    </div>
  );
}
