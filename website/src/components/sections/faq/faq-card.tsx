import { useState } from 'react';
import { ChevronIcon } from '@/assets/icons/chevron-icon';
import { Card } from '@/components/ui/card';
import { trackButtonClick } from '@/lib/analytics';

export const FaqCard = ({
  defaultOpen,
  title,
  content,
}: {
  defaultOpen: boolean;
  title: string;
  content: string;
}) => {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  return (
    <Card
      className='hover:bg-muted flex cursor-pointer gap-4 px-2 py-0 transition-colors sm:px-4 sm:py-2'
      onClick={async () => {
        if (!isOpen) {
          await trackButtonClick('faq_expand', undefined, {
            question: title,
          });
        }
        setIsOpen(!isOpen);
      }}>
      <div className='mt-4 ml-2 flex flex-1 flex-col items-start gap-4'>
        {/* Question */}
        <h3 className='content-title font-normal!'>{title}</h3>
        {/* Answer */}
        <p
          className={`content-text-muted overflow-hidden transition-all duration-300 ease-in-out ${
            isOpen ? 'mb-4 max-h-96 opacity-100' : 'max-h-0 opacity-0'
          }`}>
          {content}
        </p>
      </div>
      {/* Chevron Icon */}
      <div className='mt-4'>
        <ChevronIcon isOpen={isOpen} />
      </div>
    </Card>
  );
};
