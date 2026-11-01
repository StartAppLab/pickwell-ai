import { DownloadAppleButton } from '@/components/shared/download-apple-button';
import { DownloadGoogleButton } from '@/components/shared/download-google-button';

const sectionConfig = {
  sectionId: 'cta',
  content: {
    title: 'Ready to organize your thoughts?',
    description:
      'Download StartAppNotes today and join thousands of students, professionals, and creatives who never lose an idea.',
  },
};

export const Cta = () => {
  return (
    <section className='section-style bg-secondary'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='px-4 text-center md:px-6'>
        <h2 className='block-big-title text-secondary-foreground! mb-4 max-w-2xl!'>
          {sectionConfig.content.title}
        </h2>
        <p className='subheadline text-secondary-foreground! mx-auto mb-8 max-w-2xl!'>
          {sectionConfig.content.description}
        </p>
        <div className='mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center'>
          <DownloadAppleButton size='lg' />
          <DownloadGoogleButton size='lg' />
        </div>
      </div>
    </section>
  );
};
