import DOMPurify from 'dompurify';
import { ArrowLeft } from 'lucide-react';
import { useState, useEffect, useRef } from 'react';
import ReactMarkdown, { type Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import type { BlogData } from '@/components/sections/blog/blog-data';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { trackButtonClick } from '@/lib/analytics';

// Define custom renderers for markdown elements
const customComponents: Components = {
  h1: ({ node: _node, children, ...props }) => (
    <h1
      className='mt-20 mb-6 text-2xl leading-tight font-bold sm:text-3xl lg:text-4xl'
      {...props}>
      {children}
    </h1>
  ),
  h2: ({ node: _node, children, ...props }) => (
    <h2
      className='mt-18 mb-5 text-xl leading-tight font-semibold sm:text-2xl lg:text-3xl'
      {...props}>
      {children}
    </h2>
  ),
  h3: ({ node: _node, children, ...props }) => (
    <h3
      className='mt-12 mb-4 text-lg leading-tight font-semibold sm:text-xl lg:text-2xl'
      {...props}>
      {children}
    </h3>
  ),
  h4: ({ node: _node, children, ...props }) => (
    <h4
      className='mt-6 mb-3 text-base leading-tight font-semibold sm:text-lg lg:text-xl'
      {...props}>
      {children}
    </h4>
  ),
  h5: ({ node: _node, children, ...props }) => (
    <h5
      className='mt-6 mb-3 text-sm leading-tight font-semibold sm:text-base lg:text-lg'
      {...props}>
      {children}
    </h5>
  ),
  h6: ({ node: _node, children, ...props }) => (
    <h6
      className='mt-4 mb-2 text-xs leading-tight font-semibold sm:text-sm lg:text-base'
      {...props}>
      {children}
    </h6>
  ),
  p: ({ node: _node, ...props }) => (
    <p
      className='mb-6 text-sm leading-relaxed sm:text-base sm:leading-7'
      {...props}
    />
  ),
  ul: ({ node: _node, ...props }) => (
    <ul
      className='mb-6 ml-6 list-disc space-y-3 text-sm leading-relaxed sm:text-base sm:leading-7'
      {...props}
    />
  ),
  ol: ({ node: _node, ...props }) => (
    <ol
      className='mb-6 ml-6 list-decimal space-y-3 text-sm leading-relaxed sm:text-base sm:leading-7'
      {...props}
    />
  ),
  li: ({ node: _node, ...props }) => (
    <li
      className='pl-2 leading-relaxed'
      {...props}
    />
  ),
  a: ({ node: _node, children, ...props }) => (
    <a
      className='text-primary hover:text-primary/80 underline underline-offset-4 transition-colors'
      target={props.href?.startsWith('http') ? '_blank' : undefined}
      rel={props.href?.startsWith('http') ? 'noopener noreferrer' : undefined}
      {...props}>
      {children}
    </a>
  ),
  code: ({ node: _node, className, ...props }) => {
    const match = /language-(\w+)/.exec(className || '');
    return !match ? (
      <code
        className='bg-muted text-foreground rounded px-2 py-1 font-mono text-sm'
        {...props}
      />
    ) : (
      <code
        className={className}
        {...props}
      />
    );
  },
  pre: ({ node: _node, ...props }) => (
    <pre
      className='bg-muted text-foreground my-6 overflow-x-auto rounded-(--radius) p-5 text-sm leading-relaxed'
      {...props}
    />
  ),
  blockquote: ({ node: _node, ...props }) => (
    <blockquote
      className='border-primary bg-card/50 text-foreground my-6 border-l-4 pr-4 pl-6 leading-relaxed italic'
      {...props}
    />
  ),
  hr: ({ node: _node, ...props }) => (
    <hr
      className='border-border my-10 border-t'
      {...props}
    />
  ),
  img: ({ node: _node, alt, ...props }) => (
    <img
      className='my-8 rounded-(--radius) outline-none'
      loading='lazy'
      alt={alt || ''}
      {...props}
    />
  ),
  strong: ({ node: _node, ...props }) => (
    <strong
      className='font-semibold'
      {...props}
    />
  ),
  em: ({ node: _node, ...props }) => (
    <em
      className='italic'
      {...props}
    />
  ),
  del: ({ node: _node, ...props }) => (
    <del
      className='line-through opacity-70'
      {...props}
    />
  ),
  table: ({ node: _node, ...props }) => (
    <div className='my-8 overflow-x-auto'>
      <table
        className='border-border w-full border-collapse border'
        {...props}
      />
    </div>
  ),
  thead: ({ node: _node, ...props }) => (
    <thead
      className='bg-muted'
      {...props}
    />
  ),
  tbody: ({ node: _node, ...props }) => <tbody {...props} />,
  tr: ({ node: _node, ...props }) => (
    <tr
      className='border-border hover:bg-muted/50 border-b transition-colors'
      {...props}
    />
  ),
  th: ({ node: _node, ...props }) => (
    <th
      className='border-border text-foreground border px-5 py-3 text-left font-semibold'
      {...props}
    />
  ),
  td: ({ node: _node, ...props }) => (
    <td
      className='border-border text-foreground border px-5 py-3'
      {...props}
    />
  ),
  input: ({ node: _node, checked, ...props }) => {
    if (props.type === 'checkbox') {
      return (
        <input
          type='checkbox'
          disabled
          checked={checked}
          className='border-border mt-1.5 size-4 cursor-not-allowed rounded'
          {...props}
        />
      );
    }
    return <input {...props} />;
  },
};

export const BlogDetails = ({ blog }: { blog: BlogData }) => {
  const { title, subtitle, date, image, content, footer, tags, categories } =
    blog;
  const [isImageLoading, setIsImageLoading] = useState(true);
  const [sanitizedFooter, setSanitizedFooter] = useState<string>(footer);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    // Check if image is already loaded (cached)
    const img = imgRef.current;
    if (img) {
      if (img.complete && img.naturalHeight !== 0) {
        requestAnimationFrame(() => setIsImageLoading(false));
      } else {
        // Reset loading state when image src changes
        requestAnimationFrame(() => setIsImageLoading(true));
      }
    }
  }, [image]);

  // Sanitize footer content on client-side mount
  useEffect(() => {
    if (typeof window !== 'undefined' && footer) {
      const sanitized = DOMPurify.sanitize(footer, {
        ALLOWED_TAGS: ['p', 'div', 'br', 'strong', 'em', 'a'],
        ALLOWED_ATTR: ['class', 'href', 'target', 'rel'],
      });
      requestAnimationFrame(() => setSanitizedFooter(sanitized));
    }
  }, [footer]);

  // Handle back navigation based on referrer
  const handleBackClick = async (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();

    await trackButtonClick('blog_back', 'default', {
      blog_title: title,
    });

    if (typeof window === 'undefined') return;

    try {
      const referrer = document.referrer;
      const currentOrigin = window.location.origin;

      // Check if referrer is from the same origin
      if (referrer && referrer.startsWith(currentOrigin)) {
        const referrerUrl = new URL(referrer);
        const referrerPath = referrerUrl.pathname;

        // If came from /blog/all, go back to /blog/all
        if (referrerPath.includes('/blog/all')) {
          window.location.href = '/blog/all';
          return;
        }

        // If came from /blog (but not /blog/article), go back to /blog
        if (referrerPath === '/blog' || referrerPath === '/blog/') {
          window.location.href = '/blog';
          return;
        }

        // If came from another blog article, use browser back
        if (referrerPath.includes('/blog/article/')) {
          window.history.back();
          return;
        }
      }

      // Try browser back (if there's history)
      window.history.back();

      // Fallback after a short delay if back didn't work
      window.setTimeout(() => {
        if (window.location.pathname.includes('/blog/article/')) {
          window.location.href = '/blog';
        }
      }, 100);
    } catch {
      // Fallback: navigate to /blog
      window.location.href = '/blog';
    }
  };

  return (
    <div className='section-style bg-background'>
      <article className='section-size mt-8 p-8 px-4 text-center'>
        {/* Back Button */}
        <div className='mb-6 flex justify-start'>
          <Button
            variant='outline'
            size='default'
            className='h-10 cursor-pointer px-4'
            aria-label='Go back'
            onClick={handleBackClick}>
            <ArrowLeft className='size-4' />
            <span>Back</span>
          </Button>
        </div>
        {/* Image */}
        <div className='relative mx-auto mb-8 w-full overflow-hidden rounded-(--radius) shadow-lg md:w-10/12 lg:w-2/3'>
          {/* Skeleton Loading */}
          {isImageLoading && (
            <div className='bg-muted absolute inset-0 aspect-21/9 w-full animate-pulse' />
          )}
          {/* Image */}
          <img
            ref={imgRef}
            src={image}
            alt={title}
            aria-label={title}
            loading='lazy'
            crossOrigin='anonymous'
            className={`aspect-21/9 w-full object-cover transition-opacity duration-300 ${
              isImageLoading ? 'opacity-0' : 'opacity-100'
            }`}
            onLoad={() => setIsImageLoading(false)}
            onError={() => setIsImageLoading(false)}
          />
        </div>
        <div className='mx-auto mb-12 w-full md:w-10/12 lg:w-2/3'>
          {/* Categories */}
          {categories && categories.length > 0 && (
            <div className='mb-4 flex flex-wrap items-center gap-2'>
              {categories.map((category) => (
                <Badge
                  key={category}
                  variant='default'
                  className='h-8 px-4 text-xs'>
                  {category}
                </Badge>
              ))}
            </div>
          )}
          {/* Title */}
          <h1 className='text-foreground mb-4 text-left text-2xl font-semibold tracking-tight sm:text-3xl lg:text-4xl'>
            {title}
          </h1>
          {/* Date */}
          <div className='blog-label mb-6 text-left'>
            {date.replace(/[<>&"']/g, (char) => {
              switch (char) {
                case '<':
                  return '&lt;';
                case '>':
                  return '&gt;';
                case '&':
                  return '&amp;';
                case '"':
                  return '&quot;';
                case "'":
                  return '&#39;';
                default:
                  return char;
              }
            })}
          </div>
          {/* Subtitle */}
          <h2 className='blog-subheadline text-left'>{subtitle}</h2>
        </div>
        {/* Content */}
        <section
          className='text-foreground mx-auto mb-12 w-full text-left md:w-10/12 lg:w-2/3'
          aria-labelledby='content-title'>
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            components={customComponents}>
            {content}
          </ReactMarkdown>
        </section>
        {/* Footer */}
        {footer && footer.trim() && (
          <div className='mx-auto mb-12 w-full md:w-10/12 lg:w-2/3'>
            <Card className='p-6 shadow-sm md:p-8'>
              <div
                className='text-foreground text-left text-lg leading-relaxed sm:text-xl'
                dangerouslySetInnerHTML={{ __html: sanitizedFooter }}
              />
            </Card>
          </div>
        )}
        {/* Tags */}
        {tags && tags.length > 0 && (
          <div className='mx-auto w-full md:w-10/12 lg:w-2/3'>
            <div className='flex flex-wrap items-center gap-2'>
              {tags.map((tag) => (
                <Badge
                  key={tag}
                  variant='outline'
                  className='h-8 px-4 text-xs'>
                  {tag}
                </Badge>
              ))}
            </div>
          </div>
        )}
      </article>
    </div>
  );
};
