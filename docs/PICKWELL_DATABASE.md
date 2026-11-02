# PICKWELL AI V2 — SUPABASE DATABASE & BACKEND DATA DESIGN

**Version:** 1.0 · **Date:** 2026-11-02 · **Repository:** `pickwell-ai`  
**Source of truth:** `PICKWELL_PRD.md` v1.4, `PICKWELL_DESIGN.md` v1.2, `PICKWELL_SPEC.md` v1.2.  
**Status:** Implementation blueprint, **not deployed SQL**. Migration and deployment require verification against the actual project, schema linting and transactional tests.  
**Goal:** Shared barcode product catalog, authenticated Meta AI contributions, server-enforced adjustable daily quotas, RevenueCat-ready Premium entitlements, no active purchase flow.

## 1. Product rules / schema invariants

1. Guest may scan barcodes and view only validated published product data; **new AI analysis requires verified Supabase Email OTP sign-in**.
2. One canonical barcode resolves to at most one public current product record; repeated lookup uses cached data **without AI**.
3. For unknown barcode, photos of nutrition facts and ingredients are submitted as one analysis attempt. Success publishes validated extracted text, nutrition and color-coded findings; failure requests retake and **does not consume a successful-analysis quota credit**.
4. Server-side config starts Free at **30 barcode lookups/day** and **3 successful new-product AI analyses/day**. Change config without app release. Guest 30/day is a *fair-use target*, not a verifiable per-person allowance: implement IP/proxy-aware throttling separately.
5. Premium is **backend-ready only**, with RevenueCat as future billing provider. No checkout, price, paywall or live billing during hackathon. Future Premium limits are not yet defined.
6. **No privileged DB keys, Meta credentials, RevenueCat webhook secrets or write permission in Flutter.** Published content is exposed only through controlled Edge Function responses.
7. Label images are temporary: discard on successful extraction; delete failed/abandoned temporary images by expiration job; never persist image bytes to analytics or public product rows.

## 2. Entity inventory

| Entity/table | Primary fields | Constraints / responsibility | Client access |
|---|---|---|---|
| `products` | `id`, `barcode`, `name?`, `brand?`, `status`, `current_analysis_id?`, `created_at`, `updated_at` | Unique canonical barcode; `ready` only with validated analysis | Via `get-product` only |
| `product_analyses` | `id`, `product_id`, `nutrition jsonb`, `ingredients jsonb`, `summary`, `model_version`, `rules_version`, `validated_at`, `created_at` | Immutable published revisions; evidence and units preserved | Via `get-product` only |
| `analysis_findings` | `id`, `analysis_id`, `severity`, `title`, `explanation`, `source_details jsonb`, `sort_order` | Enum green/yellow/red; grounded claims | Via `get-product` only |
| `analysis_jobs` | `id`, `barcode`, `user_id`, `idempotency_key`, `state`, `attempts`, `lease_expires_at`, `error_code`, `created_at`, `updated_at` | Unique `(user_id,idempotency_key)`; claim/lease coordinates concurrent processing | Owner-scoped Edge Function only |
| `plans` | `code`, `display_name`, `enabled` | `free`, `premium`; premium not purchasable initially | Read via entitlement API |
| `plan_limits` | `plan_code`, `metric`, `daily_limit`, `effective_at`, `updated_at` | Configurable without Flutter update; positive daily limits | Server-only |
| `user_entitlements` | `user_id`, `plan_code`, `source`, `valid_from`, `valid_until`, `status`, `updated_at` | No client grant; active and unexpired only | Server-only |
| `usage_daily` | `user_id`, `day_utc`, `metric`, `used`, `reserved` | Unique user/day/metric; atomic quota operations | Owner status via Edge Function |
| `usage_reservations` | `id`, `user_id`, `metric`, `day_utc`, `idempotency_key`, `state`, `job_id?`, `lease_expires_at` | Unique `(user_id,metric,idempotency_key)`; exactly-once finalization/release | Server-only |
| `ai_usage` | `id`, `user_id?`, `job_id?`, `model`, `input_tokens?`, `output_tokens?`, `estimated_cost_usd?`, `outcome`, `created_at` | Tracks actual provider spend independent of user credit | Server/admin-only |
| `revenuecat_customers` | `user_id`, `app_user_id`, `environment`, `updated_at` | Stable mapping: RevenueCat App User ID = Supabase Auth UUID after login | Server/admin-only |
| `revenuecat_events` | `event_id`, `event_type`, `environment`, `app_user_id`, `occurred_at`, `received_at`, `processing_state`, `sanitized_payload jsonb` | Idempotency, reconciliation, audit | Server/admin-only |
| `operational_events` (optional) | `id`, `event_type`, `created_at`, `duration_ms?`, `context jsonb` | Restrict retention/identifiers; no images/tokens/emails | Server/admin-only |

