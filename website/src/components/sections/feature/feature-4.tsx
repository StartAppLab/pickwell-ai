import feature4 from '@/assets/images/feature-4.png';
import { FeatureImage } from '@/components/sections/feature/feature-image';
import { FeatureText } from '@/components/sections/feature/feature-text';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'design',
  content: {
    subtitle: 'Beautiful Design',
    title: 'A joy to write in.',
    description:
      'Notes should be a pleasure, not a chore. StartAppNotes features a clean, distraction-free interface with rich text formatting, checklists, and beautiful typography that makes writing enjoyable.',
  },
  features: [
    'Clean, minimal interface',
    'Rich text and markdown support',
    'Dark mode for night owls',
  ],
  image: {
    src: feature4.src,
    label: 'Beautiful notes interface with dark mode',
  },
};

export const Feature4 = () => (
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
