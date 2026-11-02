# T02.1 — Shared catalog and analysis-job foundation

2026-11-02. **T02.1 COMPLETE: isolated tests and native Supabase/PostgreSQL 15
migration, seed, replay and pgTAP checks passed.** No remote migration or seed was
applied. This task does not close T01.1's label-quality limitations.

## Existing schema and scoped additions

Reviewed root instructions, PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0, TASKS v1.1,
and the three existing migrations. Existing profiles, social/sample content,
consumer storage, auth triggers and role policies remain unchanged. The optional
subscription module remains uninstalled; no plan/quota/billing tables were added.

`supabase/migrations/20261102000100_pickwell_catalog.sql` adds:

- `products`: canonical unique barcode, optional identity, publication state/current
  revision, demo marker, timestamps and explicit invalidation metadata.
- `product_analyses`: typed JSON nutrition/ingredients, summary, schema/model/prompt/
  rules versions, validation/publication-seal timestamps and nullable contributor FK.
- `analysis_findings`: green/yellow/red category, explanation, nonempty rule/evidence
  metadata and deterministic ordering. No health-score field or unsupported thresholds.
- `analysis_jobs`: verified-caller ownership reference (authorization remains in the
  future handler), idempotency, one active barcode claim, attempt/lease state,
  retake target, safe error category and correctly owned result references.
- `published_products`: **server-only**, invoker-security view selecting only `ready`
  products with their own current analysis and ordered findings. It omits contributor
  identity/jobs. Future guest lookup must use the controlled Edge Function; no client
  role receives direct view or table access.

RLS and explicit privilege revocation are included from creation rather than
leaving new tables open until T02.2. Only `service_role` gets the required table/view
and helper privileges; functions are invoker-security with fixed empty search paths.
This is a baseline boundary, not completion of T02.2's deployed role/API audit.

## Barcode and data invariants

`pickwell_normalize_barcode` accepts digit-only EAN-8, UPC-A, EAN-13 or GTIN-14
(surrounding spaces trimmed), validates the GS1-style mod-10 check digit, and stores
GTIN-14 by zero-padding. UPC-A `036000291452` and EAN-13 `0036000291452` resolve to
the same `00036000291452`; a unique constraint prevents alias duplicates.
Eight-digit **UPC-E must first be expanded by a format-aware scanner**; eight-digit
text alone is ambiguous with EAN-8. Do not silently infer its barcode format. This
is a T03 integration requirement, not a claim that camera support is implemented.

The current-analysis composite FK enforces ownership by the same product. Ready
records require a current revision, publication timestamp and findings; all analyses
require structured nutrition/ingredient objects, explicit basis, nonempty raw evidence,
version metadata and a validation timestamp. Known nutrient values require nonnegative
numbers, explicit supported units and source text. Individual unknown values/allergen
declarations can remain null; this never means zero or allergen-free. Semantic facts,
label consistency and referenced rule accuracy still require T05.2's trusted validator.

Revisions/findings cannot be updated or deleted. Publishing seals the analysis,
including after a newer current revision replaces it; late finding inserts are rejected.
Publication and finding insertion lock the same revision row to serialize sealing.
Account deletion may detach a contributor FK without changing nonpersonal facts;
the account's private jobs cascade away. No label-image storage field/bucket is added.

## Jobs, retry and correction workflow

New jobs start `queued`, with zero attempts and no result. Allowed transitions:

```text
queued → processing | failed | cancelled
processing → ready | needs_retake | failed | cancelled
needs_retake | failed → queued | cancelled
ready | cancelled → terminal
```

Starting processing increments attempts once and requires a lease. Retake requires
a label target; failure requires a constrained error code; ready requires matching
product/revision references. User/barcode/idempotency identity cannot change, attempts
cannot decrease, and one partial unique index admits at most one queued/processing
job per canonical barcode. The foundation does **not** provide an atomic claim RPC,
quota reservations, automatic lease expiry recovery, rate limits or global spend caps;
those remain T02.3/T05.1. An expired active job must be reconciled before requeueing,
not bypassed by blindly inserting another job.

Trusted correction/invalidation path (no contributor/public overwrite rights):

