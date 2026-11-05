> **Current state (T07.2A):** The November 4 C.4 rollout deployed Product Trust,
> private results and optional thumbnails from `5178ec1`; earlier deferred/not-deployed
> sections below are historical. See [current contract and setup](../README.md),
> [hosted rollout](../docs/PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md) and
> [submission blockers](../docs/PICKWELL_SUBMISSION_READINESS.md). Billing stays disabled;
> no fresh live inference/device pass is claimed.

# Supabase Project Structure

This backend is optional for the consumer Flutter starter. Run CLI commands from
the repository root. Supabase authentication, profile editing, account deletion,
and storage use the migrations in this directory. The posts/comments/likes schema
is sample content, not a mandatory consumer data model.

```sh
supabase start
supabase db reset
supabase test db
supabase functions serve delete-account
```

Docker is required for the local stack. Apply migrations and deploy delete-account
to the generated app's own backend before enabling production account deletion.
The native auth callback and Supabase redirect allowlist must match; see
../mobile/README.md. Storage uploads use `<userId>/...` paths. Roles are managed by
the server; owners can edit profile fields but cannot promote themselves.

The consumer migration creates images, documents, and avatars buckets and their
RLS policies. It also allows self notifications. Storage policy files outside the
migration directory are no longer an installation step.

## Pickwell catalog foundation

The additive T02.1 migration, server-only published projection, private jobs and
explicit synthetic demo seed are documented in
[PICKWELL_CATALOG_FOUNDATION.md](../docs/PICKWELL_CATALOG_FOUNDATION.md).
The new seed runs alongside existing sample content on local reset. Its demo
barcode is `2900000000018` (canonical `02900000000018`); never present its fictional
facts as a real food analysis. Full local Supabase validation has passed with
experimental Native Runtime (CLI 2.122.0, PostgreSQL 15.19), without Docker. The
linked evidence describes the isolated setup and named-stack command details.

## Pickwell quota and provider admission

[T02.3 quota controls](../docs/PICKWELL_QUOTA_CONTROLS.md) documents audited mutable
Free 30/3 limits, atomic reservations/publication, guest network throttling and
server-only provider spend/concurrency admission. Normal inference and billing
remain disabled; public route wiring belongs to T03.1/T05.1. Native SQL/Auth/REST
checks pass without Docker. No hosted migration or inference was run in this task.

## Pickwell operational events and retention

[T02.4 operational evidence](../docs/PICKWELL_OPERATIONAL_EVENTS.md) covers private,
redacted lifecycle events, separate estimated provider cost, daily aggregate reports
and protected retention/archival. Optional analytics failures cannot change quota
allowance; mandatory provider accounting still fails closed. Cron registration is
conditional on the extension already being enabled; verify a running retention job
before deployment. No public analytics endpoint or hosted change was made.

## Pickwell get-product endpoint

[T03.1 lookup evidence](../docs/PICKWELL_PRODUCT_LOOKUP.md) describes the guest-capable
POST endpoint, canonical GTINs, throttling, signed-in quota, atomic read/settlement
and bounded idempotent retries. Only sanitized published products or safe explicit
miss/processing states are returned; no AI is invoked. Configure the private network
HMAC secret and verify ingress/gateway behavior before hosted deployment. Local HTTP
handler tests passed against native Supabase; Deno/hosted gateway execution is unverified.

## Optional premium backend access

Pickwell's T02.2 server-only usage/entitlement/event foundations and read boundaries
are documented in [PICKWELL_SECURITY_BOUNDARY.md](../docs/PICKWELL_SECURITY_BOUNDARY.md).
They use the approved Pickwell schema; do not install the generic subscription
module below without reconciling its different entitlement contract. No billing or
webhook is active. Public lookup remains deferred until quota/rate admission exists.

[modules/subscriptions/README.md](modules/subscriptions/README.md) provides an
explicitly installed entitlement schema, RLS helper, RevenueCat webhook,
authenticated refresh endpoint, and protected-operation example. It requires
signed-in Supabase users for paid backend access. The default migrations and
functions remain unaffected until the module is installed. Client billing flags
and local guards do not authorize server operations.

## 📁 Directory Structure

```
supabase/
├── config.toml                 # Supabase configuration
├── seed.sql                    # Main seed file
├── migrations/                 # Database migrations
│   ├── 20240101000000_initial_schema.sql
│   └── 20240101000001_rls_policies.sql
├── seed/                       # Seed data files
│   ├── 01_categories.sql
│   ├── 02_tags.sql
│   └── 03_sample_posts.sql
├── functions/                  # Edge functions
│   ├── hello-world/
│   │   └── index.ts
│   ├── send-notification/
│   │   └── index.ts
│   └── process-image/
│       └── index.ts
├── storage/                    # Storage configuration
│   ├── buckets/
│   │   ├── images.json
│   │   └── documents.json
│   └── objects/
│       └── avatars/
│           └── default-avatar.png
└── policies/                   # Additional policies
    └── storage_policies.sql
```

## 🚀 Getting Started

### 1. Initialize Supabase
```bash
supabase init
```

### 2. Start Local Development
```bash
supabase start
```

