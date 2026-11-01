import { AnimatePresence, motion } from 'motion/react';
import { CloseIcon } from '@/assets/icons/close-icon';
import { Subscribe } from '@/components/sections/subscribe/subscribe';
import { Button } from '@/components/ui/button';

export const InvitationModal = ({
  setIsOpen: _setIsOpen,
}: {
  setIsOpen: (isOpen: boolean) => void;
}) => {
  const handleClose = () => {
    _setIsOpen(false);
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, zIndex: 50 }}
        animate={{ opacity: 1, zIndex: 50 }}
        transition={{ duration: 0.1 }}
        exit={{ opacity: 0 }}>
        <div className='popover-background'>
          <div
            className='absolute inset-0'
            onClick={handleClose}
            role='button'
            tabIndex={0}
            aria-label='Close modal'
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                handleClose();
              }
            }}
          />
          <div className='popover max-h-screen overflow-y-auto pb-10'>
            {/* Close Icon */}
            <Button
              variant='outline'
              size='icon'
              className='absolute top-6 right-6 z-50 cursor-pointer'
              aria-label='Close modal'
              onClick={handleClose}>
              <CloseIcon />
            </Button>
            <Subscribe isModal={true} />
          </div>
        </div>
      </motion.div>
    </AnimatePresence>
  );
};