**User accounts** remain managed by `auth.users`; references use `auth.users(id)` with `on delete cascade` when appropriate. Do not copy OTP codes or auth secrets into app tables. Deleting an account must clear user-specific usage/account mapping while retaining published, non-personal product facts as needed under the privacy policy.

## 3. Initial migration shape (illustrative SQL, adapt and test)

SQL below communicates core contracts; **do not paste directly into production as a complete security migration**. Complete triggers/functions/grants, composite FK sequencing and rollbacks must be implemented in migrations and tested.

```sql
create type public.product_status as enum ('processing','ready','invalidated');
create type public.finding_severity as enum ('green','yellow','red');
create type public.usage_metric as enum ('barcode_lookup','ai_analysis');
create type public.reservation_state as enum ('reserved','consumed','released','expired');

create table public.plans (
  code text primary key check (code in ('free','premium')),
  display_name text not null,
  enabled boolean not null default true
);

create table public.plan_limits (
  plan_code text not null references public.plans(code),
  metric public.usage_metric not null,
  daily_limit integer not null check (daily_limit >= 0),
  effective_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (plan_code, metric)
);

insert into public.plans(code,display_name) values
 ('free','Free'), ('premium','Premium');
insert into public.plan_limits(plan_code,metric,daily_limit) values
 ('free','barcode_lookup',30), ('free','ai_analysis',3);
-- Do not seed guessed Premium limits. Resolver must refuse to grant
-- premium-specific allowances until plan_limits are explicitly configured.

create table public.products (
 id uuid primary key default gen_random_uuid(),
 barcode text not null unique,
 name text,
 brand text,
 status public.product_status not null default 'processing',
 current_analysis_id uuid,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check (barcode ~ '^[0-9]{8,14}$')
);

create table public.product_analyses (
 id uuid primary key default gen_random_uuid(),
 product_id uuid not null references public.products(id) on delete cascade,
 nutrition jsonb not null,
 ingredients jsonb not null,
 summary text not null,
 model_version text not null,
 rules_version text not null,
 validated_at timestamptz not null,
 created_at timestamptz not null default now(),
 check (jsonb_typeof(nutrition) = 'object'),
 check (jsonb_typeof(ingredients) = 'object')
);

-- Add FK after both tables exist. A commit/publish transaction should
-- verify current_analysis_id belongs to this products.id (service-side/RPC).
alter table public.products add constraint products_current_analysis_fk
 foreign key (current_analysis_id) references public.product_analyses(id);

create table public.analysis_findings (
 id uuid primary key default gen_random_uuid(),
 analysis_id uuid not null references public.product_analyses(id) on delete cascade,
 severity public.finding_severity not null,
 title text not null,
 explanation text not null,
 source_details jsonb not null default '{}'::jsonb,
 sort_order integer not null default 0
);
create index analysis_findings_analysis_idx on public.analysis_findings(analysis_id,sort_order);

create table public.user_entitlements (
 user_id uuid primary key references auth.users(id) on delete cascade,
 plan_code text not null references public.plans(code),
 source text not null check (source in ('admin_test','revenuecat')),
 valid_from timestamptz not null default now(),
 valid_until timestamptz,
 status text not null check (status in ('active','expired','revoked')),
 updated_at timestamptz not null default now()
);

create table public.usage_daily (
 user_id uuid not null references auth.users(id) on delete cascade,
 day_utc date not null,
 metric public.usage_metric not null,
 used integer not null default 0 check (used >= 0),
 reserved integer not null default 0 check (reserved >= 0),
 primary key(user_id,day_utc,metric)
);

create table public.analysis_jobs (
 id uuid primary key default gen_random_uuid(),
 barcode text not null,
 user_id uuid not null references auth.users(id) on delete cascade,
 idempotency_key uuid not null,
 state text not null check (state in ('queued','processing','needs_retake','ready','failed','cancelled')),
 attempts integer not null default 0 check (attempts >= 0),
 lease_expires_at timestamptz,
 error_code text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(user_id,idempotency_key)
);
create index analysis_jobs_barcode_idx on public.analysis_jobs(barcode,state);

create table public.usage_reservations (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 metric public.usage_metric not null,
 day_utc date not null,
 idempotency_key uuid not null,
 state public.reservation_state not null default 'reserved',
 job_id uuid references public.analysis_jobs(id) on delete set null,
 lease_expires_at timestamptz,
 created_at timestamptz not null default now(),
 unique(user_id,metric,idempotency_key)
);

create table public.ai_usage (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references auth.users(id) on delete set null,
 job_id uuid references public.analysis_jobs(id) on delete set null,
 model text not null,
 input_tokens bigint,
 output_tokens bigint,
 estimated_cost_usd numeric(12,6),
 outcome text not null,
 created_at timestamptz not null default now()
);

create table public.revenuecat_customers (
 user_id uuid primary key references auth.users(id) on delete cascade,
 app_user_id text not null unique,
 environment text not null check(environment in ('SANDBOX','PRODUCTION')),
 updated_at timestamptz not null default now()
);
create table public.revenuecat_events (
 event_id text primary key,
 event_type text not null,
 environment text not null,
 app_user_id text,
 occurred_at timestamptz,
 received_at timestamptz not null default now(),
 processing_state text not null default 'received',
 sanitized_payload jsonb not null default '{}'::jsonb
);
```

