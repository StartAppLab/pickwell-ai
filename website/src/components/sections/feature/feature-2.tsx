import feature2 from '@/assets/images/feature-2.png';
import { FeatureImage } from '@/components/sections/feature/feature-image';
import { FeatureText } from '@/components/sections/feature/feature-text';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'organize',
  content: {
    subtitle: 'Smart Organization',
    title: 'Find any note in seconds.',
    description:
      'Forget messy notebooks and endless scrolling. Organize notes with folders and tags, then find exactly what you need with powerful search. Your thoughts, always at your fingertips.',
  },
  features: [
    'Folders and nested categories',
    'Tags for flexible organization',
    'Powerful full-text search',
  ],
  image: {
    src: feature2.src,
    label: 'Organized notes with folders and tags',
  },
};

export const Feature2 = () => (
  <section className='section-style bg-background'>
    <div
      className='absolute -top-16'
      id={sectionConfig.sectionId}
    />
    <div className='section-size max-w-screen-lg'>
      <MotionWrapper>
        <div className='flex flex-col items-center lg:flex-row'>
          {/* Feature Image */}
          <div className='order-last w-full lg:order-first lg:w-1/2'>
            <div className='mx-auto w-full sm:w-11/12 md:w-10/12 lg:w-full lg:pr-8'>
              <FeatureImage
                src={sectionConfig.image.src}
                label={sectionConfig.image.label}
              />
            </div>
          </div>

          {/* Feature Text */}
          <div className='mb-8 w-full pr-0 lg:mb-0 lg:w-1/2 lg:pr-20'>
            <FeatureText
              subtitle={sectionConfig.content.subtitle}
              title={sectionConfig.content.title}
              description={sectionConfig.content.description}
              features={sectionConfig.features}
              className='w-full px-4 sm:px-8 md:px-12 lg:px-0'
            />
          </div>
        </div>
      </MotionWrapper>
    </div>
  </section>
);
