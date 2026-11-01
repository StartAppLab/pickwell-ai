import { Logo } from '@/assets/logos/logo';
import { trackButtonClick } from '@/lib/analytics';
import { cn } from '@/lib/utils';

export const AppLogo = ({
  appName = 'StartAppNotes',
  className,
  clickable = false,
  size = 'default',
  href = '/',
}: {
  appName?: string;
  className?: string;
  clickable?: boolean;
  size?: 'sm' | 'default';
  href?: string;
}) => {
  const logoContent = (
    <div className={cn('flex items-center gap-2 font-medium', className)}>
      <Logo className={size === 'sm' ? 'size-7' : 'size-8'} />
      <span
        className={cn(
          'text-foreground font-bold',
          size === 'sm' ? 'text-lg' : 'text-xl'
        )}>
        {appName}
      </span>
    </div>
  );

  if (clickable) {
    return (
      <a
        href={href}
        aria-label='Home'
        onClick={async () => {
          await trackButtonClick('logo_click', undefined, {
            destination: href,
          });
        }}>
        {logoContent}
      </a>
    );
  }

  return logoContent;
};
