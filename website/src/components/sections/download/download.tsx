import { Logo } from '@/assets/logos/logo';
import { DownloadAppleButton } from '@/components/shared/download-apple-button';
import { DownloadGoogleButton } from '@/components/shared/download-google-button';

const sectionConfig = {
  sectionId: 'download',
  content: {
    title: 'Download StartAppNotes',
    description:
      'Capture ideas instantly, organize effortlessly, and sync seamlessly across all your devices',
  },
};

export const Download = () => {
  return (
    <section className='bg-background mx-auto flex min-h-screen max-w-5xl flex-col items-center justify-center px-4 py-16'>
      <div className='flex w-full flex-col items-center gap-4 text-center'>
        <div className='mb-4'>
          <Logo className='size-36' />
        </div>
        <h1 className='headline'>{sectionConfig.content.title}</h1>
        <p className='subheadline font-light!'>
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
