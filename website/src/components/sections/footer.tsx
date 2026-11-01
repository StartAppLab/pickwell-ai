import { FacebookIcon } from '@/assets/icons/facebook-icon';
import { InstagramIcon } from '@/assets/icons/instagram-icon';
import { LinkedInIcon } from '@/assets/icons/linkedin-icon';
import { ThreadsIcon } from '@/assets/icons/threads-icon';
import { TikTokIcon } from '@/assets/icons/tiktok-icon';
import { XIcon } from '@/assets/icons/x-icon';
import { YouTubeIcon } from '@/assets/icons/youtube-icon';
import { AppLogo } from '@/components/shared/app-logo';
import { BuiltWith } from '@/components/shared/built-with';
import { FooterLinkSection } from '@/components/shared/footer-link-section';
import { trackButtonClick } from '@/lib/analytics';

const appName = 'StartAppNotes';
const appDescription =
  'Capture ideas instantly, organize effortlessly, and sync seamlessly across all your devices. Your thoughts, beautifully organized.';
const copyrightText = `Copyright © ${new Date().getFullYear()} ${appName}. All rights reserved.`;

const socialMediaData = [
  {
    title: 'Facebook',
    url: 'https://facebook.com/startapplab',
    icon: FacebookIcon,
  },
  {
    title: 'X',
    url: 'https://x.com/startapplab_',
    icon: XIcon,
  },
  {
    title: 'Threads',
    url: 'https://www.threads.net/@startapplab',
    icon: ThreadsIcon,
  },
  {
    title: 'Instagram',
    url: 'https://instagram.com/startapplab',
    icon: InstagramIcon,
  },
  {
    title: 'TikTok',
    url: 'https://tiktok.com/@startapplab',
    icon: TikTokIcon,
  },
  {
    title: 'YouTube',
    url: 'https://youtube.com/@startapplab_',
    icon: YouTubeIcon,
  },
  {
    title: 'LinkedIn',
    url: 'https://linkedin.com/company/startapplab',
    icon: LinkedInIcon,
  },
];
const footerLinksData = [
  {
    title: 'Company',
    items: [
      { title: 'About Us', url: '/about' },
      { title: 'Contact Us', url: '/contact' },
      { title: 'Blog', url: '/blog' },
    ],
  },
  {
    title: 'Legal',
    items: [
      { title: 'Terms of Use', url: '/terms' },
      { title: 'Privacy Policy', url: '/privacy' },
      { title: 'Cookie Policy', url: '/cookies' },
    ],
  },
];

export const Footer = () => {
  return (
    <footer
      aria-label='Footer'
      className='footer-style border-border/80 border-t'>
      <div className='footer-size'>
        <div className='flex flex-wrap'>
          <div className='mb-16 w-full lg:mb-0 lg:w-auto'>
            {/* App Logo and Name */}
            <AppLogo
              size='sm'
              className='justify-center lg:justify-start'
            />
            {/* App Description */}
            <p className='sxs:w-64 text-muted-foreground mx-auto my-4 text-center sm:w-[22rem] lg:mx-0 lg:w-80 lg:text-left xl:w-96'>
              {appDescription}
            </p>
            {/* Social Media Icons */}
            <div className='mx-auto mb-5 flex w-full flex-wrap justify-center gap-2 sm:flex-row md:gap-4 lg:mx-0 lg:justify-start'>
              {socialMediaData.map((social) => {
                const Icon = social.icon;
                return (
                  <a
                    key={social.title}
                    className='border-border bg-card text-muted-foreground hover:border-primary/50 hover:bg-primary/10 hover:text-primary flex size-10 items-center justify-center rounded-(--radius) border shadow-sm transition-colors duration-200'
                    href={social.url}
                    aria-label={social.title}
                    target='_blank'
                    rel='noopener noreferrer'
                    onClick={async () => {
                      await trackButtonClick('footer_social', undefined, {
                        platform: social.title,
                        url: social.url,
                        location: 'footer',
                      });
                    }}>
                    <Icon className='size-5' />
                  </a>
                );
              })}
            </div>
            <BuiltWith />
          </div>
          <div className='flex w-full flex-1 flex-col justify-center gap-8 md:flex-row md:gap-16 lg:ml-20 lg:justify-evenly'>
            {/* Footer Links 1 */}
            <FooterLinkSection
              title={footerLinksData[0].title}
              items={footerLinksData[0].items}
            />
            {/* Footer Links 2 */}
            <FooterLinkSection
              title={footerLinksData[1].title}
              items={footerLinksData[1].items}
            />
          </div>
        </div>
        {/* Copyright */}
        <div className='mt-8 pt-6'>
          <p className='text-muted-foreground text-center text-sm'>
            {copyrightText}
          </p>
        </div>
      </div>
    </footer>
  );
};