**Barcode normalization:** Validate EAN/UPC lengths and check digits in backend logic. Decide on a canonical UPC/EAN representation (e.g., convert UPC-A to EAN-13 consistently or preserve normalized prefix mapping) and test barcode alias collisions before live data import. The length-only SQL check is a secondary safety net, not full validation.

**Analysis JSON:** Define versioned extraction schema in SPEC with `value`, `unit`, `basis` (per serving vs per 100 g/mL), source text span/field, and confidence/unknown. `ingredients` should contain ordered raw label names and source metadata, not automatically inferred allergen absences. Split into normalized tables later if reporting needs justify them.

## 4. RLS and privilege design

Every public-schema table above **must enable RLS**. Use no direct authenticated or anonymous write policies for shared catalog, jobs, quotas, entitlements, webhook records or audit logs. Prefer no direct client SELECT policies either; use controlled Edge Functions for sanitized published results.

```sql
alter table public.products enable row level security;
alter table public.product_analyses enable row level security;
alter table public.analysis_findings enable row level security;
alter table public.analysis_jobs enable row level security;
alter table public.plans enable row level security;
alter table public.plan_limits enable row level security;
alter table public.user_entitlements enable row level security;
alter table public.usage_daily enable row level security;
alter table public.usage_reservations enable row level security;
alter table public.ai_usage enable row level security;
alter table public.revenuecat_customers enable row level security;
alter table public.revenuecat_events enable row level security;
-- ALSO revoke any pre-existing privileges/policies, and check table grants.
-- No public policy means browser/mobile anonymous and authenticated DB
-- clients cannot directly read/write; Edge Functions use restricted
-- service-side credentials after validating their own request rules.
```

