import { trackButtonClick } from '@/lib/analytics';

interface FooterLinkItem {
  title: string;
  url: string;
}

interface FooterLinkSectionProps {
  title: string;
  items: FooterLinkItem[];
}

export const FooterLinkSection = ({ title, items }: FooterLinkSectionProps) => {
  return (
    <div className='w-auto text-center md:w-1/3 md:text-center lg:w-auto lg:text-left'>
      <h3 className='text-md text-muted-foreground mb-4 font-medium tracking-wide uppercase sm:text-base'>
        {title}
      </h3>
      <ul>
        {items.map((item) => (
          <li
            key={item.title}
            className='mb-4'>
            <a
              className='group text-foreground hover:text-primary relative inline-block transition-all duration-300'
              href={item.url}
              aria-label={item.title}
              onClick={async () => {
                await trackButtonClick('footer_navigation', undefined, {
                  link_text: item.title,
                  destination: item.url,
                  section: title,
                });
              }}
              {...(item.url.startsWith('http')
                ? { target: '_blank', rel: 'noopener noreferrer' }
                : {})}>
              <span className='relative z-10'>{item.title}</span>
              <span className='bg-primary absolute bottom-0 left-0 h-0.5 w-0 rounded-(--radius) transition-all duration-300 group-hover:w-full' />
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
};
