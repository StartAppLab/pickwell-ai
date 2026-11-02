# Supabase cloud migration deployment

2026-11-02. **DEPLOYED AND VERIFIED** to the existing **Pickwell** project
`bzmqgjinbjykhqqswdva` (Singapore, PostgreSQL 17.11). The target matched the existing
mobile development project URL and authenticated CLI project inventory. No Docker,
new Supabase project, database reset, history repair or secret upload was used.

## Before deployment

Repository was clean at commit `63795ff`. Read root instructions/backend README
and reviewed the eight pending migrations. Cloud inspection found one existing
Auth user, no public tables, no migration history, no storage buckets/policies and
no conflicting custom enums or Auth triggers. The platform's existing
`rls_auto_enable` function was left unchanged. Supabase Cron was not installed.

Used the existing authenticated CLI, pinned to version 2.122.0. The root directory
was not linked; every cloud operation specified the exact project reference rather
than inferring another project. Read-only inspection and a migration dry run
confirmed the target and all eight pending versions. Vault, optional roles and
sample seeds were excluded.

## Compatibility correction

The first push failed in the initial, previously unapplied template migration:
`uuid_generate_v4()` could not be resolved by the cloud migration runner. The
extension function existed under `extensions`, while the template's UUID defaults
used an unqualified extension-dependent name.

Read-only verification after that failure confirmed **zero applied migrations**,
no `profiles` table and the original Auth-user count of one. The failed migration
had rolled back. No version was marked applied or repaired manually.

Changed the seven UUID defaults in
`supabase/migrations/20240101000000_initial_schema.sql` to PostgreSQL's built-in
`gen_random_uuid()`. This preserves UUID v4 values/type and avoids extension
search-path dependence. The target had never successfully applied this migration;
no applied cloud migration was rewritten. Existing local databases need no destructive
replay: their UUID-generation behavior is equivalent.

Updated `supabase/tests/catalog_schema.test.mjs` to install uuid-ossp under
`extensions` and execute with a public-only search path, reproducing this hosting
boundary. All **9 tests / 46 expected SQL rejections** passed after the correction.
No unrelated template/schema feature was changed.

## Deployment and observed verification

Commands ran from the repository root:

```sh
npx --yes supabase@2.122.0 migration list --project-ref bzmqgjinbjykhqqswdva
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --dry-run --skip-vault
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --skip-vault --yes
```

Cloud metadata queries used `db query --linked --project-ref ... --file ...`;
inspection queries were explicitly read-only and never selected emails, credentials,
OTPs or session values. Logs/query files remain in ignored `.secrets/`.

The retry applied these versions successfully:

| Version | Migration |
| --- | --- |
| `20240101000000` | Initial template schema |
| `20240101000001` | Template RLS policies |
| `20261013000000` | Consumer profile/storage security |
| `20261102000100` | Pickwell shared catalog and jobs |
| `20261102000200` | Least-privilege security boundary |
| `20261102000300` | Plans, quotas and provider admission |
| `20261102000400` | Redacted events and cost reporting/retention |
| `20261102000500` | Atomic product lookup and retry receipts |

Post-deployment cloud assertions passed:

- All eight versions recorded in migration history; another dry run reports
  **up to date**, with no pending migrations, seeds or roles.
- **27 public tables, all with RLS enabled.** No public/anon/authenticated table/view
  grants on protected Pickwell objects; no client EXECUTE on any Pickwell RPC.
  Existing template profile/sample policies retain their intended capabilities.
- Eight valid anonymous REST table requests were rejected with SQLSTATE `42501`;
  anonymous direct `pickwell_get_product` RPC access was also denied. This verifies
  the public key cannot bypass the future Edge handler's throttling boundary.
- A trusted `service_role` product insert succeeded inside an explicit transaction,
  then rolled back. Read verification confirmed the test row does not exist.
- Original Auth-user count remains **one**. No Auth user was created/deleted by this
  deployment or verification.
- Free limits are **30 barcode lookups/day and 3 successful analyses/day**.
- `billing_enabled=false`, `inference_enabled=false`, Premium plan disabled.
- Products, analyses, provider-call ledger and sample-post counts are **zero**.
  No label photos, fake users, catalog/demo records or social sample seeds were added.
- No Meta inference, purchase/billing activation, provider-key upload or mobile
  configuration change occurred.

## Remaining deployment dependencies

**Database migration deployment does not deploy Edge Functions.** `get-product`
function deployment is still separate; the prior availability check returned 404.
Its server-only network HMAC/verified ingress configuration must be set before
publishing and its real ready/miss/error paths verified afterward.

The approved synthetic demo seed is also separate and was **not applied**. A newly
empty catalog should return real misses once the Edge function is deployed; a
cache-hit demo requires explicitly adding the clearly labeled demo seed or a real
validated product. Do not run the generic sample seed against cloud incidentally.

Supabase Cron remains disabled/uninstalled. The migration intentionally did not
install it; automatic retention must be enabled and its scheduled execution verified
before hosted use. No unresolved provider work exists because inference is disabled
and no provider call was made.

T03.2 remains PARTIAL: the user deferred physical barcode testing. This deployment
closes its missing database prerequisite, not the missing Edge endpoint or device
acceptance. No task checkbox was promoted based on schema deployment alone.

Changed repository files: the initial migration UUID defaults, hosted-layout
regression fixture, this deployment report, and backend README pointer. Credentials,
queries and deployment logs remain ignored; no secret values are in this report.

CLI behavior reference: [Supabase database migration deployment](https://supabase.com/docs/guides/deployment/database-migrations).


## Subsequent lookup deployment — 2026-11-02

After the migration-only operation described above, `get-product` was deployed
and the dedicated labeled demo seed applied. Live lookup/security/quota/throttle
checks passed with zero provider calls. See [hosted lookup evidence](PICKWELL_PRODUCT_LOOKUP.md#hosted-deployment-and-live-validation--2026-11-02).
Cron and physical-device acceptance remain outstanding. Earlier statements about
no function/demo deployment describe the migration operation, not this follow-up.
