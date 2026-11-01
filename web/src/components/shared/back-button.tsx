'use client';

import { ArrowLeft } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { Button, type ButtonProps } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface BackButtonProps {
  href?: string;
  onClick?: () => void;
  className?: string;
  variant?: ButtonProps['variant'] | 'circle';
}

export function BackButton({
  href,
  onClick,
  className,
  variant = 'outline',
}: BackButtonProps) {
  const router = useRouter();

  const handleClick = () => {
    if (onClick) {
      onClick();
    } else if (href) {
      router.push(href);
    } else {
      router.back();
    }
  };

  return (
    <Button
      variant={variant === 'circle' ? 'ghost' : variant}
      size='icon'
      onClick={handleClick}
      className={cn(
        variant === 'circle' &&
          'border-border bg-background hover:bg-accent hover:text-accent-foreground h-9 w-9 rounded-full border transition-colors',
        className
      )}>
      <ArrowLeft className='h-4 w-4' />
    </Button>
  );
}