**Important:** RLS is not sufficient if service-role privileges are leaked. Edge Functions use service secrets privately, and every public request gets explicit app-level authorization and validation. `get-product` exposes only published-safe data and runs bounded rate limits. `analyze-product` requires verified Auth JWT/email plus quotas. `get-analysis-status` returns only the requesting user's job. `revenuecat-webhook` checks RevenueCat origin before any privileged operation. Do not build SQL SECURITY DEFINER functions owned by an over-privileged role without fixed `search_path`, explicit grants and dedicated tests.

## 5. Quota resolution and atomic consumption

**Source:** `plan_limits` is the one editable source of quota values. Seed Free `barcode_lookup=30`, `ai_analysis=3`. Decreasing Free lookups to 20 requires an authorized database update; the next API response returns limit 20. If `used=25`, `remaining=0` and further lookups fail until UTC day rollover. No Flutter release.

**Effective plan:** By default Free; resolve Premium only when an independently trusted `user_entitlements` row is active and not expired, with a mapped user. If Premium limits are not configured, fail closed to a documented Free policy or reject Premium-only operations; **never assume unlimited**.

**Atomic `reserve_usage(user_id, metric, idempotency_key, job_id?)` transaction:**
1. Derive user from verified JWT on server; never accept a caller-supplied `user_id` as authorization.
2. Select current UTC day using DB/server time; read effective plan and limit.
3. Insert/lock `(user_id,day_utc,metric)` counter row (`INSERT ... ON CONFLICT DO NOTHING` followed by `SELECT ... FOR UPDATE`), then look for existing unique reservation for the idempotency key.
4. If already consumed/reserved, return previous state without decrement or duplicate model call. If `used+reserved >= limit`, reject with `quota_exceeded` and exact reset timestamp.
5. Create `reserved` row and increment counter in the same transaction. Also claim a barcode job atomically; prevent two simultaneous AI requests for the same barcode from both running. Unique barcode alone is not a sufficient processing lock; use a row claim/lease and recheck published cache.
6. **Finalize** exactly once on successful validated publication: decrement reserved, increment used, mark reservation consumed. **Release** for failed technical processing/retake: decrement reserved, mark released. For bounded retry, use an existing claimed job/session and a new attempt token only when appropriate; avoid free unlimited model replays.
7. Expired reservations must be reconciled with job state and provider work before releasing. A reservation started before midnight belongs to its original UTC day; don't double-charge after day rollover.

**Barcode lookups:** For verified users, use the same atomic count mechanism, consuming on completed `ready`/`not_found`/safe `processing` lookups. For guests, maintain best-effort request throttles, not a spoofable `user_id` counter; avoid claiming that precise guest remaining-lookups is known. When guest becomes authenticated, start tracking precise user usage without pretending earlier anonymous activity can be reliably attached.

**AI credit vs provider spend:** A successful product publication consumes one analysis allowance regardless of two input photos. Cache hits consume zero. Bounded retakes or Meta failures release user quota but **do not undo actual provider spend**: record cost in `ai_usage` and enforce separate max requests/cost per job, per IP, per user, and global daily budget.

**Global budget:** Store protected operations configuration/secret and track account-level estimated provider spend plus inflight request cap. Reject with `service_budget_exceeded` without misrepresenting it as a user's own quota. Pricing/tokens must be verified on live Meta API.

## 6. RevenueCat design (billing disabled until later)

**Approved provider:** RevenueCat. The MVP prepares identity, entitlement and webhook storage; **does not activate purchases**.

