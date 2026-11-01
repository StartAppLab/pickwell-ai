import { QuoteIcon } from '@/assets/icons/quote-icon';
import { StarIcon } from '@/assets/icons/star-icon';
import type { Testimonial } from '@/components/sections/testimonial/testimonial-data';
import { Card } from '@/components/ui/card';

export const TestimonialCard = ({
  testimonial,
}: {
  testimonial: Testimonial;
}) => {
  return (
    <Card className='flex h-full flex-col p-6 md:p-8'>
      {/* Quote Icon */}
      <div className='mb-3 xl:mb-4'>
        <QuoteIcon />
      </div>
      {/* Content */}
      <div className='content-text-muted mb-6 flex-1 leading-relaxed'>
        &quot;{testimonial.content}&quot;
      </div>
      <div className='border-border/50 mt-auto flex items-center gap-4 border-t pt-4'>
        {/* Author Avatar */}
        <div className='ring-primary/20 ring-offset-background flex size-14 items-center justify-center overflow-hidden rounded-full ring-2 ring-offset-2'>
          {testimonial.image ? (
            <img
              src={testimonial.image}
              alt={`${testimonial.name} avatar`}
              width='56px'
              height='56px'
              className='size-full object-cover'
              aria-label={testimonial.name}
              onError={(e) => {
                // Hide image and show fallback on error
                e.currentTarget.style.display = 'none';
                e.currentTarget.nextElementSibling?.classList.remove('hidden');
              }}
            />
          ) : null}
          <div
            className={`bg-primary text-primary-foreground flex size-14 items-center justify-center rounded-full text-base font-semibold ${testimonial.image ? 'hidden' : ''}`}>
            {testimonial.name
              .split(' ')
              .map((n) => n[0])
              .join('')}
          </div>
        </div>
        {/* Author Name, Title and Rating */}
        <div className='flex flex-1 flex-col'>
          <div className='content-title font-semibold'>{testimonial.name}</div>
          <div className='content-text-muted'>{testimonial.title}</div>
          <div className='flex gap-0.5'>
            {[...Array(5)].map((_, i) => (
              <StarIcon
                key={i}
                className='size-5 fill-yellow-500'
              />
            ))}
          </div>
        </div>
      </div>
    </Card>
  );
};
