import { cn } from '@/lib/utils';

interface FormMessageProps {
  type: 'error' | 'success';
  children: React.ReactNode;
  className?: string;
}

export function FormMessage({ type, children, className }: FormMessageProps) {
  if (!children) return null;

  return (
    <div
      className={cn(
        'rounded-lg px-3 py-2 text-sm',
        type === 'error' && 'bg-destructive/10 text-destructive',
        type === 'success' && 'bg-green-50 text-green-700',
        className
      )}>
      {children}
    </div>
  );
}
