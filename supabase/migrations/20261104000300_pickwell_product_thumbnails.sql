-- T07.1A.1: optional post-publication operator derivative, never an approval grant.
begin;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('product-thumbnails','product-thumbnails',false,65536,array['image/jpeg']) on conflict(id) do nothing;
-- Native resets preserve bucket rows. Reuse only an empty, exactly matching bucket;
-- do not silently repurpose someone else's public/media bucket.
do $$begin
 if not exists(select 1 from storage.buckets where id='product-thumbnails' and name='product-thumbnails'
  and public=false and file_size_limit=65536 and allowed_mime_types=array['image/jpeg'])
  or exists(select 1 from storage.objects where bucket_id='product-thumbnails') then
  raise exception 'Thumbnail bucket must be new or empty and match the private derivative contract';end if;
end;$$;
-- Restrictive policy also defeats an unrelated future permissive Storage policy.
create policy "Pickwell thumbnails server only" on storage.objects as restrictive
 for all to anon,authenticated using(bucket_id<>'product-thumbnails') with check(bucket_id<>'product-thumbnails');
create table public.product_thumbnails (
 id uuid primary key default gen_random_uuid(),
 product_id uuid not null unique references public.products(id) on delete cascade,
 review_id uuid not null references public.product_trust_reviews(id),
 input_digest text not null check(input_digest ~ '^[0-9a-f]{64}$'),
 candidate_digest text not null check(candidate_digest ~ '^[0-9a-f]{64}$'),
 front_digest text not null check(front_digest ~ '^[0-9a-f]{64}$'),
 digest text not null check(digest ~ '^[0-9a-f]{64}$'),
 width integer not null check(width between 1 and 384),height integer not null check(height between 1 and 384),
 bytes integer not null check(bytes between 1 and 65536),
 generator_version text not null default 'front-thumbnail-v1' check(generator_version='front-thumbnail-v1'),
 state text not null default 'uploading' check(state in ('uploading','ready','purging')),
 created_at timestamptz not null default clock_timestamp(),
 object_path text generated always as ('v1/'||id::text||'/'||digest||'.jpg') stored unique
);
alter table public.product_thumbnails enable row level security;
revoke all on public.product_thumbnails from public,anon,authenticated;
grant select on public.product_thumbnails to service_role;
create function public.pickwell_thumbnail_immutable() returns trigger language plpgsql set search_path='' as $$
begin
 if (to_jsonb(new)-array['state','object_path']) is distinct from (to_jsonb(old)-array['state','object_path']) or old.state<>'uploading' or new.state not in ('ready','purging') then
  raise exception 'Thumbnail association is immutable' using errcode='23514';end if;return new;
end;$$;
create trigger pickwell_thumbnail_immutable before update on public.product_thumbnails for each row execute function public.pickwell_thumbnail_immutable();

create function public.pickwell_prepare_thumbnail(p_review uuid,p_barcode text,p_input text,p_candidate text,
 p_front text,p_nutrition text,p_ingredients text,p_digest text,p_width integer,p_height integer,p_bytes integer)
 returns jsonb language plpgsql security definer set search_path='' as $$
declare v public.product_trust_reviews;p public.products;t public.product_thumbnails;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict v from public.product_trust_reviews where id=p_review and state='published' and policy_version='trust-publication-v1';
 if (v.barcode,v.input_digest,v.candidate_digest) is distinct from (public.pickwell_normalize_barcode(p_barcode),p_input,p_candidate)
  or p_front is null or p_front !~ '^[0-9a-f]{64}$' or p_nutrition is null or p_nutrition !~ '^[0-9a-f]{64}$'
  or p_ingredients is null or p_ingredients !~ '^[0-9a-f]{64}$'
  or p_front=p_nutrition or p_front=p_ingredients or p_nutrition=p_ingredients
  or v.input_digest is distinct from encode(sha256(convert_to(v.barcode||'|'||p_front||'|'||p_nutrition||'|'||p_ingredients,'UTF8')),'hex') then
  raise exception 'Exact published evidence required' using errcode='23514';end if;
 select p1.* into strict p from public.products p1 join public.product_analyses a on a.id=p1.current_analysis_id and a.product_id=p1.id
  where p1.barcode=v.barcode and p1.status='ready' and a.provenance#>>'{barcode_association,review_id}'=v.id::text;
 select * into t from public.product_thumbnails where product_id=p.id;
 if found then
  if (t.review_id,t.input_digest,t.candidate_digest,t.front_digest,t.digest,t.width,t.height,t.bytes)
    is distinct from (p_review,p_input,p_candidate,p_front,p_digest,p_width,p_height,p_bytes) or t.state='purging' then
   raise exception 'Existing thumbnail cannot be replaced' using errcode='23514';end if;
 else
  insert into public.product_thumbnails(product_id,review_id,input_digest,candidate_digest,front_digest,digest,width,height,bytes)
   values(p.id,v.id,p_input,p_candidate,p_front,p_digest,p_width,p_height,p_bytes) returning * into t;
 end if;
 return jsonb_build_object('id',t.id,'state',t.state,'object_path',t.object_path,'digest',t.digest,'width',t.width,'height',t.height,'bytes',t.bytes);
