import { Eye, EyeOff } from 'lucide-react';
import * as React from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

export type PasswordInputProps = React.ComponentProps<'input'>;

export const PasswordInput = React.forwardRef<
  HTMLInputElement,
  PasswordInputProps
>(({ className, ...props }, ref) => {
  const [showPassword, setShowPassword] = React.useState(false);

  return (
    <div className='relative'>
      <Input
        ref={ref}
        type={showPassword ? 'text' : 'password'}
        className={className}
        {...props}
      />
      <Button
        type='button'
        variant='ghost'
        size='icon'
        className='text-muted-foreground hover:text-primary absolute top-1/2 right-2 h-8 w-8 -translate-y-1/2 hover:bg-transparent'
        onClick={() => setShowPassword((prev) => !prev)}>
        {showPassword ? (
          <Eye className='h-4 w-4' />
        ) : (
          <EyeOff className='h-4 w-4' />
        )}
      </Button>
    </div>
  );
});
PasswordInput.displayName = 'PasswordInput';
