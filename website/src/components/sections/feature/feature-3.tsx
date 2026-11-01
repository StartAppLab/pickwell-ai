import feature3 from '@/assets/images/feature-3.png';
import { FeatureImage } from '@/components/sections/feature/feature-image';
import { FeatureText } from '@/components/sections/feature/feature-text';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'sync',
  content: {
    subtitle: 'Seamless Sync',
    title: 'Your notes, everywhere you go.',
    description:
      'Start a note on your phone, continue on your tablet, finish on your laptop. StartAppNotes keeps everything in sync automatically. Your thoughts follow you across all your devices.',
  },
  features: [
    'Automatic cloud sync',
    'Works on iOS and Android',
    'Offline access included',
  ],
  image: {
    src: feature3.src,
    label: 'Sync across all devices',
  },
};

export const Feature3 = () => {
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