- When purchasing is eventually enabled, require Supabase Email OTP identity first; initialize RevenueCat using a stable custom App User ID equal to the Supabase Auth UUID. Do not allow premium assignment based on `CustomerInfo` sent by the Flutter client.
- `revenuecat_customers` maps verified Auth users to RevenueCat identity. Handle RevenueCat aliases/transfers explicitly; webhook `app_user_id` may be an alias rather than the latest user ID. Unmapped aliases are held for reconciliation, not silently assigned. See <https://www.revenuecat.com/docs/customers/user-ids>.
- Set a dedicated server-side RevenueCat webhook secret. RevenueCat documents webhook `Authorization` header verification and optional HMAC signature (`X-RevenueCat-Webhook-Signature`) over timestamp and raw JSON; **verify before accepting any event**. Use constant-time comparison and replay tolerance for signed events. See <https://www.revenuecat.com/docs/integrations/webhooks>.
- Store unique `event_id` and the minimum sanitized fields. Do not trust client events or duplicate webhooks. Webhook delivery is at-least-once and can be out of order; reconciliation to **current trusted RevenueCat entitlement state**, expiration and transfer behavior is mandatory, rather than blindly activating Premium on any purchase event or revoking on cancellation alone.
- Model grace periods, refunds, renewals, expirations, product transfers and sandbox/production separation. Choose the real RevenueCat entitlement identifier and product IDs later, along with prices, offerings and Premium allowances; these are not approved yet.
- `billing_enabled=false` server feature flag for hackathon. No user-facing paywall, payment CTA, store purchase screen, or RevenueCat checkout integration. Test/admin Premium grants use privileged operations and should be readily revocable.

### Server routes

| Edge Function | Auth mode | Work |
|---|---|---|
| `get-product` | Guest-capable; guarded publishable/public access plus throttling | Normalize barcode, quota/throttle, return only ready result or explicit miss/processing |
| `analyze-product` | Verified Supabase user JWT | Check quota + lock + cache, call Meta AI, validate/publish, meter usage |
| `get-analysis-status` | Verified owner JWT | Poll/retake/failed/ready for own job only |
| `get-usage` | Verified user JWT; guest gets coarse fair-use messaging | Resolve current plan/limits, remaining counters, reset time |
| `revenuecat-webhook` | No user JWT; **RevenueCat-authenticated webhook** | Authenticate signature/header, log/dedupe event, reconcile entitlement, reject invalid payload |
| `admin-invalidate-product` / `admin-test-entitlement` | Privileged internal/admin only | Correct invalid records, issue/revoke test entitlement |

Webhook route should not be deployed unprotected merely because it omits JWT verification. Decide whether to deploy the handler disabled until live billing is planned; in either case no invalid message can update entitlements.

## 7. Transient images, cleanup, privacy

- Client compresses nutrition/ingredient photo and submits securely to backend. If Edge Function cannot safely process within request/payload limits, use private transient Storage, short-lived upload grant, and a scheduled cleanup job.
- Images **discarded after successful extraction**, regardless of whether later interpretation/publishing fails; for unreadable/failed/abandoned jobs delete by short bounded TTL (proposed <=24 hours pending privacy-policy decision). Any local photo draft remains on device only for user-driven retake.
- Do not expose label photos as public Storage, do not log base64 or full nutrition photo contents, do not retain personal emails in product results.
- Track account deletion and usage logs retention; proposed operational logs retention 30 days before aggregation/anonymization, subject to privacy requirements and product policy. Published non-personal product analysis may remain after deleting contributor account; do not include contributor email in published catalog.

## 8. Indexes, migrations and maintenance

- Barcode unique index, analyses by `(product_id,created_at desc)`, findings by `(analysis_id,sort_order)`, job indexes by `barcode/state` and `user_id/created_at`, usage PK by `user/day/metric`, reservation idempotency unique, webhook event ID unique.
- Use forward-only numbered Supabase migrations under `supabase/migrations/`; never mutate live schema by manually running untracked changes. Migrations must be idempotent where applicable and include a plan for rollback/backups.
- Seed **only Free** plan limits and `premium` plan shell. Premium numerical limits remain TBD; enabling billing must fail readiness check until they are configured.
- Retain job failure reason categories but avoid storing private image content. Implement abandoned-job recovery and expired temporary upload cleanup.

