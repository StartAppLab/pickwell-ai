// @ts-check
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  adapter: cloudflare({
    platformProxy: {
      enabled: true,
    },

    imageService: 'cloudflare',
  }),

  site: 'https://startapplab.com',
  trailingSlash: 'never',

  vite: {
    plugins: [tailwindcss()],
  },

  integrations: [
    react(),
    sitemap({
      entryLimit: 10000,
      changefreq: 'weekly',
      priority: 0.7,
      lastmod: new Date(),
      // i18n support
      i18n: {
        defaultLocale: 'en',
        locales: {
          en: 'en-US',
          // Add other locales
        },
      },
    }),
  ],

  prefetch: {
    prefetchAll: false,
    defaultStrategy: 'hover',
  },

  srcDir: './src',
  compressHTML: true,
  build: {
    inlineStylesheets: 'auto',
    assets: 'assets',
    format: 'file',
  },

  output: 'static',
});