### 3. Apply Migrations
```bash
supabase db reset
```

### 4. Run Seed Data
```bash
supabase db seed
```

## 📊 Database Schema

### Core Tables
- **profiles** - User profiles extending auth.users
- **posts** - Blog posts with status and publishing
- **comments** - Nested comments system
- **likes** - Post likes with unique constraints
- **follows** - User following relationships
- **notifications** - User notifications system

### Content Management
- **categories** - Post categories with colors
- **tags** - Flexible tagging system
- **post_categories** - Many-to-many relationship
- **post_tags** - Many-to-many relationship

### Features
- ✅ Row Level Security (RLS) policies
- ✅ Automatic timestamps with triggers
- ✅ User signup handling
- ✅ Slug generation for posts
- ✅ Comprehensive indexing

## 🔧 Edge Functions

### hello-world
Simple greeting function for testing.

### send-notification
Creates an in-app database notification for the verified caller only. It does not deliver remote push.

### delete-account
Verifies the caller, deletes their files from the consumer buckets, and deletes
their auth account. Extend cleanup for new buckets or external user data. It never
accepts a target user ID from the request body.

### process-image
An authenticated image-copy scaffold accepts `source_path` inside the caller's
`<userId>/...` folder. It uses caller-scoped storage permissions and never fetches
arbitrary URLs. Nonempty `transformations` are rejected until a real transformer
is added; the response explicitly reports `transformed: false`.

## 📦 Storage Buckets

### images
- **Public**: Yes
- **Size limit**: 50MB
- **Types**: JPEG, PNG, GIF, WebP
- **Use case**: User uploads, post images

### documents
- **Public**: No
- **Size limit**: 50MB
- **Types**: PDF, DOC, DOCX, TXT, CSV
- **Use case**: Private document storage

## 🔐 Security

### Row Level Security
All tables have comprehensive RLS policies:
- Users can only access their own data
- Public content is readable by everyone
- Admin users have elevated permissions

### Storage Policies
- Public images are accessible to everyone
- Users can only manage their own files
- Proper folder structure for user isolation

## 🎯 Usage Examples

### Create a Post
```sql
insert into posts (user_id, title, content, status)
values (auth.uid(), 'My Post', 'Content here', 'published');
```

### Get User's Posts
```sql
select * from posts 
where user_id = auth.uid() 
order by created_at desc;
```

### Follow a User
```sql
insert into follows (follower_id, following_id)
values (auth.uid(), 'user-uuid-here');
```

### Upload an Image
```javascript
const { data, error } = await supabase.storage
  .from('images')
  .upload(`${userId}/${fileName}`, file)
```

## 🔄 Migration Workflow

1. Create new migration: `supabase migration new migration_name`
2. Write SQL in the generated file
3. Apply migration: `supabase db push`
4. Update seed data if needed

## 📝 Notes

- All timestamps use UTC timezone
- UUIDs are used for all primary keys
- Proper foreign key constraints maintain data integrity
- Indexes are optimized for common query patterns
- Triggers handle automatic timestamp updates

## 🆘 Troubleshooting

### Common Issues
- **RLS blocking queries**: Check your policies and user authentication
- **Storage uploads failing**: Verify bucket policies and file size limits
- **Functions not working**: Check Deno permissions and environment variables

### Useful Commands
```bash
# Check database status
supabase status

# View logs
supabase logs

# Reset database
supabase db reset

# Generate types
supabase gen types typescript --local > types/database.types.ts
```

## Current cloud migration deployment

All eight repository migrations through `20261102000500` were applied to the existing
Pickwell cloud project on 2026-11-02. See [cloud deployment evidence](../docs/PICKWELL_CLOUD_MIGRATIONS.md)
for the UUID-default compatibility correction, RLS/role verification and exact commands.
No sample/demo seed or Edge Function was deployed by that operation. Inference,
billing and Premium remain disabled; Edge lookup and Cron activation are separate.


## Hosted get-product follow-up

