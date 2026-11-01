import { Download, PenLine, Cloud } from 'lucide-react';
import { Step } from '@/components/sections/how-it-works/step';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'how-it-works',
  content: {
    subtitle: 'How It Works',
    title: '3 Simple Steps to Organize Your Thoughts',
    description:
      'Getting started with StartAppNotes is effortless. Download, write, and sync, your notes are always with you.',
  },
  steps: [
    {
      step: 'Step 1',
      icon: <Download className='text-primary size-8' />,
      title: 'Download & Install',
      description:
        'Get StartAppNotes free from the App Store or Google Play. Setup takes just seconds.',
    },
    {
      step: 'Step 2',
      icon: <PenLine className='text-primary size-8' />,
      title: 'Capture Your Ideas',
      description:
        'Tap the + button to create a note. Write, add checklists, and organize with folders and tags.',
    },
    {
      step: 'Step 3',
      icon: <Cloud className='text-primary size-8' />,
      title: 'Sync Everywhere',
      description:
        'Your notes automatically sync to the cloud. Access them from any device, anytime.',
    },
  ],
};

export const HowItWorks = () => {
  return (
    <section className='section-style bg-background'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size max-w-screen-lg'>
        <MotionWrapper>
          <div className='flex flex-col gap-12'>
            <div className='flex flex-col items-center gap-6 text-center'>
              {/* Subtitle */}
              <p className='block-subtitle'>{sectionConfig.content.subtitle}</p>
              {/* Title */}
              <h2 className='block-big-title max-w-3xl'>
                {sectionConfig.content.title}
              </h2>
              {/* Description */}
              <p className='text-muted-foreground max-w-2xl text-lg'>
                {sectionConfig.content.description}
              </p>
            </div>

            {/* Steps */}
            <div className='grid gap-8 md:grid-cols-3'>
              {sectionConfig.steps.map((step, index) => (
                <Step
                  key={index}
                  index={index}
                  {...step}
                />
              ))}
            </div>
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
