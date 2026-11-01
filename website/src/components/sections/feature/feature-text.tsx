import { CheckArrowIcon } from '@/assets/icons/check-arrow-icon';
import { EksArrowIcon } from '@/assets/icons/eks-arrow-icon';
import { cn } from '@/lib/utils';

export const FeatureText = ({
  subtitle,
  title,
  description,
  features,
  children,
  className,
  iconType = 'check',
}: {
  subtitle: string;
  title: string;
  description: string;
  features?: string[];
  children?: React.ReactNode;
  className?: string;
  iconType?: 'check' | 'eks';
}) => {
  const Icon = iconType === 'check' ? CheckArrowIcon : EksArrowIcon;

  return (
    <div className={cn('flex flex-col items-center lg:items-start', className)}>
      {/* Subtitle */}
      <p className='block-subtitle'>{subtitle}</p>

      {/* Title */}
      <h2 className='block-big-title my-6 text-center lg:text-left'>{title}</h2>

      {/* Description */}
      <p className='text-muted-foreground mb-8 text-center lg:text-left'>
        {description}
      </p>

      {/* Features */}
      {features && (
        <ul className='text-foreground'>
          {features.map((feature, index) => (
            <li
              key={`feature-${index}`}
              className='mb-4 flex items-center text-start'>
              <div className='shrink-0'>
                <Icon />
              </div>
              <span>{feature}</span>
            </li>
          ))}
        </ul>
      )}

      {/* Additional Content */}
      {children && <div className='text-center lg:text-left'>{children}</div>}
    </div>
  );
};
