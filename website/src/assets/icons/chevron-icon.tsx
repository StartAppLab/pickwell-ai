export const ChevronIcon = ({ isOpen }: { isOpen: boolean }) => (
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 20 20'
    width='20px'
    height='22px'
    className={`fill-none transition-all duration-300 ${
      isOpen ? 'rotate-0' : 'rotate-180'
    }`}>
    <path
      d='M4.16732 12.5L10.0007 6.66667L15.834 12.5'
      className='stroke-primary'
      strokeWidth='2'
      strokeLinecap='round'
      strokeLinejoin='round'
    />
  </svg>
);
