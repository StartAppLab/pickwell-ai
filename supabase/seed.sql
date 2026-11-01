-- Consumer starter sample content. Keep this file plain SQL for the Supabase CLI.
-- Insert default categories
insert into public.categories (name, slug, description, color) values
  ('Technology', 'technology', 'Posts about technology, programming, and software development', '#3B82F6'),
  ('Design', 'design', 'Posts about UI/UX design, graphic design, and visual arts', '#8B5CF6'),
  ('Business', 'business', 'Posts about entrepreneurship, startups, and business strategies', '#10B981'),
  ('Lifestyle', 'lifestyle', 'Posts about personal development, health, and lifestyle tips', '#F59E0B'),
  ('Education', 'education', 'Posts about learning, tutorials, and educational content', '#EF4444'),
  ('News', 'news', 'Latest news and updates from around the world', '#6B7280'),
  ('Entertainment', 'entertainment', 'Posts about movies, music, games, and entertainment', '#EC4899'),
  ('Science', 'science', 'Posts about scientific discoveries, research, and innovations', '#14B8A6');
-- Insert popular tags
insert into public.tags (name, slug) values
  ('javascript', 'javascript'),
  ('typescript', 'typescript'),
  ('react', 'react'),
  ('nextjs', 'nextjs'),
  ('nodejs', 'nodejs'),
  ('python', 'python'),
  ('flutter', 'flutter'),
  ('dart', 'dart'),
  ('supabase', 'supabase'),
  ('postgresql', 'postgresql'),
  ('tailwindcss', 'tailwindcss'),
  ('ui', 'ui'),
  ('ux', 'ux'),
  ('design', 'design'),
  ('mobile', 'mobile'),
  ('web', 'web'),
  ('api', 'api'),
  ('database', 'database'),
  ('authentication', 'authentication'),
  ('deployment', 'deployment'),
  ('tutorial', 'tutorial'),
  ('tips', 'tips'),
  ('beginner', 'beginner'),
  ('advanced', 'advanced'),
  ('open-source', 'open-source');
