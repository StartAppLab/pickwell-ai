import { useState, useEffect, useRef } from 'react';
import type { BlogData } from '@/components/sections/blog/blog-data';
import { Card } from '@/components/ui/card';
import { trackButtonClick } from '@/lib/analytics';

export const BlogCard = ({ blog }: { blog: BlogData }) => {
  const [isImageLoading, setIsImageLoading] = useState(true);
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
  }, [blog.image]);

  const handleClick = async () => {
    await trackButtonClick('blog_card_click', undefined, {
      blog_title: blog.title,
      blog_url: blog.url,
      blog_categories: blog.categories?.join(', ') || '',
    });
    // Allow default link navigation
  };

  return (
    <a
      href={blog.url}
      className='group block h-full'
      onClick={handleClick}>
      <Card className='flex h-full min-h-full flex-col overflow-hidden'>
        <div className='relative overflow-hidden'>
          {/* Skeleton Loading */}
          {isImageLoading && (
            <div className='bg-muted absolute inset-0 h-48 w-full animate-pulse sm:h-56 lg:h-64' />
          )}
          {/* Image */}
          <img
            ref={imgRef}
            src={blog.image}
            alt={blog.title}
            aria-label={blog.title}
            loading='lazy'
            className={`h-48 w-full shrink-0 object-cover transition-all duration-300 ease-in-out group-hover:scale-110 sm:h-56 lg:h-64 ${
              isImageLoading ? 'opacity-0' : 'opacity-100'
            }`}
            onLoad={() => setIsImageLoading(false)}
            onError={() => setIsImageLoading(false)}
          />
        </div>
        <div className='flex flex-col gap-2 p-4'>
          <h3 className='blog-card-title wrap-break-words line-clamp-2'>
            {blog.title}
          </h3>
          <p className='blog-card-subtitle wrap-break-words line-clamp-3'>
            {blog.subtitle}
          </p>
        </div>
      </Card>
    </a>
  );
};
