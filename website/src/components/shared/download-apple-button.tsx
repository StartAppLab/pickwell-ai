import { useState } from 'react';
import AppleIcon from '@/assets/images/download-apple-icon.svg';
import { InvitationModal } from '@/components/modals/invitation-modal';
import { trackButtonClick } from '@/lib/analytics';
import type { ButtonSize } from '@/types/button';

interface DownloadAppleButtonProps {
  size?: Exclude<ButtonSize, 'icon'>;
  href?: string;
}

const getSizeClass = (size: Exclude<ButtonSize, 'icon'>) => {
  switch (size) {
    case 'sm':
      return 'h-8 w-auto md:h-10';
    case 'lg':
      return 'h-12 w-auto md:h-14';
    case 'default':
    default:
      return 'h-10 w-auto md:h-12';
  }
};

export const DownloadAppleButton = ({
  size = 'default',
  href,
}: DownloadAppleButtonProps) => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleClick = async () => {
    await trackButtonClick('app_store', size);

    if (href) {
      window.open(href, '_blank', 'noopener,noreferrer');
    } else {
      setIsModalOpen(true);
    }
  };

  return (
    <>
      <button
        className='inline-block cursor-pointer transition-transform hover:scale-105'
        aria-label='Download on the App Store'
        onClick={handleClick}>
        <img
          src={AppleIcon.src}
          alt='Download on the App Store'
          className={getSizeClass(size)}
          width={180}
          height={52}
        />
      </button>

      {isModalOpen && <InvitationModal setIsOpen={setIsModalOpen} />}
    </>
  );
};
