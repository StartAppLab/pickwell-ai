'use client';

import { AlertTriangle } from 'lucide-react';
import { useEffect } from 'react';
import { Button } from '@/components/ui/button';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Optionally log the error to an error reporting service
    console.error('Unhandled application error:', error);
  }, [error]);

  return (
    <div className='flex min-h-svh flex-col items-center justify-center gap-6 px-6 text-center'>
      <div className='bg-destructive/10 flex h-20 w-20 items-center justify-center rounded-2xl'>
        <AlertTriangle className='text-destructive h-10 w-10' />
      </div>
      <div className='space-y-2'>
        <h1 className='text-foreground text-3xl font-bold tracking-tight'>
          Something went wrong
        </h1>
        <p className='text-muted-foreground max-w-[400px] whitespace-pre-wrap'>
          An unexpected error occurred. We&apos;ve been notified and are working
          on a fix.
        </p>
        {error.digest && (
          <p className='text-muted-foreground mt-2 font-mono text-xs'>
            Error ID: {error.digest}
          </p>
        )}
      </div>
      <div className='flex gap-3'>
        <Button
          variant='outline'
          onClick={() => (window.location.href = '/')}>
          Go back home
        </Button>
        <Button onClick={() => reset()}>Try again</Button>
      </div>
    </div>
  );
}
