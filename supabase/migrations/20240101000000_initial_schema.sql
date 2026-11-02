-- Enable necessary extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- Create custom types
create type user_role as enum ('user', 'admin', 'moderator');
create type post_status as enum ('draft', 'published', 'archived');
create type notification_type as enum ('like', 'comment', 'follow', 'mention');

-- UUID defaults use PostgreSQL 13+ built-ins, independent of extension search_path.
-- Create profiles table (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  username text unique,
  full_name text,
  avatar_url text,
  bio text,
  website text,
  location text,
  role user_role default 'user',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create posts table
create table public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  content text,
  slug text unique not null,
  status post_status default 'draft',
  published_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create comments table
create table public.comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  parent_id uuid references public.comments(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create likes table
create table public.likes (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(post_id, user_id)
);

-- Create follows table
create table public.follows (
  id uuid default gen_random_uuid() primary key,
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(follower_id, following_id)
);

-- Create notifications table
create table public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  type notification_type not null,
  title text not null,
  message text,
  data jsonb,
  read_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create categories table
create table public.categories (
  id uuid default gen_random_uuid() primary key,
  name text unique not null,
  slug text unique not null,
  description text,
  color text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create post_categories junction table
create table public.post_categories (
  post_id uuid references public.posts(id) on delete cascade not null,
  category_id uuid references public.categories(id) on delete cascade not null,
  primary key (post_id, category_id)
);

-- Create tags table
create table public.tags (
  id uuid default gen_random_uuid() primary key,
  name text unique not null,
  slug text unique not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create post_tags junction table
create table public.post_tags (
  post_id uuid references public.posts(id) on delete cascade not null,
  tag_id uuid references public.tags(id) on delete cascade not null,
  primary key (post_id, tag_id)
);

-- Create indexes for better performance
create index posts_user_id_idx on public.posts(user_id);
create index posts_status_idx on public.posts(status);
create index posts_published_at_idx on public.posts(published_at);
create index posts_slug_idx on public.posts(slug);
create index comments_post_id_idx on public.comments(post_id);
create index comments_user_id_idx on public.comments(user_id);
create index comments_parent_id_idx on public.comments(parent_id);
create index likes_post_id_idx on public.likes(post_id);
create index likes_user_id_idx on public.likes(user_id);
create index follows_follower_id_idx on public.follows(follower_id);
create index follows_following_id_idx on public.follows(following_id);
create index notifications_user_id_idx on public.notifications(user_id);
create index notifications_read_at_idx on public.notifications(read_at);

-- Create updated_at trigger function
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

-- Create triggers for updated_at
create trigger handle_updated_at before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at before update on public.posts
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at before update on public.comments
  for each row execute procedure public.handle_updated_at();

-- Create function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger for new user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create function to generate slug
create or replace function public.generate_slug(title text)
returns text as $$
begin
  return lower(regexp_replace(
    regexp_replace(
      regexp_replace(title, '[^a-zA-Z0-9\s-]', '', 'g'),
      '\s+', '-', 'g'
    ),
    '-+', '-', 'g'
  ));
end;
$$ language plpgsql;

-- Create function to auto-generate post slug
create or replace function public.handle_post_slug()
returns trigger as $$
begin
  if new.slug is null or new.slug = '' then
    new.slug = public.generate_slug(new.title);
  end if;
  return new;
end;
$$ language plpgsql;

-- Create trigger for auto-generating post slug
create trigger handle_post_slug before insert on public.posts
  for each row execute procedure public.handle_post_slug();