1. In a privileged transaction, lock the product row and set `invalidated`, recording
   `invalidated_at` and a nonempty `invalidation_reason`. Published view excludes it.
2. Preserve the prior revision/findings. Insert a newly validated analysis and findings
   for the same product, with explicit new version metadata as appropriate.
3. Atomically change `current_analysis_id`, `status=ready` and `published_at`. The FK
   and seal enforce ownership and immutability. Later quota finalization belongs in
   this publication transaction when T02.3/T05.3 exists.

No admin HTTP endpoint or correction UI is exposed here. Invalidation columns retain
the latest reason; a broader admin event ledger is not implemented by this task.

## Clearly identified demo seed

`supabase/seed/04_pickwell_demo.sql` is wired into local seeds alongside the existing
`seed.sql` through `[db.seed].sql_paths` in `supabase/config.toml`.

- Barcode input **`2900000000018`**, stored **`02900000000018`**. Synthetic test
  identifier only: no claim of real package ownership or GS1 assignment.
- Name **DEMO — Fictional oat sample**, `is_demo=true`; summary and caution finding
  explicitly say synthetic demo. Model metadata is `fixture:no-provider-call`.
- Eight fictional nutrient values with per-100g basis/source text, two ordered
  ingredients, unknown allergen declaration and an evidence-backed demo notice.
  No real health classification or Meta output is claimed.
- Fixed fixture IDs and insert-if-missing behavior make this **new demo seed** safe
  to replay. Existing publications, admin invalidations and corrections are preserved.
  A conflicting identifier owned by another record skips the demo instead of overwriting.
  Existing generic starter `seed.sql` is unchanged and is not claimed replay-idempotent.

## Targeted validation and limits

Commands from repository root:

```sh
# Isolated test-only dependency; same version used by existing subscription SQL tests.
# Local files remain under ignored .secrets/, with no Flutter/runtime package changes.
npm install --prefix .secrets/sql-test --ignore-scripts --no-audit --no-fund @electric-sql/pglite@0.3.14
node --test supabase/tests/catalog_schema.test.mjs
supabase db reset --local
supabase test db --local
python3 mobile/tool/check_environment.py
git diff --check
```

Observed results:

- PGlite install succeeded. **9 tests passed, including 46 expected SQL rejections**
  on PostgreSQL **17.5**. Applied all three existing migrations and sample seed,
  preserved an existing post/categories, applied the additive migration, and replayed
  a transaction/version-ledger runner with zero reapplied versions/data loss.
- Verified normalization/duplicate/check-digit constraints, analysis/result ownership,
  JSON/version/evidence constraints, publication/invalidation, correction history,
  job transitions/idempotency/active uniqueness, actual anon/authenticated denial,
  service-role publication and account-erasure behavior.
- Isolated tests use minimal Auth/Storage platform fixtures and load uuid-ossp.
  PGlite lacks pgcrypto, so only its existing `CREATE EXTENSION pgcrypto` declaration
  is omitted in the test adapter; no new migration statement is rewritten. Native
  `gen_random_uuid()` remains real PostgreSQL behavior.
- `supabase db reset --local` **failed** before reset because Docker is unavailable.
  `supabase test db --local` **failed** connecting to `127.0.0.1:54322`. CLI accepted
  the updated seed configuration. No remote/linked reset was used.
- Secret scan and diff whitespace checks passed. No additional Meta request/provider
  spend, remote schema mutation, billing activation, credential or photo commitment.

At this initial checkpoint, the isolated version-ledger replay was **not the Supabase
CLI migration runner**, and the actual Supabase checks were blocked. The subsequent
Native Runtime validation below closes that migration/seed/pgTAP gap without Docker.
Real concurrent multi-session behavior and a hosted deployment are not claimed by
either suite. No full-project/native/mobile regression was needed for these SQL-only changes.

## Native Runtime follow-up — full local validation passed

