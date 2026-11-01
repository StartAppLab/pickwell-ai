import { Moon, Sun } from 'lucide-react';
import { useSyncExternalStore } from 'react';
import { cn } from '@/lib/utils';

type Theme = 'light' | 'dark';

const THEME_CHANGE_EVENT = 'theme-change';
const THEME_STORAGE_KEY = 'pickwell-theme';

// Get theme from DOM/localStorage
const getThemeSnapshot = (): Theme => {
  const stored = localStorage.getItem(THEME_STORAGE_KEY) as Theme | null;
  if (stored) return stored;
  return 'light';
};

// Server snapshot - always return light for SSR
const getServerSnapshot = (): Theme => 'light';

// Subscribe to theme changes
const subscribeToTheme = (callback: () => void): (() => void) => {
  const handleThemeChange = () => callback();
  const handleStorageChange = (e: StorageEvent) => {
    if (e.key === THEME_STORAGE_KEY) callback();
  };

  window.addEventListener(THEME_CHANGE_EVENT, handleThemeChange);
  window.addEventListener('storage', handleStorageChange);

  return () => {
    window.removeEventListener(THEME_CHANGE_EVENT, handleThemeChange);
    window.removeEventListener('storage', handleStorageChange);
  };
};

const applyTheme = (theme: Theme) => {
  document.documentElement.classList.toggle('dark', theme === 'dark');
  localStorage.setItem(THEME_STORAGE_KEY, theme);
  window.dispatchEvent(new CustomEvent(THEME_CHANGE_EVENT, { detail: theme }));
};

export function ThemeToggle() {
  const theme = useSyncExternalStore(
    subscribeToTheme,
    getThemeSnapshot,
    getServerSnapshot
  );

  const toggleTheme = () => {
    const newTheme: Theme = theme === 'dark' ? 'light' : 'dark';
    applyTheme(newTheme);
  };

  const isDark = theme === 'dark';

  return (
    <button
      onClick={toggleTheme}
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
