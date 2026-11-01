'use client';

import { cn } from '@/lib/utils';

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  text?: string;
  className?: string;
}

const sizes = {
  sm: 'h-4 w-4 border-2',
  md: 'h-6 w-6 border-2',
  lg: 'h-8 w-8 border-3',
};

export function LoadingSpinner({
  size = 'md',
  text,
  className,
}: LoadingSpinnerProps) {
  const sizeClass = (() => {
    switch (size) {
      case 'sm':
        return sizes.sm;
      case 'lg':
        return sizes.lg;
      case 'md':
      default:
        return sizes.md;
    }
  })();

  return (
    <div
      className={cn(
        'text-muted-foreground flex items-center gap-3',
        className
      )}>
      <span
        className={cn(
          'border-border border-t-primary inline-block animate-spin rounded-full',
          sizeClass
        )}
        aria-label='Loading'
      />
      {text ? <span className='text-sm font-medium'>{text}</span> : null}
    </div>
  );
}
