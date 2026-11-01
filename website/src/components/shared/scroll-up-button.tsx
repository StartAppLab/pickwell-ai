import { useCallback, useEffect, useRef, useState } from 'react';

export const ScrollUpButton = () => {
  const [isVisible, setIsVisible] = useState(false);
  const ticking = useRef(false);

  // Throttled scroll handler to prevent excessive DOM reads
  const toggleVisible = useCallback(() => {
    if (!ticking.current) {
      window.requestAnimationFrame(() => {
        const scrolled =
          window.pageYOffset || document.documentElement.scrollTop;
        setIsVisible(scrolled > 300);
        ticking.current = false;
      });
      ticking.current = true;
    }
  }, []);

  useEffect(() => {
    // Use passive event listener for better performance
    window.addEventListener('scroll', toggleVisible, { passive: true });

    // Cleanup
    return () => {
      window.removeEventListener('scroll', toggleVisible);
    };
  }, [toggleVisible]);

  const scrollToTop = useCallback(() => {
    // Use requestAnimationFrame for smoother scrolling
    window.requestAnimationFrame(() => {
      window.scrollTo({
        top: 0,
        behavior: 'smooth',
      });
    });
  }, []);

  return (
    <>
      {isVisible && (
        <button
          className='contained-button main-border fixed right-6 bottom-6 z-50 flex size-12 items-center justify-center shadow-lg transition-all duration-300'
          aria-label='Scroll to top'
          onClick={scrollToTop}>
          <svg
            xmlns='http://www.w3.org/2000/svg'
            viewBox='0 0 20 20'
            width='24'
            height='24'
            className='fill-none'>
            <path
              d='M4 12l6-6 6 6'
              className='stroke-primary-foreground'
              strokeWidth='2'
              strokeLinecap='round'
              strokeLinejoin='round'
            />
          </svg>
        </button>
      )}
    </>
  );
};
