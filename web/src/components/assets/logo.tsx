import { RocketIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

export const Logo = ({ className }: { className?: string }) => (
  <div
    className={cn(
      'bg-primary text-primary-foreground flex items-center justify-center rounded-[15%]',
      className
    )}
    aria-hidden='true'>
    <RocketIcon className='size-[55%]' />
  </div>
);
