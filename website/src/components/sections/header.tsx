import { X } from 'lucide-react';
import { motion } from 'motion/react';
import { useCallback, useEffect, useRef, useState } from 'react';
import { AppLogo } from '@/components/shared/app-logo';
import { CtaButton } from '@/components/shared/cta-button';
import { HamburgerButton } from '@/components/shared/hamburger-button';
import { ThemeToggle } from '@/components/shared/theme-toggle';
import { Button } from '@/components/ui/button';
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetTitle,
} from '@/components/ui/sheet';
import { trackButtonClick } from '@/lib/analytics';
import { cn } from '@/lib/utils';

const appDescription =
  'Capture ideas instantly, organize effortlessly, and sync seamlessly across all your devices.';
const ctaButtonTitle = 'Download';
const ctaButtonLink = '/download';

const headerLinksData = [
  { title: 'Features', href: '/#features', ariaLabel: 'Features' },
  { title: 'Pricing', href: '/#pricing', ariaLabel: 'Pricing' },
  { title: 'FAQ', href: '/#faq', ariaLabel: 'FAQ' },
  { title: 'Blog', href: '/blog', ariaLabel: 'Blog' },
];

export const Header = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const ticking = useRef(false);

  // Throttled scroll handler
  const handleScroll = useCallback(() => {
    if (!ticking.current) {
      window.requestAnimationFrame(() => {
        setIsScrolled(window.scrollY > 20);
        ticking.current = false;
      });
      ticking.current = true;
    }
  }, []);

  useEffect(() => {
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return (
    <nav
      className={cn(
        'header-style bg-background py-5 transition-all duration-300',
        isScrolled ? 'shadow-sm' : 'shadow-none'
      )}
      aria-label='Header'>
      <div className='header-size'>
        <div className='relative flex w-full items-center justify-between'>
          {/* App Logo and Name */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3 }}
            exit={{ opacity: 0 }}>
            <AppLogo clickable />
          </motion.div>
          {/* Header Links */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3 }}
            exit={{ opacity: 0 }}
            className='hidden flex-1 lg:block'>
            <div className='flex h-full items-center justify-end gap-6'>
              {headerLinksData.map(({ title, href, ariaLabel }) => (
                <a
                  key={title}
                  className='group text-foreground hover:text-primary relative mx-4 inline-block text-base font-medium transition-all duration-300'
                  href={href}
                  aria-label={ariaLabel}
                  onClick={async () => {
                    await trackButtonClick('header_navigation', undefined, {
                      link_text: title,
                      destination: href,
                      location: 'header_desktop',
                    });
                  }}>
                  <span className='relative z-10'>{title}</span>
                  <span className='bg-primary absolute bottom-0 left-0 h-0.5 w-0 rounded-(--radius) transition-all duration-300 group-hover:w-full' />
                </a>
              ))}
            </div>
          </motion.div>
          {/* Download Button - Desktop */}
          <div className='hidden lg:ml-10 lg:flex lg:items-center lg:gap-4'>
            <CtaButton
              ctaButtonTitle={ctaButtonTitle}
              size='sm'
              onClick={async () => {
                await trackButtonClick('header_cta', undefined, {
                  location: 'header_desktop',
                  destination: ctaButtonLink,
                });
                window.location.href = ctaButtonLink;
              }}
            />
            <ThemeToggle />
          </div>
          {/* Hamburger and Theme Toggle - Mobile Only */}
          <div className='flex items-center gap-4 lg:hidden'>
            <ThemeToggle />
            <HamburgerButton
              isOpen={isOpen}
              setIsOpen={setIsOpen}
            />
          </div>
        </div>
        {/* Mobile Navigation Drawer */}
        <div className='lg:hidden'>
          <Sheet
            open={isOpen}
            onOpenChange={setIsOpen}>
            <SheetContent
              side='right'
              hideClose
              className='border-border bg-background w-[300px] sm:w-[350px]'>
              <nav className='mt-12 flex flex-col gap-4'>
                <SheetClose
                  asChild
                  className='absolute top-4 right-4'>
                  <Button
                    variant='outline'
                    size='icon'
                    aria-label='Close menu'
                    className='border-border hover:bg-accent rounded-(--radius)'>
                    <X className='size-4' />
                  </Button>
                </SheetClose>
                {headerLinksData.map(({ title, href, ariaLabel }) => (
                  <a
                    key={title}
                    href={href}
                    aria-label={ariaLabel}
                    className='group text-foreground hover:text-primary relative p-3 text-center text-lg font-medium transition-all duration-300'
                    onClick={async () => {
                      await trackButtonClick('header_navigation', undefined, {
                        link_text: title,
                        destination: href,
                        location: 'header_mobile_drawer',
                      });
                      setIsOpen(false);
                    }}>
                    <span className='relative z-10'>{title}</span>
                    <span className='bg-primary absolute bottom-0 left-1/2 h-0.5 w-0 -translate-x-1/2 rounded-(--radius) transition-all duration-300 group-hover:w-3/4' />
                  </a>
                ))}
                <div className='mt-4 flex justify-center'>
                  <CtaButton
                    ctaButtonTitle={ctaButtonTitle}
                    className='w-full'
                    onClick={async () => {
                      await trackButtonClick('header_buy_now', undefined, {
                        location: 'header_mobile_drawer',
                        destination: ctaButtonLink,
                      });
                      window.location.href = ctaButtonLink;
                      setIsOpen(false);
                    }}
                  />
                </div>
                <div className='border-border mt-6 hidden border-t pt-6'>
                  <SheetTitle>
                    {/* App Logo and Name */}
                    <AppLogo
                      size='sm'
                      className='justify-center'
                    />
                  </SheetTitle>
                  <SheetDescription className='text-muted-foreground mx-auto text-center'>
                    {/* App Description */}
                    {appDescription}
                  </SheetDescription>
                </div>
              </nav>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  );
};