## 9. Test matrix and acceptance gates

| Test | Expected result |
|---|---|
| Guest scans existing barcode | Published result; zero Meta requests |
| Guest scans missing barcode | Three-step capture, OTP at analysis submission |
| Guest attempts `analyze-product` | 401/403, zero AI spend |
| Verified user completes 3 analyses in UTC day | Fourth new request rejected before Meta call |
| Two photos, one successfully published product | Exactly one AI allowance consumed |
| Existing barcode analyzed again | Cache result; zero AI allowance consumed |
| Unreadable label or Meta failure | User credit refunded, bounded retake; provider cost logged |
| Signed-in user performs 30 valid lookups | 31st rejected; subsequent reset succeeds |
| Free barcode limit changed 30→20 on server | Immediate new effective limit, zero remaining for users already at 20+ |
| Concurrent submissions with one credit left | Exactly one reservation admitted |
| Guest quota bypass through fake client fields | No privileged write or plan change |
| Direct anonymous and authenticated table reads/writes | Denied (Edge Function required) |
| Fake Premium claim / altered client RevenueCat data | No higher backend allowance |
| Bad/duplicate/out-of-order RevenueCat webhooks | Invalid rejected, duplicate ignored, stale safely reconciled |
| Account deleted | Personal mapping/usage removed per policy, published catalog unaffected |
| Temporary image cleanup | No image retained after extraction; abandoned images expire |

**Blocking proof:** deploy a small real Supabase Edge Function + Meta image analysis with two package photos. Validate Email OTP, latency, request size and actual token charge before assuming the remaining processing plan works.

## 10. Open implementation choices (not new product requirements)

- Exact Meta multimodal endpoint/model, actual per-image token cost, max payload size and timeout.
- Barcode canonical UPC/EAN conversion rules and recognized formats after testing real scanners.
- Reliable storage/rate-limiter backend for unauthenticated guests, including shared-IP fairness and privacy protections.
- Concrete nutrition classification thresholds and supporting authoritative sources; never invent green/yellow/red clinical claims.
- Numeric Premium limits/prices, RevenueCat entitlement ID/product IDs, webhook environment and billing activation schedule.
- Whether to use direct short-lived image upload or private temporary Storage and queued processing after runtime measurement.

**Next document:** `PICKWELL_TASKS.md`, followed by `AGENTS.md` after inspecting the real `pickwell-ai` repository's existing instructions/template.

## 11. T02.1 implementation reference (2026-11-02)

The catalog/analysis/findings/jobs subset now has an additive implementation in
`supabase/migrations/20261102000100_pickwell_catalog.sql`, a clearly synthetic
`supabase/seed/04_pickwell_demo.sql`, and targeted PostgreSQL-engine tests.
See [catalog foundation evidence](PICKWELL_CATALOG_FOUNDATION.md) for normalization,
composite revision ownership, publication sealing, correction/retry behavior and
validation limits. No remote migration was applied. Native Supabase/PostgreSQL
15.19 checks now pass without Docker: clean migration/seed application, actual
migration replay/data preservation and 37 pgTAP assertions. Quota, analytics,
entitlement and webhook portions of this blueprint remain later tasks.

## 12. T02.2 security boundary reference (2026-11-02)

`20261102000200_pickwell_security_boundary.sql` adds protected usage counters/
reservations, environment-separated entitlement/event storage and explicit privilege
defaults. The shared read boundary and owner-scoped status adapter are in
`supabase/functions/`; no hosted deployment occurred. Entitlements use a composite
user/environment key and require verified same-environment event references for
future RevenueCat sources; this strengthens the illustrative user-only key.
No authoritative Premium resolver, webhook reconciliation or atomic quota logic
exists yet. See [security evidence and deferred public endpoint](PICKWELL_SECURITY_BOUNDARY.md).
