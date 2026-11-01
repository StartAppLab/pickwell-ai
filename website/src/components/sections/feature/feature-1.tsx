import feature1 from '@/assets/images/feature-1.png';
import { FeatureImage } from '@/components/sections/feature/feature-image';
import { FeatureText } from '@/components/sections/feature/feature-text';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'features',
  content: {
    subtitle: 'Quick Capture',
    title: 'Capture ideas the moment they strike.',
    description:
      "Great ideas don't wait. With StartAppNotes, jot down thoughts instantly with a single tap. Whether you're in a meeting, on a walk, or lying in bed, your notes are always ready.",
  },
  features: [
    'One-tap note creation',
    'Lightning-fast startup',
    'Never lose an idea again',
  ],
  image: {
    src: feature1.src,
    label: 'Quick capture notes on mobile',
  },
};

export const Feature1 = () => {
  return (
    <section className='section-style bg-background'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size max-w-screen-lg'>
        <MotionWrapper>
          <div className='flex flex-col items-center lg:flex-row'>
            {/* Feature Text */}
            <div className='mb-8 w-full pl-0 lg:mb-0 lg:w-1/2 lg:pl-20'>
              <FeatureText
                subtitle={sectionConfig.content.subtitle}
                title={sectionConfig.content.title}
                description={sectionConfig.content.description}
                features={sectionConfig.features}
                className='w-full px-4 sm:px-8 md:px-12 lg:px-0'
              />
            </div>

            {/* Feature Image */}
            <div className='w-full lg:w-1/2'>
              <div className='mx-auto w-full sm:w-11/12 md:w-10/12 lg:w-full lg:pl-8'>
                <FeatureImage
                  src={sectionConfig.image.src}
                  label={sectionConfig.image.label}
                />
              </div>
            </div>
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
