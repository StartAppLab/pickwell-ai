import { motion } from 'motion/react';
import { DownloadAppleButton } from '@/components/shared/download-apple-button';
import { DownloadGoogleButton } from '@/components/shared/download-google-button';

const sectionConfig = {
  sectionId: 'home',
  content: {
    headline: 'Your thoughts, beautifully organized.',
    subheadline:
      'Capture ideas instantly, organize effortlessly, and sync seamlessly across all your devices. StartAppNotes is the simple, elegant notes app that gets out of your way.',
    ctaText: 'Get StartAppNotes for Free',
  },
};

export const Hero = () => {
  return (
    <section
      className='bg-background flex min-h-screen w-full items-center justify-center pt-20 pb-10 lg:py-0 xl:py-48'
      id={sectionConfig.sectionId}>
      <div className='flex w-full max-w-screen-xl flex-col items-center gap-8 px-4'>
        {/* Content */}
        <div className='flex w-full max-w-4xl flex-col items-center text-center'>
          {/* Headline */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.05 }}>
            <h1 className='headline mt-8'>{sectionConfig.content.headline}</h1>
          </motion.div>
          {/* Subheadline */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}>
            <h2 className='subheadline mt-6'>
              {sectionConfig.content.subheadline}
            </h2>
          </motion.div>
          {/* CTA */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.15 }}>
            <div className='mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center'>
              <DownloadAppleButton size='lg' />
              <DownloadGoogleButton size='lg' />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};
