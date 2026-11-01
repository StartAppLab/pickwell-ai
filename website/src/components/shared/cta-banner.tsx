import { DownloadAppleButton } from '@/components/shared/download-apple-button';
import { DownloadGoogleButton } from '@/components/shared/download-google-button';

interface CtaBannerProps {
  title?: string;
  description?: string;
}

export const CtaBanner = ({ title, description }: CtaBannerProps) => {
  return (
    <div className='border-border bg-card rounded-(--radius) border p-6'>
      <h2 className='mx-auto mb-4 max-w-2xl! text-center text-2xl font-semibold'>
        {title}
      </h2>
      <p className='mx-auto mb-6 max-w-2xl! text-center'>{description}</p>
      <div className='mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center'>
        <DownloadAppleButton size='lg' />
        <DownloadGoogleButton size='lg' />
      </div>
    </div>
  );
};
