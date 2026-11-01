import { useState, useMemo, useEffect, useRef } from 'react';
import { BlogCard } from '@/components/sections/blog/blog-card';
import type { BlogData } from '@/components/sections/blog/blog-data';
import { MotionWrapper } from '@/components/shared/motion-wrapper';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { trackButtonClick } from '@/lib/analytics';

interface BlogAllProps {
  blogs: BlogData[];
}

// Predefined categories
// Getting Started: Onboarding and beginner-friendly content
// Note-Taking: Tips and techniques for capturing ideas effectively
// Organization: Strategies for keeping your notes structured and findable
// Productivity: Workflows and habits for getting things done
// News & Updates: Product announcements and new features
const CATEGORIES = [
  'Getting Started',
  'Note-Taking',
  'Organization',
  'Productivity',
  'News & Updates',
] as const;

const sectionConfig = {
  sectionId: 'blog-all',
  content: {
    subtitle: 'All Blogs',
    title: 'Browse Posts',
    description:
      'Explore tips and insights on note-taking, productivity, and organizing your thoughts beautifully.',
    searchPlaceholder: 'Search blog posts...',
    resultsText: 'Showing {current} of {total} posts',
    noResultsText: 'No blog posts found matching your search.',
  },
  pagination: {
    itemsPerPage: 6,
    previousText: 'Prev',
    nextText: 'Next',
  },
  categories: CATEGORIES,
};

const ITEMS_PER_PAGE = sectionConfig.pagination.itemsPerPage;

