begin;
create extension if not exists pgtap with schema extensions;
select plan(17);
insert into auth.users(id, email, raw_user_meta_data) values
  ('10000000-0000-0000-0000-000000000001', 'subscriber@example.com', '{}'),
  ('20000000-0000-0000-0000-000000000002', 'other-subscriber@example.com', '{}');
insert into public.user_entitlements
(user_id, entitlement_id, environment, product_id, is_active, is_non_expiring, expires_at, verified_until) values
('10000000-0000-0000-0000-000000000001', 'active', 'PRODUCTION', 'monthly', true, false, now() + interval '1 day', now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'expired', 'PRODUCTION', 'monthly', true, false, now() - interval '1 day', now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'revoked', 'PRODUCTION', 'monthly', false, false, now() + interval '1 day', now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'lifetime', 'PRODUCTION', 'forever', true, true, null, now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'unknown-expiry', 'PRODUCTION', 'monthly', true, false, null, now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'sandbox', 'SANDBOX', 'monthly', true, true, null, now() + interval '1 hour'),
('10000000-0000-0000-0000-000000000001', 'stale', 'PRODUCTION', 'forever', true, true, null, now() - interval '1 second'),
('20000000-0000-0000-0000-000000000002', 'other', 'PRODUCTION', 'forever', true, true, null, now() + interval '1 hour');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select is((select count(*)::integer from public.user_entitlements), 7, 'Owner sees only own grants');
select ok(public.has_entitlement('active'), 'Active entitlement allows access');
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated","is_anonymous":true}', true);
select ok(not public.has_entitlement('active'), 'Anonymous authenticated identity cannot authorize paid work');
select set_config('request.jwt.claims', '{"sub":"10000000-0000-0000-0000-000000000001","role":"authenticated","is_anonymous":false}', true);
select ok(not public.has_entitlement('expired'), 'Expired entitlement denies access');
select ok(not public.has_entitlement('revoked'), 'Revoked entitlement denies access');
select ok(public.has_entitlement('lifetime'), 'Verified lifetime allows access');
select ok(not public.has_entitlement('unknown-expiry'), 'Missing validity fails closed');
select ok(not public.has_entitlement('sandbox'), 'Sandbox never authorizes production');
select ok(not public.has_entitlement('stale'), 'Stale verification fails closed');
select ok(not public.has_entitlement('other'), 'Another account cannot lend access');
select throws_ok($$update public.user_entitlements set is_active = true$$, '42501', null, 'Client cannot edit grants');
select throws_ok($$delete from public.user_entitlements$$, '42501', null, 'Client cannot delete grants');
select throws_ok($$select public.claim_entitlement_sync(auth.uid(), 0)$$, '42501', null, 'Client cannot claim a sync lease');
select throws_ok($$select * from public.revenuecat_webhook_events$$, '42501', null, 'Client cannot read webhook records');
select throws_ok($$select * from public.entitlement_sync_leases$$, '42501', null, 'Client cannot read sync tokens');
set local role anon;
select throws_ok($$select public.has_entitlement('active')$$, '42501', null, 'Guests cannot authorize paid operations');
reset role;
delete from auth.users where id = '10000000-0000-0000-0000-000000000001';
select is((select count(*)::integer from public.user_entitlements where user_id = '10000000-0000-0000-0000-000000000001'), 0, 'Account deletion clears grants');
select * from finish();
rollback;
