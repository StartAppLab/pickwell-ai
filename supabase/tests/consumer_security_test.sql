begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

insert into auth.users (id, email, raw_user_meta_data)
values ('10000000-0000-0000-0000-000000000001', 'consumer-test@example.com', '{"full_name":"Consumer"}');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select lives_ok($$update public.profiles set full_name = 'Updated' where id = auth.uid()$$,
  'An owner can edit their profile name');
select throws_ok($$update public.profiles set role = 'admin' where id = auth.uid()$$,
  '42501', null, 'An owner cannot promote their role');
select lives_ok($$insert into storage.objects (bucket_id, name) values
  ('documents', '10000000-0000-0000-0000-000000000001/test.txt')$$,
  'An owner can upload into their own folder');
select throws_ok($$insert into storage.objects (bucket_id, name) values
  ('documents', '20000000-0000-0000-0000-000000000002/test.txt')$$,
  '42501', null, 'A user cannot upload into another folder');
select lives_ok($$insert into public.notifications (user_id, type, title)
  values (auth.uid(), 'mention', 'Self notification')$$, 'A user can create their own notification');
select throws_ok($$insert into public.notifications (user_id, type, title)
  values ('20000000-0000-0000-0000-000000000002', 'mention', 'Other')$$,
  '42501', null, 'A user cannot notify another account directly');
select * from finish();
rollback;
