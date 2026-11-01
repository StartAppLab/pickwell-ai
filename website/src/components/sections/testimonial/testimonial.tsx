import { motion, useAnimationFrame } from 'motion/react';
import { useRef, useState, useEffect } from 'react';
import { TestimonialCard } from '@/components/sections/testimonial/testimonial-card';
import { testimonialData } from '@/components/sections/testimonial/testimonial-data';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'testimonial',
  subtitle: 'Testimonial',
  title: 'People who love StartAppNotes',
  description:
    'Join thousands of students, professionals, and creatives who organize their thoughts with StartAppNotes.',
  testimonials: testimonialData.testimonials.map(
    ({ name, title, content, image }) => ({
      name,
      title,
      content,
      image,
    })
  ),
};

// Common styles and constants
const CONTENT_CONTAINER = 'mx-auto max-w-screen-xl px-4';
const SCROLL_STYLES = {
  scrollbarWidth: 'none',
  msOverflowStyle: 'none',
  WebkitOverflowScrolling: 'touch',
} as const;
const AUTO_RESUME_DELAY = 2000; // 2 seconds of inactivity before resuming

export const Testimonial = () => {
  const [isPaused, setIsPaused] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const resumeTimeoutRef = useRef<number | null>(null);

  // Duplicate testimonials for seamless infinite loop
  const duplicatedTestimonials = [
    ...sectionConfig.testimonials,
    ...sectionConfig.testimonials,
    ...sectionConfig.testimonials,
  ];

  useAnimationFrame(() => {
    if (!containerRef.current || isPaused) return;

    const scrollSpeed = 0.5;
    containerRef.current.scrollLeft += scrollSpeed;

    const maxScroll = containerRef.current.scrollWidth / 3;
    if (containerRef.current.scrollLeft >= maxScroll) {
      containerRef.current.scrollLeft = 0;
    }
  });

  const handleInteraction = () => {
    setIsPaused(true);
    // Clear existing timeout
    if (resumeTimeoutRef.current) {
      window.clearTimeout(resumeTimeoutRef.current);
    }
    // Set new timeout to resume after inactivity
    resumeTimeoutRef.current = window.setTimeout(() => {
      setIsPaused(false);
    }, AUTO_RESUME_DELAY);
  };

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (resumeTimeoutRef.current) {
        window.clearTimeout(resumeTimeoutRef.current);
      }
    };
  }, []);

  return (
    <section className='bg-background relative w-full py-20 md:py-24'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      {/* Centered header content */}
      <div className={CONTENT_CONTAINER}>
        <MotionWrapper>
          <div className='mb-20 flex flex-col items-center gap-6 text-center'>
            {/* Subtitle */}
            <p className='block-subtitle'>{sectionConfig.subtitle}</p>
            {/* Title */}
            <h2 className='block-big-title px-8'>{sectionConfig.title}</h2>
            {/* Description */}
            <p className='text-muted-foreground max-w-2xl text-lg'>
              {sectionConfig.description}
            </p>
          </div>
        </MotionWrapper>
      </div>

      {/* Mobile: Stacked testimonials (top 3 only) */}
      <div className={`${CONTENT_CONTAINER} md:hidden`}>
        <MotionWrapper>
          <div className='flex flex-col gap-6'>
            {sectionConfig.testimonials
              .slice(0, 3)
              .map((testimonial, index) => (
                <motion.div
                  key={`testimonial-mobile-${index}`}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: index * 0.1 }}>
                  <TestimonialCard testimonial={testimonial} />
                </motion.div>
              ))}
          </div>
        </MotionWrapper>
      </div>

      {/* Desktop: Full-width horizontal scrolling carousel */}
      <div className='relative hidden w-full overflow-hidden md:block'>
        {}
        {/* eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions */}
        <div
          ref={containerRef}
          className='relative overflow-x-auto overflow-y-hidden scroll-smooth py-4 [&::-webkit-scrollbar]:hidden'
          style={SCROLL_STYLES}
          role='region'
          aria-label='Testimonials carousel'
          onMouseEnter={handleInteraction}
          onMouseMove={handleInteraction}
          onTouchStart={handleInteraction}
          onTouchMove={handleInteraction}
          onKeyDown={handleInteraction}
          onFocus={handleInteraction}>
          <div className='testimonial-scroll flex gap-4 px-4 md:gap-6 md:px-8 lg:gap-8'>
            {duplicatedTestimonials.map((testimonial, index) => (
              <motion.div
                key={`testimonial-desktop-${index}`}
                className='flex w-[calc(50%-1rem)] max-w-md shrink-0 lg:w-[calc(33.333%-1.33rem)] xl:w-[calc(33.333%-1.5rem)]'
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{
                  duration: 0.5,
                  delay: (index % sectionConfig.testimonials.length) * 0.1,
                }}>
                <TestimonialCard testimonial={testimonial} />
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};
