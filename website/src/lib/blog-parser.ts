import type { BlogData } from '@/components/sections/blog/blog-data';

interface BlogFrontmatter {
  title: string;
  description: string;
  pubDate: string;
  author?: string;
  image: string;
  tags?: string[];
  categories?: string[];
}

interface BlogModule {
  frontmatter: BlogFrontmatter;
  Content: React.ComponentType;
  url?: string;
}

/**
 * Parses markdown files from blog/content/ directory
 * Uses Astro's built-in markdown support
 */
export class BlogParser {
  /**
   * Formats date string
   */
  private static formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  }

  /**
   * Extracts slug from file path
   */
  static extractSlug(path: string): string {
    const filename = path.split('/').pop() || '';
    return filename.replace('.md', '');
  }

  /**
   * Converts blog module to BlogData
   *
   * NOTE: This parser only extracts and cleans raw markdown text.
   * No formatting, HTML conversion, or styling is applied here.
   * All markdown rendering and styling is handled by react-markdown in the React component.
   */
  static async blogModuleToBlogData(
    module: BlogModule,
    slug: string
  ): Promise<BlogData> {
    // Get raw markdown content as plain text
    const rawContent = await this.getRawMarkdownContent(slug);

    // Remove frontmatter from raw content (returns raw markdown)
    const contentWithoutFrontmatter = this.removeFrontmatter(rawContent);

    // Extract footer text (plain text, not formatted)
    const footer = this.extractFooter(contentWithoutFrontmatter);

    // Remove footer from content (returns raw markdown)
    const contentWithoutFooter = this.removeFooter(contentWithoutFrontmatter);

    // Remove title (H1) and first paragraph from content (returns raw markdown)
    const contentWithoutTitleAndDescription =
      this.removeTitleAndDescription(contentWithoutFooter);

    return {
      title: module.frontmatter.title,
      subtitle: module.frontmatter.description,
      date: this.formatDate(module.frontmatter.pubDate), // Only formats date string, not markdown
      image: module.frontmatter.image,
      content: contentWithoutTitleAndDescription, // Raw markdown string - no formatting applied
      footer: footer, // Plain text string - no formatting applied
      url: `/blog/article/${slug}`,
      tags: module.frontmatter.tags || [],
      categories: module.frontmatter.categories || [],
    };
  }

  /**
   * Removes frontmatter from markdown content
   */
  private static removeFrontmatter(content: string): string {
    const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/;
    const match = content.match(frontmatterRegex);
    return match ? match[2].trim() : content;
  }

  /**
   * Gets raw markdown content for a slug
   */
  private static async getRawMarkdownContent(slug: string): Promise<string> {
    // Validate slug to prevent path traversal and ensure it doesn't contain dangerous characters
    if (slug.includes('/') || slug.includes('\\') || slug.includes('..')) {
      throw new Error(`Invalid slug provided: ${slug}`);
    }

    // Import the markdown file as raw text
    const modules = import.meta.glob<string>('../pages/blog/content/*.md', {
      query: '?raw',
      import: 'default',
      eager: false,
    });

    const found = Object.entries(modules).find(([path]) => {
      return this.extractSlug(path) === slug;
    });

    if (!found) {
      throw new Error(`Blog post not found: ${slug}`);
    }

    const [, module] = found;
    return await module();
  }

  /**
   * Removes title (H1) and first paragraph from markdown content
   */
  private static removeTitleAndDescription(content: string): string {
    const lines = content.split('\n');
    const contentLines: string[] = [];
    let foundH1 = false;
    let skippedFirstParagraph = false;

    for (const line of lines) {
      const trimmedLine = line.trim();

      // Skip H1 heading (starts with #)
      if (trimmedLine.startsWith('# ') && !foundH1) {
        foundH1 = true;
        continue;
      }

      // After finding H1, skip empty lines and the first paragraph
      if (foundH1 && !skippedFirstParagraph) {
        // Skip empty lines
        if (trimmedLine === '') {
          continue;
        }
        // If we hit a heading, we've passed the first paragraph
        if (trimmedLine.startsWith('#')) {
          skippedFirstParagraph = true;
          contentLines.push(line);
        } else {
          // Skip the first paragraph (non-heading, non-empty line)
          continue;
        }
      } else {
        // Include all other lines
        contentLines.push(line);
      }
    }

    return contentLines.join('\n').trim();
  }

  /**
   * Removes footer from markdown content
   */
  private static removeFooter(content: string): string {
    const lines = content.split('\n');
    const contentLines: string[] = [];
    let foundSeparator = false;

    // Remove everything from --- separator onwards (including footer)
    for (const line of lines) {
      const trimmedLine = line.trim();
      if (trimmedLine.startsWith('---') && !foundSeparator) {
        foundSeparator = true;
        // Don't include the separator line
        break;
      }
      if (!foundSeparator) {
        contentLines.push(line);
      }
    }

    return contentLines.join('\n').trim();
  }

  /**
   * Extracts footer from markdown content
   * Footer is content after the --- separator, or the last line if it starts with ~
   */
  private static extractFooter(content: string): string {
    const lines = content.split('\n');
    const footerLines: string[] = [];
    let foundSeparator = false;

    // First, try to find content after --- separator
    for (const line of lines) {
      if (line.trim().startsWith('---')) {
        foundSeparator = true;
        // Start collecting footer content after the separator
        continue;
      }

      // Only collect footer content after the separator
      if (foundSeparator) {
        const trimmedLine = line.trim();
        // Skip empty lines
        if (trimmedLine === '') {
          continue;
        }
        // Collect footer content (everything after ---)
        footerLines.push(trimmedLine);
      }
    }

    // If no separator found, check for footer pattern at the end (starts with ~)
    if (!foundSeparator && lines.length > 0) {
      const reversedLines = [...lines].reverse();
      for (const lineItem of reversedLines) {
        const line = lineItem.trim();
        if (line.startsWith('~')) {
          footerLines.push(line);
          break;
        }
        if (line.length > 0 && !line.startsWith('#')) {
          // Stop if we hit non-empty content that's not a footer
          break;
        }
      }
    }

    // Return footer content, removing markdown formatting
    if (footerLines.length > 0) {
      const footerContent = footerLines
        .map((line) => {
          // Remove italic markdown (*text*)
          if (
            line.startsWith('*') &&
            line.endsWith('*') &&
            !line.startsWith('**')
          ) {
            return line.replace(/^\*|\*$/g, '');
          }
          // Remove bold markdown (**text**)
          if (line.startsWith('**') && line.endsWith('**')) {
            return line.replace(/^\*\*|\*\*$/g, '');
          }
          return line;
        })
        .join(' ')
        .trim();

      // Don't return footer if it's just the default team signature
      if (
        footerContent === 'StartAppNotes Team' ||
        footerContent === '~ StartAppNotes Team'
      ) {
        return '';
      }

      return footerContent;
    }

    return '';
  }

  /**
   * Gets all blog modules
   */
  static async getAllBlogModules(): Promise<Map<string, BlogModule>> {
    const modules = import.meta.glob<BlogModule>('../pages/blog/content/*.md', {
      eager: true,
    });

    const blogMap = new Map<string, BlogModule>();

    for (const [path, module] of Object.entries(modules)) {
      const slug = this.extractSlug(path);
      blogMap.set(slug, module);
    }

    return blogMap;
  }

  /**
   * Gets blog data by slug
   */
  static async getBlogBySlug(slug: string): Promise<BlogData | null> {
    // Validate slug to prevent path traversal or object injection attacks
    if (slug.includes('/') || slug.includes('\\') || slug.includes('..')) {
      console.warn(`Invalid blog slug attempt: ${slug}`);
      return null;
    }

    try {
      const modules = await this.getAllBlogModules();
      const module = modules.get(slug);

      if (!module) {
        return null;
      }

      return await this.blogModuleToBlogData(module, slug);
    } catch (error) {
      console.error(`Error loading blog ${slug}:`, error);
      return null;
    }
  }

  /**
   * Gets all blogs for listing
   */
  static async getAllBlogs(): Promise<BlogData[]> {
    const modules = await this.getAllBlogModules();
    const blogs: BlogData[] = [];

    for (const [slug, module] of modules.entries()) {
      try {
        const blogData = await this.blogModuleToBlogData(module, slug);
        blogs.push(blogData);
      } catch (error) {
        console.error(`Error processing blog ${slug}:`, error);
      }
    }

    // Sort by date (newest first)
    return blogs.sort((a, b) => {
      const dateA = new Date(a.date);
      const dateB = new Date(b.date);
      return dateB.getTime() - dateA.getTime();
    });
  }
}
