-- Insert sample posts (these will be created after users are created)
-- Note: This is a template that should be run after user creation

-- Sample post 1: Getting Started with Supabase
insert into public.posts (user_id, title, content, slug, status, published_at) values
  (
    (select id from auth.users limit 1), -- Replace with actual user ID
    'Getting Started with Supabase',
    'Supabase is an open-source Firebase alternative that provides a PostgreSQL database, authentication, real-time subscriptions, and storage. In this post, we''ll explore how to set up a new Supabase project and integrate it with your application.

## What is Supabase?

Supabase is a backend-as-a-service platform that gives you:
- A PostgreSQL database with real-time subscriptions
- Authentication and user management
- File storage
- Edge functions
- Auto-generated APIs

## Setting Up Your Project

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key
3. Install the Supabase client library
4. Configure your environment variables

## Next Steps

Once you have your project set up, you can start building your application with features like:
- User authentication
- Real-time data synchronization
- File uploads
- Database queries

Happy coding!',
    'getting-started-with-supabase',
    'published',
    now()
  );

-- Sample post 2: Building a Full-Stack App with Next.js
insert into public.posts (user_id, title, content, slug, status, published_at) values
  (
    (select id from auth.users limit 1), -- Replace with actual user ID
    'Building a Full-Stack App with Next.js',
    'Next.js is a powerful React framework that makes it easy to build full-stack applications. In this tutorial, we''ll create a complete application with authentication, database integration, and deployment.

## Why Next.js?

Next.js provides:
- Server-side rendering (SSR)
- Static site generation (SSG)
- API routes
- Built-in optimization
- Easy deployment

## Project Structure

```
startapplab-template/
├── pages/
│   ├── api/
│   ├── _app.js
│   └── index.js
├── components/
├── lib/
└── styles/
```

## Key Features

- Authentication with NextAuth.js
- Database with Prisma
- Styling with Tailwind CSS
- Deployment on Vercel

This combination provides a robust foundation for modern web applications.',
    'building-fullstack-app-nextjs',
    'published',
    now()
  );

-- Sample post 3: Flutter Mobile Development Tips
insert into public.posts (user_id, title, content, slug, status, published_at) values
  (
    (select id from auth.users limit 1), -- Replace with actual user ID
    'Flutter Mobile Development Tips',
    'Flutter is Google''s UI toolkit for building natively compiled applications for mobile, web, and desktop. Here are some essential tips for Flutter development.

## Performance Tips

1. **Use const constructors** - They help Flutter optimize widget rebuilds
2. **Implement proper state management** - Consider Provider, Riverpod, or Bloc
3. **Optimize images** - Use appropriate image formats and sizes
4. **Lazy load lists** - Use ListView.builder for large datasets

## Best Practices

- Follow the Material Design guidelines
- Use meaningful widget names
- Implement proper error handling
- Write unit and widget tests
- Use code generation tools like json_annotation

## Common Pitfalls

- Not disposing of controllers properly
- Overusing setState in StatefulWidget
- Not handling platform differences
- Ignoring accessibility guidelines

With these tips, you''ll be well on your way to building high-quality Flutter applications.',
    'flutter-mobile-development-tips',
    'published',
    now()
  );
