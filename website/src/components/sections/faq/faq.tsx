import { FaqCard } from '@/components/sections/faq/faq-card';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'faq',
  content: {
    subtitle: 'FAQ',
    title: 'Frequently Asked Questions',
    description:
      "Everything you need to know about StartAppNotes. Can't find your answer? Reach out to our support team.",
  },
  faqs: [
    {
      question: 'Is StartAppNotes really free?',
      answer:
        'Yes! The Free plan includes up to 50 notes, 3 folders, checklists, and basic formatting. You can use StartAppNotes completely free with no account required. Upgrade to Pro for unlimited notes, cloud sync, and advanced features.',
    },
    {
      question: 'How does sync work?',
      answer:
        'With Pro, your notes automatically sync across all your devices via secure cloud storage. Start a note on your phone, continue on your tablet. Changes sync instantly when connected to the internet.',
    },
    {
      question: 'Can I use StartAppNotes offline?',
      answer:
        'Absolutely! StartAppNotes works completely offline. Create, edit, and organize notes without an internet connection. When you reconnect, Pro users will have their changes synced automatically.',
    },
    {
      question: 'Is my data private and secure?',
      answer:
        'Your privacy is our priority. Notes are stored locally on your device. Pro users get encrypted cloud sync. We never sell your data or show ads. You own your notes.',
    },
    {
      question: 'What platforms are supported?',
      answer:
        'StartAppNotes is available on iOS (iPhone & iPad) and Android. Download from the App Store or Google Play. Your Pro subscription works across all your devices signed in with the same account.',
    },
  ],
  contact: {
    x: 'https://x.com/startapplab_',
    email: 'hello@startapplab.com',
    contactUsLink: '/contact',
    text: {
      stillHaveQuestions: 'Do you have more questions? Contact us on',
      xLabel: 'X',
      orBy: ' or by ',
      emailLabel: 'email.',
      otherResources: 'You can also check other contact details at',
      contactUsLabel: 'Contact Us',
    },
  },
};

export const Faq = () => {
  return (
    <section className='section-style bg-background'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size max-w-3xl'>
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

            {/* Faqs */}
            <div className='flex flex-col items-center gap-4'>
              {sectionConfig.faqs.map((faq, index) => (
                <div
                  key={`faq-${index}`}
                  className='w-full'>
                  <FaqCard
                    key={`${faq.question}-${faq.answer}`}
                    title={faq.question}
                    content={faq.answer}
                    defaultOpen={index === 0}
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Contact Us */}
          <div className='text-muted-foreground mt-8 text-center text-sm!'>
            <p>
              {sectionConfig.contact.text.stillHaveQuestions}{' '}
              <a
                href={sectionConfig.contact.x}
                target='_blank'
                rel='noopener noreferrer'
                className='text-primary underline'>
                {sectionConfig.contact.text.xLabel}
              </a>
              {sectionConfig.contact.text.orBy}
              <a
                href={`mailto:${sectionConfig.contact.email}`}
                target='_blank'
                rel='noopener noreferrer'
                className='text-primary underline'>
                {sectionConfig.contact.text.emailLabel}
              </a>
            </p>
            <p className='mt-2'>
              {sectionConfig.contact.text.otherResources}{' '}
              <a
                href={sectionConfig.contact.contactUsLink}
                className='text-primary underline'>
                {sectionConfig.contact.text.contactUsLabel}
              </a>
            </p>
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
