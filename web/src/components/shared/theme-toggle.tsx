'use client';

import { Moon, Sun } from 'lucide-react';
import { useTheme } from 'next-themes';
import * as React from 'react';
import { cn } from '@/lib/utils';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = React.useState(false);

  React.useEffect(() => {
    setMounted(true);
  }, []);

  // Prevents hydration mismatch by defaulting to false (light/default) until mounted
  const isDark = mounted && theme === 'dark';

  return (
    <button
      onClick={() => setTheme(isDark ? 'light' : 'dark')}
      className={cn(
        'relative inline-flex h-7 w-12 cursor-pointer items-center rounded-full border-2 transition-all duration-300 ease-in-out',
        isDark ? 'border-input bg-border' : 'border-border bg-input'
      )}
      role='switch'
      aria-checked={isDark}
      aria-label='Toggle theme'>
      {/* Background */}
      <div
        className={cn(
          'absolute inset-0 rounded-full transition-all duration-300 ease-in-out',
          isDark ? 'bg-primary' : 'bg-input'
        )}
      />

      {/* Toggle thumb */}
      <span
        className={cn(
          'bg-background relative z-10 inline-flex h-6 w-6 transform items-center justify-center rounded-full shadow-lg transition-all duration-300 ease-in-out',
          isDark ? 'translate-x-5' : 'translate-x-0'
        )}>
        {/* Icon container */}
        <div className='flex h-full w-full items-center justify-center'>
          {isDark ? (
            <Moon className='h-3 w-3 text-white' />
          ) : (
            <Sun className='h-3 w-3 text-black' />
          )}
        </div>
      </span>
    </button>
  );
}
