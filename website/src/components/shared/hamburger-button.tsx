import { Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';

export const HamburgerButton = ({
  isOpen,
  setIsOpen,
}: {
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}) => {
  return (
    <Button
      variant='outline'
      size='icon'
      aria-label='Hamburger menu'
      className='hover:bg-background rounded-(--radius) p-2 lg:hidden'
      onClick={() => setIsOpen(!isOpen)}>
      <Menu className='size-4' />
    </Button>
  );
};