export const BlogAll = ({ blogs }: BlogAllProps) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [showMoreCategories, setShowMoreCategories] = useState(false);
  const desktopDropdownRef = useRef<HTMLDivElement>(null);
  const mobileDropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: globalThis.MouseEvent) => {
      const desktopClicked = desktopDropdownRef.current?.contains(
        event.target as Node
      );
      const mobileClicked = mobileDropdownRef.current?.contains(
        event.target as Node
      );

      if (!desktopClicked && !mobileClicked) {
        setShowMoreCategories(false);
      }
    };

    if (showMoreCategories) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [showMoreCategories]);

  // Calculate category counts to determine top 3
  const categoryCounts = useMemo(() => {
    const counts = new Map<string, number>();
    blogs.forEach((blog) => {
      if (blog.categories && blog.categories.length > 0) {
        blog.categories.forEach((cat) => {
          counts.set(cat, (counts.get(cat) || 0) + 1);
        });
      }
    });
    return counts;
  }, [blogs]);

  // Get top 3 categories by count
  const topCategories = useMemo(() => {
    return sectionConfig.categories
      .filter((cat) => (categoryCounts.get(cat) || 0) > 0)
      .sort(
        (a, b) => (categoryCounts.get(b) || 0) - (categoryCounts.get(a) || 0)
      )
      .slice(0, 3);
  }, [categoryCounts]);

  // Get remaining categories (not in top 3)
  const remainingCategories = useMemo(() => {
    return sectionConfig.categories.filter(
      (cat) => !topCategories.includes(cat)
    );
  }, [topCategories]);

  // Filter blogs based on search query and category
  const filteredBlogs = useMemo(() => {
    return blogs.filter((blog) => {
      const searchLower = searchQuery.toLowerCase();
      const matchesSearch =
        searchQuery === '' ||
        blog.title.toLowerCase().includes(searchLower) ||
        blog.subtitle.toLowerCase().includes(searchLower) ||
        (blog.tags &&
          blog.tags.some((tag) => tag.toLowerCase().includes(searchLower))) ||
        (blog.categories &&
          blog.categories.some((cat) =>
            cat.toLowerCase().includes(searchLower)
          ));

      // Category filtering
      const matchesCategory =
        selectedCategory === null ||
        (blog.categories && blog.categories.includes(selectedCategory));

      return matchesSearch && matchesCategory;
    });
  }, [blogs, searchQuery, selectedCategory]);

  // Pagination
  const totalPages = Math.ceil(filteredBlogs.length / ITEMS_PER_PAGE);
  const paginatedBlogs = useMemo(() => {
    const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
    return filteredBlogs.slice(startIndex, startIndex + ITEMS_PER_PAGE);
  }, [filteredBlogs, currentPage]);

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <section className='section-style bg-background pt-32!'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size'>
        <MotionWrapper>
          <div className='flex flex-col'>
            <div className='mx-auto mb-16 flex flex-col gap-6 text-center lg:mx-0 lg:text-left'>
              {/* Subtitle */}
              <p className='block-subtitle'>{sectionConfig.content.subtitle}</p>
              {/* Title */}
              <h1 className='block-big-title px-8 lg:px-0'>
                {sectionConfig.content.title}
              </h1>
              {/* Description */}
              <p className='text-muted-foreground px-8 lg:px-0'>
                {sectionConfig.content.description}
              </p>
            </div>

            {/* Search Bar and Category Filters */}
            <div className='mb-8 flex flex-col gap-6 lg:flex-row lg:items-center'>
              {/* Search Bar */}
              <div className='relative w-full lg:max-w-md'>
                <Input
                  type='text'
                  placeholder={sectionConfig.content.searchPlaceholder}
                  value={searchQuery}
                  className='h-12 pl-12 text-left'
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    setCurrentPage(1);
                  }}
                />
                <svg
                  className='text-muted-foreground pointer-events-none absolute top-1/2 left-4 size-5 -translate-y-1/2'
                  fill='none'
                  stroke='currentColor'
                  viewBox='0 0 24 24'>
                  <path
                    strokeLinecap='round'
                    strokeLinejoin='round'
                    strokeWidth={2}
                    d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'
                  />
                </svg>
              </div>

              {/* Category Filter Chips */}
              {sectionConfig.categories.length > 0 && (
                <div className='flex flex-wrap items-center gap-2'>
                  {/* All Posts Chip */}
                  <Button
                    variant={selectedCategory === null ? 'default' : 'outline'}
                    size='sm'
                    className='h-10 cursor-pointer rounded-(--radius) px-6'
                    onClick={async () => {
                      await trackButtonClick('blog_category_filter', 'sm', {
                        category: 'all',
                      });
                      setSelectedCategory(null);
                      setCurrentPage(1);
                    }}>
                    All Posts
                  </Button>

                  {/* Top 3 Categories as Chips */}
                  {topCategories.map((category) => (
                    <Button
                      key={category}
                      variant={
                        selectedCategory === category ? 'default' : 'outline'
                      }
                      size='sm'
                      className='h-10 cursor-pointer rounded-(--radius) px-6'
                      onClick={async () => {
                        await trackButtonClick('blog_category_filter', 'sm', {
                          category: category,
                        });
                        setSelectedCategory(category);
                        setCurrentPage(1);
                      }}>
                      {category}
                    </Button>
                  ))}

                  {/* More Categories Dropdown */}
                  {remainingCategories.length > 0 && (
                    <div
                      ref={desktopDropdownRef}
                      className='relative'>
                      <Button
                        variant={
                          selectedCategory &&
                          remainingCategories.includes(
                            selectedCategory as (typeof remainingCategories)[number]
                          )
                            ? 'default'
                            : 'outline'
                        }
                        size='sm'
                        className='h-10 cursor-pointer rounded-(--radius) px-6'
                        onClick={async () => {
                          await trackButtonClick('blog_category_filter', 'sm', {
                            action: 'toggle_dropdown',
                          });
                          setShowMoreCategories(!showMoreCategories);
                        }}>
                        <span>
                          {selectedCategory &&
                          remainingCategories.includes(
                            selectedCategory as (typeof remainingCategories)[number]
                          )
                            ? selectedCategory
                            : 'More Categories'}
                        </span>
                        <svg
                          className={`size-4 transition-transform ${showMoreCategories ? 'rotate-180' : ''}`}
                          fill='none'
                          stroke='currentColor'
                          viewBox='0 0 24 24'>
                          <path
                            strokeLinecap='round'
                            strokeLinejoin='round'
                            strokeWidth={2}
                            d='M19 9l-7 7-7-7'
                          />
                        </svg>
                      </Button>
                      {showMoreCategories && (
                        <div className='bg-popover text-popover-foreground border-border absolute top-full right-0 z-50 mt-2 w-48 overflow-hidden rounded-(--radius) border p-1 shadow-md'>
                          {remainingCategories.map((category) => (
                            <button
                              key={category}
                              className={`w-full cursor-pointer rounded-(--radius) px-3 py-2 text-left text-sm transition-colors ${
                                selectedCategory === category
                                  ? 'bg-accent text-accent-foreground'
                                  : 'hover:bg-accent hover:text-accent-foreground text-popover-foreground'
                              }`}
                              onClick={async () => {
                                await trackButtonClick(
                                  'blog_category_filter',
                                  undefined,
                                  {
                                    category: category,
                                    source: 'dropdown',
                                  }
                                );
                                setSelectedCategory(category);
                                setCurrentPage(1);
                                setShowMoreCategories(false);
                              }}>
                              {category}
                            </button>
                          ))}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Results Count */}
            {filteredBlogs.length > 0 && (
              <p className='text-muted-foreground mb-6 text-sm italic'>
                {sectionConfig.content.resultsText
                  .replace('{current}', paginatedBlogs.length.toString())
                  .replace('{total}', filteredBlogs.length.toString())}
              </p>
            )}

            {/* Blog Grid */}
            {paginatedBlogs.length > 0 ? (
              <>
                <div className='grid grid-cols-1 gap-6 lg:grid-cols-3'>
                  {paginatedBlogs.map((blog, index) => (
                    <BlogCard
                      key={`${blog.title}-${index}`}
                      blog={blog}
                    />
                  ))}
                </div>

                {/* Pagination */}
                {totalPages > 1 && (
                  <div className='mt-16 flex items-center justify-center gap-2'>
                    <Button
                      variant='outline'
                      size='default'
                      className='cursor-pointer'
                      disabled={currentPage === 1}
                      onClick={async () => {
                        await trackButtonClick('blog_pagination', 'default', {
                          direction: 'prev',
                          to_page: currentPage - 1,
                        });
                        handlePageChange(currentPage - 1);
                      }}>
                      {sectionConfig.pagination.previousText}
                    </Button>
                    <div className='flex items-center gap-1'>
                      {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                        (page) => (
                          <Button
                            key={page}
                            variant={
                              currentPage === page ? 'default' : 'outline'
                            }
                            size='icon'
                            className='h-10 w-10 cursor-pointer md:h-12 md:w-12 md:text-lg'
                            onClick={async () => {
                              await trackButtonClick(
                                'blog_pagination',
                                'default',
                                {
                                  to_page: page,
                                }
                              );
                              handlePageChange(page);
                            }}>
                            {page}
                          </Button>
                        )
                      )}
                    </div>
                    <Button
                      variant='outline'
                      size='default'
                      className='cursor-pointer'
                      disabled={currentPage === totalPages}
                      onClick={async () => {
                        await trackButtonClick('blog_pagination', 'default', {
                          direction: 'next',
                          to_page: currentPage + 1,
                        });
                        handlePageChange(currentPage + 1);
                      }}>
                      {sectionConfig.pagination.nextText}
                    </Button>
                  </div>
                )}
              </>
            ) : (
              <div className='py-12 text-center'>
                <p className='text-muted-foreground'>
                  {sectionConfig.content.noResultsText}
                </p>
              </div>
            )}
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