Before this follow-up, the T02.1 implementation was committed as **`616c548`**.
Used pinned **`npx --yes supabase@2.122.0`**, leaving the existing system CLI 2.48.3
and hosted project unchanged. Official [Native Runtime documentation](https://supabase.com/docs/guides/local-development/docker-and-native-runtimes)
and [stack selection guidance](https://supabase.com/docs/guides/local-development/running-multiple-local-projects)
were checked before setup.

The test workspace is ignored `.secrets/native-validation/`. It contains copies of
the repository's migrations, seed files and SQL tests, **not** real server env files
or the Meta spike. Its copied config enables `[experimental] stack=true`, omits fixed
ports and uses a distinct local project ID. The repository config is not rewritten
or reinitialized. Native resolved the configured Postgres 15 requirement to
**PostgreSQL 15.19**, service artifact **15.19.0.007-r0**, on macOS arm64.

Started with:

```sh
SUPABASE_EXPERIMENTAL_STACK=1 npx --yes supabase@2.122.0 start \
  --runtime native --preparation on-demand --stack t021 \
  --exclude functions,realtime,studio,analytics,pooler,mail \
  --workdir .secrets/native-validation
```

This downloads native service binaries without a Docker VM. Postgres starts first;
other enabled services are lazy. Credentials/status output was captured only in
ignored owner-only local files, not chat or Git. No production keys were imported.

Verified results:

| Check | Observed outcome |
| --- | --- |
| Native startup | Exit 0; all four repository migrations and both configured seeds applied without SQL edits. |
| Native clean reset | CLI `db reset --db-url <guarded-loopback-URL> --yes` exited 0; actual server reports `15.19`, migration ledger contains `20261102000100`, one ready demo and one analysis. |
| pgTAP | **37 assertions passed across 2 files**: new `catalog_schema_test.sql` (31) plus existing `consumer_security_test.sql` (6). Passed both before and after reset. |
| Actual CLI migration replay | `migration up --db-url <guarded-loopback-URL>` exited 0 with the current version ledger; existing data stayed intact. |
| Preservation sentinel and demo replay | An extra local category survived migration replay; two demo-seed replays preserved catalog/analysis/finding IDs/counts and created no duplicate demo. |
| Stop | `stop --stack t021 --workdir .secrets/native-validation` exited 0. Native processes stopped to free memory; local data/cache remain available for reuse. |

CLI 2.122 compatibility details discovered during testing:

- `--stack t021` works on start/status/stop, **not** on database commands. For a
  named stack, obtain its private `DB_URL` using status and pass `--db-url`. Every
  reset/test target was programmatically restricted to loopback and runtime=native;
  generic CLI wording "remote database" did not mean a hosted project was contacted.
- The returned local URL needed **`sslmode=disable`** for direct database commands
  because native Postgres does not accept TLS. This was used only on verified
  loopback URLs, never a hosted connection. The initial attempt without this option
  failed safely before tests; rerunning with it passed.
- `[inbucket]` emits a deprecation warning in favor of `[local_smtp]`, but still
  works. No change was required to the repository's legacy-compatible configuration.

New `supabase/tests/catalog_schema_test.sql` is transaction-wrapped pgTAP coverage
for real Supabase schemas/extensions/roles, canonical identity, publication and
ownership, immutable revisions, jobs, client denials and account cleanup. Tests
roll back their changes. Native validation uses the unmodified pgcrypto/uuid-ossp
extension declarations, unlike the isolated PGlite adapter.

**No migration correction was necessary.** The follow-up changes retain the native
pgTAP test and update documentation/status. The remaining T02.1 integration gate is
closed; production deployment, later quota concurrency and the full T02.2 security
audit remain separate work. No AI request, remote schema/secret change or billing
activation occurred during Native Runtime testing.

## Application and recovery

This is a forward-only additive migration, not a repeatable SQL script. The migration
runner records its version; do not add `IF NOT EXISTS` guards that hide schema drift
or manually replay the DDL. Take a schema/data backup and inspect the actual remote
schema/migration ledger before any separately requested deployment. Remote tables
were not inspected or assumed identical in this local implementation task.

On a local integration failure, fix unapplied migration inputs and reset only the
disposable local stack. Once deployed, preserve revisions/product facts and use a
reviewed forward repair migration or restore from backup; do not drop/recreate the
catalog or edit an applied migration in place.

All four implementation checklist items and T02.1's local migration/seed/replay
acceptance are now verified. **T02.1 COMPLETE.** Next is T02.2's full RLS/least-privilege
audit; no later phase or remote database deployment was started. Docker is not
required for the documented native validation path.
