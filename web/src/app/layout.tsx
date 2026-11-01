import '@/app/global.css';
import '@/app/theme.css';

import fs from 'node:fs';
import path from 'node:path';
import type { Metadata } from 'next';
import { ThemeProvider } from 'next-themes';
import { TooltipProvider } from '@/components/ui/tooltip';
import { env } from '@/lib/env';

// Load font configuration from global.css
const globalCssPath = path.resolve(process.cwd(), 'src/app/global.css');
const globalCss = fs.readFileSync(globalCssPath, 'utf-8');
const fontMatch = globalCss.match(/--font-sans:\s*([^,;]+?)(?:,|;)/);
const fontName = fontMatch ? fontMatch[1].replace(/['"]/g, '').trim() : 'Inter';

// System fonts that don't need to be fetched from Google Fonts
const systemFonts = [
  'ui-sans-serif',
  'system-ui',
  '-apple-system',
  'BlinkMacSystemFont',
  'Segoe UI',
  'Helvetica Neue',
  'Arial',
  'sans-serif',
  'Apple Color Emoji',
  'Segoe UI Emoji',
  'Segoe UI Symbol',
  'Noto Color Emoji',
];

const shouldFetchFont = !systemFonts.includes(fontName);
const googleFontUrl = shouldFetchFont
  ? `https://fonts.googleapis.com/css2?family=${encodeURIComponent(fontName)}&display=swap`
  : null;

export const metadata: Metadata = {
  title: 'StartAppLab — SaaS boilerplate',
  description:
    'Feature-first Next.js + Supabase boilerplate with org management, billing, and guards.',
  metadataBase: new URL(env.NEXT_PUBLIC_SITE_URL),
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang='en'
      suppressHydrationWarning>
      <head>
        {/* Google Fonts */}
        {googleFontUrl && (
          <link
            rel='stylesheet'
            href={googleFontUrl}
          />
        )}
        {/* Coloured Brand Icons */}
        <link
          rel='stylesheet'
          href='https://cdn.jsdelivr.net/gh/dheereshag/coloured-icons@1.9.6/app/ci.min.css'
        />
        <style>
          {`
            :root {
              --font-sans: ${fontName}, sans-serif;
            }
            body {
              font-family: var(--font-sans);
            }
          `}
        </style>
      </head>
      <body className='bg-background text-foreground min-h-screen font-sans'>
        <ThemeProvider
          attribute='class'
          defaultTheme='light'
          enableSystem={false}
          disableTransitionOnChange
          storageKey='pickwell-theme'>
          <TooltipProvider delayDuration={150}>{children}</TooltipProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