end;$$;
create function public.pickwell_commit_thumbnail(p_id uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare t public.product_thumbnails;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict t from public.product_thumbnails where id=p_id;
 if t.state='ready' then return jsonb_build_object('status','ready');end if;
 if t.state<>'uploading' or t.created_at<clock_timestamp()-interval '30 minutes' or not exists(
  select 1 from public.products p join public.product_analyses a on a.id=p.current_analysis_id and a.product_id=p.id
   join public.product_trust_reviews v on v.id=t.review_id and v.state='published'
  where p.id=t.product_id and p.status='ready' and a.provenance#>>'{barcode_association,review_id}'=v.id::text)
  or not exists(select 1 from storage.objects o where o.bucket_id='product-thumbnails' and o.name=t.object_path
   and o.metadata->>'mimetype'='image/jpeg' and o.metadata->>'size'=t.bytes::text) then
  raise exception 'Stored derivative and published association required' using errcode='23514';end if;
 update public.product_thumbnails set state='ready' where id=t.id;
 return jsonb_build_object('status','ready');
end;$$;
-- Claim expired uploads under the same lock before external Storage API deletion.
create function public.pickwell_thumbnail_cleanup() returns jsonb language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(725021003);
 update public.product_thumbnails set state='purging' where id in
  (select id from public.product_thumbnails where state='uploading' and created_at<clock_timestamp()-interval '30 minutes' order by created_at limit 100);
 return (select coalesce(jsonb_agg(item),'[]'::jsonb) from (
  select jsonb_build_object('id',id,'object_path',object_path) as item from public.product_thumbnails where state='purging' limit 100
 ) q);
end;$$;
create function public.pickwell_forget_thumbnail(p_id uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(725021003);
 if exists(select 1 from storage.objects o join public.product_thumbnails t on t.id=p_id and o.name=t.object_path where o.bucket_id='product-thumbnails') then
  raise exception 'Delete via Storage API first' using errcode='23514';end if;
 delete from public.product_thumbnails where id=p_id and state='purging';
end;$$;
-- Orphan keys are UUID-based and never reused by another prepare operation.
create function public.pickwell_thumbnail_orphans() returns jsonb language sql security definer set search_path='' as $$
 select coalesce(jsonb_agg(o.name),'[]'::jsonb) from (select name from storage.objects o
  where bucket_id='product-thumbnails' and created_at<clock_timestamp()-interval '1 hour'
   and not exists(select 1 from public.product_thumbnails t where t.object_path=o.name)
  order by created_at limit 100) o;
$$;
create view public.published_thumbnail_assets with(security_invoker=true) as
 select t.* from public.product_thumbnails t join public.products p on p.id=t.product_id and p.status='ready'
 join public.product_analyses a on a.id=p.current_analysis_id and a.product_id=p.id
 join public.product_trust_reviews v on v.id=t.review_id and v.state='published'
 where t.state='ready' and a.provenance#>>'{barcode_association,review_id}'=v.id::text;
revoke all on public.published_thumbnail_assets from public,anon,authenticated;
grant select on public.published_thumbnail_assets to service_role;
-- Append only; existing projection columns and immutable analyses are unchanged.
create or replace view public.published_products with(security_invoker=true) as
select p.id,p.barcode,p.name,p.brand,p.is_demo,p.published_at,
 a.id as analysis_id,a.schema_version,a.nutrition,a.ingredients,a.summary,
 a.model_version,a.prompt_version,a.rules_version,a.validated_at as analyzed_at,
 (select jsonb_agg(jsonb_build_object('severity',f.severity,'title',f.title,'explanation',f.explanation,
 'source_details',f.source_details,'sort_order',f.sort_order) order by f.sort_order) from public.analysis_findings f where f.analysis_id=a.id) as findings,
 a.explanations,a.missing_information,a.provenance,
 (select jsonb_build_object('id',t.id,'digest',t.digest,'width',t.width,'height',t.height) from public.published_thumbnail_assets t where t.product_id=p.id) as thumbnail
from public.products p join public.product_analyses a on a.product_id=p.id and a.id=p.current_analysis_id where p.status='ready';
revoke all on function public.pickwell_thumbnail_immutable(),public.pickwell_prepare_thumbnail(uuid,text,text,text,text,text,text,text,integer,integer,integer),
 public.pickwell_commit_thumbnail(uuid),public.pickwell_thumbnail_cleanup(),public.pickwell_forget_thumbnail(uuid),public.pickwell_thumbnail_orphans() from public,anon,authenticated;
grant execute on function public.pickwell_prepare_thumbnail(uuid,text,text,text,text,text,text,text,integer,integer,integer),
 public.pickwell_commit_thumbnail(uuid),public.pickwell_thumbnail_cleanup(),public.pickwell_forget_thumbnail(uuid),public.pickwell_thumbnail_orphans() to service_role;
commit;
