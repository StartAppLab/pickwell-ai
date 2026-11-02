-- Server-only atomic read/charge with bounded replay receipts; never calls a provider.
create table public.lookup_receipts (
 reservation_id uuid primary key references public.usage_reservations(id) on delete cascade,
 status text not null check(status in ('ready','not_found','processing')),
 product_id uuid, analysis_id uuid,
 expires_at timestamptz not null default clock_timestamp()+interval '5 minutes'
);
alter table public.lookup_receipts enable row level security;
revoke all on public.lookup_receipts from public,anon,authenticated;
grant select,insert,delete on public.lookup_receipts to service_role;
create index lookup_receipts_expiry_idx on public.lookup_receipts(expires_at);

create function public.pickwell_get_product(p_user uuid,p_key uuid,p_barcode text)
 returns jsonb language plpgsql set search_path='' as $$
declare code text:=public.pickwell_normalize_barcode(p_barcode); admission jsonb;
 receipt public.lookup_receipts; product jsonb; v_status text; rid uuid;
begin
 perform pg_advisory_xact_lock(725021003);
 if code is null or p_key is null then raise exception 'Invalid lookup' using errcode='22023'; end if;
 -- Receipts are ephemeral references, not copies of label data or credentials.
 delete from public.lookup_receipts where expires_at<=clock_timestamp();
 if p_user is not null then
  admission:=public.pickwell_reserve_usage(p_user,'barcode_lookup',p_key,code);
  if admission->>'status'='quota_exceeded' then return admission; end if;
  rid:=(admission->>'reservation_id')::uuid;
  if admission->>'replay'='true' then
   select * into receipt from public.lookup_receipts where reservation_id=rid;
   if not found then return jsonb_build_object('status','retry_expired'); end if;
   v_status:=receipt.status;
   if v_status='ready' then
    select to_jsonb(p) into product from public.published_products p where p.id=receipt.product_id and p.analysis_id=receipt.analysis_id;
    if product is null then return jsonb_build_object('status','retry_expired'); end if;
   end if;
   return jsonb_build_object('status',v_status,'barcode',code,'product',product,'replay',true,
    'quota',public.pickwell_quota_snapshot(p_user,'barcode_lookup'));
  end if;
  if admission->>'status'<>'reserved' then return jsonb_build_object('status','retry_expired'); end if;
 end if;
 select to_jsonb(p) into product from public.published_products p where p.barcode=code;
 v_status:=case when product is not null then 'ready'
  when exists(select 1 from public.products where barcode=code and status='processing')
    or exists(select 1 from public.analysis_jobs where barcode=code and state in ('queued','processing'))
    or exists(select 1 from public.ai_usage where barcode=code and state in ('inflight','unknown')) then 'processing'
  else 'not_found' end;
 if p_user is not null then
  insert into public.lookup_receipts(reservation_id,status,product_id,analysis_id)
  values(rid,v_status,(product->>'id')::uuid,(product->>'analysis_id')::uuid);
  perform public.pickwell_finish_usage(rid,v_status);
 end if;
 return jsonb_build_object('status',v_status,'barcode',code,'product',product,'replay',false,
  'quota',case when p_user is null then null else public.pickwell_quota_snapshot(p_user,'barcode_lookup') end);
end; $$;
revoke all on function public.pickwell_get_product(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.pickwell_get_product(uuid,uuid,text) to service_role;
