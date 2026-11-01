import type { ReactNode } from 'react';
import { MotionWrapper } from '@/components/shared/motion-wrapper';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';

export interface StepProps {
  icon: ReactNode;
  title: string;
  description: string;
  index: number;
  step?: string;
}

export function Step({ icon, title, description, index, step }: StepProps) {
  return (
    <MotionWrapper
      delay={index * 0.2}
      duration={0.5}>
      <Card className='group flex h-full flex-col items-center p-8 text-center transition-all hover:shadow-md'>
        {/* Step Badge */}
        {step && (
          <Badge
            variant='secondary'
            className='mb-6 px-3 py-1 text-sm'>
            {step}
          </Badge>
        )}
        {/* Icon */}
        <div className='bg-primary/10 mb-6 flex size-16 items-center justify-center rounded-(--radius) transition-transform group-hover:scale-110'>
          {icon}
        </div>
        {/* Title */}
        <h3 className='mb-4 text-base font-semibold lg:text-lg'>{title}</h3>
        {/* Description */}
        <p className='text-muted-foreground leading-relaxed'>{description}</p>
      </Card>
    </MotionWrapper>
  );
}
