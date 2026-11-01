import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

export const CtaButton = ({
  ctaButtonTitle,
  className,
  variant = 'default',
  size = 'default',
  onClick,
}: {
  ctaButtonTitle: string;
  className?: string;
  variant?: 'default' | 'outline';
  size?: 'default' | 'sm' | 'lg';
  onClick: () => void;
}) => {
  return (
    <Button
      variant={variant}
      aria-label={ctaButtonTitle}
      className={cn(
        'button cursor-pointer',
        size === 'default' && 'h-12 w-64 sm:w-52',
        size === 'sm' && 'h-10 px-8',
        size === 'lg' && 'h-14 w-72 sm:w-64',
        variant === 'outline' && 'border-primary!',
        className
      )}
      onClick={onClick}>
      {ctaButtonTitle}
    </Button>
  );
};
