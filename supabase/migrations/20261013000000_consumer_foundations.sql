-- Protect server-managed roles without changing the consumer profile schema.
revoke update on public.profiles from anon, authenticated;
grant update (username, full_name, avatar_url, bio, website, location)
  on public.profiles to authenticated;
drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile" on public.profiles
  for insert to authenticated with check (auth.uid() = id and role = 'user');

-- Self notifications are allowed; cross-user notifications require a trusted server.
create policy "Users can create their own notifications" on public.notifications
  for insert to authenticated with check (auth.uid() = user_id);

-- Storage configuration is part of migrations, so a fresh checkout is complete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('images', 'images', true, 52428800, array['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('documents', 'documents', false, 52428800, array['application/pdf', 'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain', 'text/csv']),
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = excluded.public,
  file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

-- Replace legacy policies if they were applied manually on an existing project.
drop policy if exists "Images are publicly accessible" on storage.objects;
drop policy if exists "Authenticated users can upload images" on storage.objects;
drop policy if exists "Users can update their own images" on storage.objects;
drop policy if exists "Users can delete their own images" on storage.objects;
drop policy if exists "Users can view their own documents" on storage.objects;
drop policy if exists "Authenticated users can upload documents" on storage.objects;
drop policy if exists "Users can update their own documents" on storage.objects;
drop policy if exists "Users can delete their own documents" on storage.objects;
drop policy if exists "Avatars are publicly accessible" on storage.objects;
drop policy if exists "Users can upload their own avatars" on storage.objects;
drop policy if exists "Users can update their own avatars" on storage.objects;
drop policy if exists "Users can delete their own avatars" on storage.objects;

create policy "Consumer public media" on storage.objects
  for select using (bucket_id in ('images', 'avatars'));
create policy "Consumer own documents" on storage.objects
  for select to authenticated using (
    bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "Consumer upload own files" on storage.objects
  for insert to authenticated with check (
    bucket_id in ('images', 'documents', 'avatars')
    and (storage.foldername(name))[1] = auth.uid()::text
    and exists (select 1 from public.profiles where id = auth.uid())
  );
create policy "Consumer update own files" on storage.objects
  for update to authenticated using (
    bucket_id in ('images', 'documents', 'avatars') and (storage.foldername(name))[1] = auth.uid()::text
  ) with check (
    bucket_id in ('images', 'documents', 'avatars') and (storage.foldername(name))[1] = auth.uid()::text
    and exists (select 1 from public.profiles where id = auth.uid())
  );
create policy "Consumer delete own files" on storage.objects
  for delete to authenticated using (
    bucket_id in ('images', 'documents', 'avatars') and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Restrict the privileged signup trigger's search path.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'username',
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'display_name'),
    new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$;