`get-product` version 1 is deployed and live contract/security checks passed on
2026-11-02. The dedicated labeled synthetic demo seed is now present for cache-hit
testing. See [hosted lookup evidence](../docs/PICKWELL_PRODUCT_LOOKUP.md#hosted-deployment-and-live-validation--2026-11-02).
The conservative shared network throttle remains in use; automatic retention and
physical-device validation remain outstanding. Normal inference and billing are off.

## Contribution authorization gate (T04.2)

`authorize-analysis` is deployed as a POST-only auth preflight with JWT gateway
verification and an independent Auth user lookup. It requires confirmed email and
`is_anonymous=false`, rejects client identity/verification fields, and returns only
`status=authorized`. It needs only injected Supabase URL/anon configuration; it
performs no DB writes, uploads, usage reservation, billing or inference.

`_shared/analysis_authorization.mjs` exports `requireVerifiedEmail` for T05's actual
submission handler. That handler must recheck identity; a prior preflight response
or a client flag grants no submission capability. See
[Email OTP evidence](../docs/PICKWELL_EMAIL_OTP_GATE.md).

## Analyze-product orchestration (T05.1)

`analyze-product` is deployed with gateway JWT verification and the shared trusted
confirmed-email guard. It accepts bounded multipart barcode/idempotency/two-photo
input, applies atomic admission and provider-spend controls, and calls the reused
Meta adapter only after a unique provider claim. Inference remains disabled.

Private `analysis_requests` bind request keys to canonical barcode and image hashes;
`analysis_candidates` hold structured extraction for later validation/publication.
No original images are stored. The latter expire after 24 hours when
`pickwell_prune_analysis()` runs; configure it alongside existing telemetry
maintenance before enabling hosted inference. Admission also runs that pruning
opportunistically. Unknown provider outcomes require trusted reconciliation and
must never be cleared by a client retry.

See [orchestration evidence](../docs/PICKWELL_ANALYSIS_ORCHESTRATION.md). T05.2/T05.3
and Flutter upload/result wiring remain separate; an auth preflight or private
candidate is not a published product or a consumed successful-analysis credit.

## Extraction and validation (T05.2)

The protected analysis handler uses `analysis_validation.mjs` for a versioned strict
Meta schema, literal fact checks, photo-specific retakes and source-backed nutrient
rules. It stages accepted `candidate.validation` privately, without publishing or
spending a successful-analysis credit. Model explanations are constrained factual
restatements; colours come solely from backend rules. Unsupported contexts remain
unclassified. See [validation/live evidence](../docs/PICKWELL_ANALYSIS_VALIDATION.md).

T05.2 remains partial: existing real pairs still need retakes and the so-called
unreadable fixture is a readable mismatch. Normal inference/billing are disabled.
The optional operator-only `spikes/meta-vision/analysis-index.ts` reuses the existing
guards; its three-case manifest/runner must not treat retakes as successful products.
No publication or Flutter upload implementation is included.

## Atomic publication and disposal (T05.3)

`analysis_publication.mjs` revalidates owned private candidates and calls the new
server-only atomic publisher. Existing quota finalization, unique barcodes and
immutable revisions are reused. Publication writes explanations/provenance and
findings, marks ready, finalizes one successful credit and deletes the candidate
in one transaction. Retakes/failures release allowance but retain provider costs.
Lost publication acknowledgements resume safely; invalidated records require
operator review. V2 results may have no supported colour findings.

The migration and updated analysis/lookup functions are deployed with inference
and billing OFF. Backend photos are request-local, with no files/Storage uploads.
Client success must still call existing transient-draft disposal when the Flutter
submission/result handoff is connected. See [publication evidence](../docs/PICKWELL_PUBLICATION.md)
for targeted native/hosted checks and the remaining partial acceptance.

## T06.2 response quota metadata

The protected analysis handler optionally attaches the existing server-only AI
quota snapshot after authorization, with a bounded one-second read. Metadata
failure never changes admission/publication/accounting. No new RPC, migration or
model invocation is introduced. See [T06.2 evidence](../docs/PICKWELL_QUOTA_UI.md)
for native and hosted checks; inference and billing remain disabled.

## Retryable service-cap responses

Daily analysis service limits return a UTC retry/reset time. Only confirmed
pre-provider denials explicitly permit a fresh persisted request key; uncertain
provider outcomes retain their key. Manual retries still enforce all rate/spend
controls. See [pending analysis evidence](../docs/PICKWELL_PENDING_ANALYSES.md).

## T07.1C publication review (rollout pending)

New associations require an exact-evidence operator decision under
`trust-publication-v1`. Apply the C.1 migration then
`20261104000200_pickwell_product_trust.sql` before updated analysis handlers; deploy
`cancel-analysis-review` with handler-owned confirmed-user authorization. Approval
is available only to protected service/operator RPCs, never a mobile endpoint.
See [Product Trust](../docs/PICKWELL_PRODUCT_TRUST.md) for dry-run commands, expiry,
private evidence handling, tests and rollout prerequisites. No live change is
implied by these files.

## T07.1A.1 optional package thumbnails (not deployed)

[Product thumbnail contract](../docs/PICKWELL_PRODUCT_THUMBNAILS.md): private JPEG
bucket, immutable product/review/source binding, server-only post-publication
attachment, read-only eligible-image endpoint and Storage-API cleanup. Original
analysis submission is unchanged and never uploads photographs to Storage.
Operator/test tooling needs Python >=3.11 plus pinned `scripts/thumbnail-requirements.txt`;
no Flutter or Edge image-processing dependency was added. Configure protected
scheduled `attach-product-thumbnail.mjs --cleanup --apply` before enabling uploads.
No automatic production deployment; no image role/client flag grants publication.

## Private analysis / shared publication separation

T07.1C.3 and thumbnails were deployed in T07.1C.4. Read
[the hosted rollout and remaining verification/cleanup limits](../docs/PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md), then
[PICKWELL_PRIVATE_RESULTS.md](../docs/PICKWELL_PRIVATE_RESULTS.md) before applying
migration `20261104000400` or deploying the private-read/analysis/cancel handlers.
It changes successful-credit timing while preserving bound operator publication.
Use the documented coordinated rollout; do not mix old handlers and settlement
semantics, reset hosted data or silently change testing quotas.
