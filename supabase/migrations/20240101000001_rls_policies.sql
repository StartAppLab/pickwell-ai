-- Enable Row Level Security
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.likes enable row level security;
alter table public.follows enable row level security;
alter table public.notifications enable row level security;
alter table public.categories enable row level security;
alter table public.post_categories enable row level security;
alter table public.tags enable row level security;
alter table public.post_tags enable row level security;

-- Profiles policies
create policy "Public profiles are viewable by everyone" on public.profiles
  for select using (true);

create policy "Users can insert their own profile" on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on public.profiles
  for update using (auth.uid() = id);

create policy "Users can delete their own profile" on public.profiles
  for delete using (auth.uid() = id);

-- Posts policies
create policy "Published posts are viewable by everyone" on public.posts
  for select using (status = 'published');

create policy "Users can view their own posts" on public.posts
  for select using (auth.uid() = user_id);

create policy "Users can insert their own posts" on public.posts
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own posts" on public.posts
  for update using (auth.uid() = user_id);

create policy "Users can delete their own posts" on public.posts
  for delete using (auth.uid() = user_id);

-- Comments policies
create policy "Comments are viewable by everyone" on public.comments
  for select using (true);

create policy "Authenticated users can insert comments" on public.comments
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own comments" on public.comments
  for update using (auth.uid() = user_id);

create policy "Users can delete their own comments" on public.comments
  for delete using (auth.uid() = user_id);

-- Likes policies
create policy "Likes are viewable by everyone" on public.likes
  for select using (true);

create policy "Authenticated users can insert likes" on public.likes
  for insert with check (auth.uid() = user_id);

create policy "Users can delete their own likes" on public.likes
  for delete using (auth.uid() = user_id);

-- Follows policies
create policy "Follows are viewable by everyone" on public.follows
  for select using (true);

create policy "Users can insert their own follows" on public.follows
  for insert with check (auth.uid() = follower_id);

create policy "Users can delete their own follows" on public.follows
  for delete using (auth.uid() = follower_id);

-- Notifications policies
create policy "Users can view their own notifications" on public.notifications
  for select using (auth.uid() = user_id);

create policy "Users can update their own notifications" on public.notifications
  for update using (auth.uid() = user_id);

create policy "Users can delete their own notifications" on public.notifications
  for delete using (auth.uid() = user_id);

-- Categories policies
create policy "Categories are viewable by everyone" on public.categories
  for select using (true);

create policy "Admins can manage categories" on public.categories
  for all using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Tags policies
create policy "Tags are viewable by everyone" on public.tags
  for select using (true);

create policy "Authenticated users can insert tags" on public.tags
  for insert with check (auth.uid() is not null);

-- Post categories policies
create policy "Post categories are viewable by everyone" on public.post_categories
  for select using (true);

create policy "Post owners can manage their post categories" on public.post_categories
  for all using (
    exists (
      select 1 from public.posts
      where id = post_id and user_id = auth.uid()
    )
  );

-- Post tags policies
create policy "Post tags are viewable by everyone" on public.post_tags
  for select using (true);

create policy "Post owners can manage their post tags" on public.post_tags
  for all using (
    exists (
      select 1 from public.posts
      where id = post_id and user_id = auth.uid()
    )
  );
