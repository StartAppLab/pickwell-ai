import { BlogCard } from '@/components/sections/blog/blog-card';
import type { BlogData } from '@/components/sections/blog/blog-data';
import { MotionWrapper } from '@/components/shared/motion-wrapper';
import { Button } from '@/components/ui/button';
import { trackButtonClick } from '@/lib/analytics';

interface BlogProps {
  blogs: BlogData[];
}

const sectionConfig = {
  sectionId: 'blog',
  content: {
    subtitle: 'Blog',
    title: 'Latest Posts',
    description:
      'Discover tips and insights on note-taking, productivity, and organizing your thoughts beautifully.',
  },
};

export const Blog = ({ blogs }: BlogProps) => {
  // Ensure we have at least one blog
  if (!blogs || blogs.length === 0) {
    return (
      <section className='section-style bg-background pt-32!'>
        <div className='section-size'>
          <MotionWrapper>
            <div className='text-center'>
              <p className='text-muted-foreground'>
                No blog posts available yet.
              </p>
            </div>
          </MotionWrapper>
        </div>
      </section>
    );
  }

  return (
    <section className='section-style bg-background pt-32!'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size'>
        <MotionWrapper>
          <div className='flex flex-col'>
            <div className='mx-auto mb-16 flex flex-col items-center gap-6 text-center lg:mx-0 lg:items-start lg:text-left'>
              {/* Subtitle */}
              <p className='block-subtitle'>{sectionConfig.content.subtitle}</p>
              {/* Title */}
              <h2 className='block-big-title px-8 lg:px-0'>
                {sectionConfig.content.title}
              </h2>
              {/* Description */}
              <p className='text-muted-foreground px-8 lg:px-0'>
                {sectionConfig.content.description}
              </p>
            </div>
            <div className='grid grid-cols-1 gap-6 lg:grid-cols-3'>
              {blogs.slice(0, 3).map((blog, index) => (
                <BlogCard
                  key={`${blog.title}-${index}`}
                  blog={blog}
                />
              ))}
            </div>
            {blogs.length > 3 && (
              <div className='mt-12 flex justify-center'>
                <Button
                  variant='outline'
                  size='lg'
                  onClick={async () => {
                    await trackButtonClick('blog_view_all');
                  }}
                  asChild>
                  <a href='/blog/all'>View All</a>
                </Button>
              </div>
            )}
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
