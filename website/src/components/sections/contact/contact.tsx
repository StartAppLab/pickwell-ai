const sectionConfig = {
  sectionId: 'contact',
  content: {
    title: 'Contact Us',
    availableHours: 'Available Hours: Monday - Friday',
    hours: ['8:00 AM - 4:00 PM EST (UTC-5)'],
    socialMediaLinks: [
      {
        name: 'Facebook',
        url: 'https://facebook.com/startapplab',
      },
      {
        name: 'X',
        url: 'https://x.com/startapplab_',
      },
      {
        name: 'Threads',
        url: 'https://www.threads.net/@startapplab',
      },
      {
        name: 'Instagram',
        url: 'https://instagram.com/startapplab',
      },
      {
        name: 'TikTok',
        url: 'https://tiktok.com/@startapplab',
      },
      {
        name: 'YouTube',
        url: 'https://youtube.com/@startapplab_',
      },
      {
        name: 'LinkedIn',
        url: 'https://linkedin.com/company/startapplab',
      },
    ],
  },
  contact: {
    x: 'https://x.com/startapplab_',
    email: 'hello@startapplab.com',
    website: 'https://startapplab.com/contact',
    text: {
      stillHaveQuestions: 'Do you have more questions? Contact us on',
      xLabel: 'X',
      orBy: ' or by ',
      emailLabel: 'email.',
    },
  },
};

export const Contact = () => {
  return (
    <section className='px-4 py-20 md:px-8 md:py-24'>
      <div className='mx-auto max-w-3xl'>
        <h1 className='mb-8 text-4xl font-semibold tracking-tight'>
          {sectionConfig.content.title}
        </h1>

        <div className='space-y-8'>
          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Get in Touch</h2>
            <p className='mb-6'>
              We&apos;d love to hear from you! Whether you have questions about
              our app, need help using the app, want to provide feedback, or
              have feature suggestions, we are here to help.
            </p>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Contact Information</h2>

            <div className='space-y-6'>
              <div>
                <h3 className='mb-2 text-xl font-medium'>Email</h3>
                <p className='mb-1'>
                  All Inquiries & Support:{' '}
                  <a
                    href={`mailto:${sectionConfig.contact.email}`}
                    className='text-primary underline'
                    target='_blank'
                    rel='noopener noreferrer'>
                    {sectionConfig.contact.email}
                  </a>
                </p>
              </div>

              <div>
                <h3 className='mb-2 text-xl font-medium'>Chat</h3>
                <p className='mb-1'>
                  Customer Support:
                  <ul className='list-disc space-y-1 pl-6'>
                    <li>
                      Tell me your concerns on{' '}
                      <a
                        href='https://m.me/139522909248067'
                        className='text-primary underline'
                        target='_blank'
                        rel='noopener noreferrer'>
                        Facebook Messenger
                      </a>
                    </li>
                    <li>
                      Contact me directly on{' '}
                      <a
                        href='https://x.com/startappdev'
                        className='text-primary underline'
                        target='_blank'
                        rel='noopener noreferrer'>
                        X as @startappdev
                      </a>
                    </li>
                  </ul>
                </p>
                <p className='mt-2'>{sectionConfig.content.availableHours}</p>
                <ul className='list-disc space-y-1 pl-6'>
                  {sectionConfig.content.hours.map((hour, index) => (
                    <li key={index}>{hour}</li>
                  ))}
                </ul>
              </div>

              <div>
                <h3 className='mb-2 text-xl font-medium'>Community</h3>
                <p className='mb-1'>
                  Join our community:{' '}
                  <a
                    href={sectionConfig.contact.x}
                    className='text-primary underline'
                    target='_blank'
                    rel='noopener noreferrer'>
                    Follow us on X
                  </a>
                </p>
              </div>
            </div>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Social Media</h2>
            <p className='mb-4'>
              Follow us on social media to stay updated on the latest features,
              updates and other contents:
            </p>
            <ul className='list-disc space-y-1 pl-6'>
              {sectionConfig.content.socialMediaLinks.map((link) => (
                <li key={link.name}>
                  <a
                    href={link.url}
                    className='text-primary underline'
                    target='_blank'
                    rel='noopener noreferrer'>
                    {link.name}
                  </a>
                </li>
              ))}
            </ul>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Response Time</h2>
            <div>
              We strive to respond to all inquiries within 24-48 hours during
              business days. For urgent matters, please contact us on{' '}
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
            </div>
          </section>
        </div>
      </div>
    </section>
  );
};
