# T02.1 — Shared catalog and analysis-job foundation

2026-11-02. **Implementation and isolated SQL validation completed; full local
Supabase/PostgreSQL 15 application remains unverified.** No remote migration or
seed was applied. This task does not close T01.1's label-quality limitations.

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

The isolated version-ledger replay is **not the Supabase CLI migration runner**.
PostgreSQL 15/Supabase extension/seed compatibility, native pgTAP, real concurrent
transactions and a deployed schema remain unverified. Start the local Docker-backed
stack and run the two CLI checks before treating full integration acceptance as closed.
No full-project/native/mobile regression was needed for these SQL-only changes.

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

Four implementation checklist items are verified locally. **Overall T02.1 remains
PARTIAL pending the full Supabase-stack application check.** Next dependency is a
working local Docker stack, then T02.2's full RLS/least-privilege audit. No later
phase or remote database deployment was started.
