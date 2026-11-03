# T05.3 — Atomic publication and photo disposal

2026-11-03. **PARTIAL overall; backend publication and targeted checks pass.**
The protected backend now publishes accepted analyses and serves them to guests.
The remaining mobile submission/result handoff must call the existing draft disposal
operation on success; that client integration and full-flow/device tests are deferred
until the flow is connected, as requested. No new paid Meta call was made. T05.2's
real-label quality blockers remain open and its validation gates are preserved.

## Inventory and reconciliation

Started clean at `5de7878`. Read root instructions, backend README, actual catalog,
quota, read boundary, orchestration and validation code, and relevant PRD v1.4,
DESIGN/SPEC v1.2, DATABASE v1.0 and exact TASKS requirements. Reviewed mobile capture
instructions/source only to verify existing cleanup; Flutter files were not changed.

Reused the existing `pickwell_finish_usage` transaction, advisory lock, canonical
unique barcode, immutable revisions/findings, provider ledger, trusted email guard
and RLS. No duplicate quota subsystem, new dependency or photo Storage was added.
One material conflict was resolved: legacy publication required at least one
finding, whereas current rules require unsupported colour classifications to be
omitted. Validated v2 results may now have zero coloured findings; v1 still requires
a finding. Unknown/per-serving context never causes an invented colour.

## Implementation and security

- Additive migration `20261103000200_pickwell_publish_analysis.sql` adds bounded
  explanation/missing-information/provenance JSON to existing immutable revisions
  and appends those fields to the server-only published view.
- Server-only `pickwell_read_analysis_candidate` checks trusted verified identity,
  request ownership and expiry. The Edge helper recomputes the T05.2 validator from
  the stored raw candidate, using its original validation timestamp. It does not
  trust the stored `validated` flag or accept a publication payload from Flutter.
- Server-only `pickwell_publish_analysis` binds the recomputed result to the exact
  staged validation, model/prompt/rule versions, owner, successful provider attempt
  and reserved job. One transaction creates the product/revision/findings, invokes
  the existing finalizer to seal the revision/mark ready/consume exactly one credit,
  and deletes the private candidate. A failed write rolls back every publication
  and quota change. Duplicate publication returns the existing result.
- Ready cache races release the new reservation; invalidated/existing revision
  corrections require operator review and cannot be overwritten by contributors.
  That rejection releases successful-use credit while retaining actual provider
  spend. No client grants or security-definer business functions are introduced.
- Known failed/retake/cancelled/ready jobs delete their private structured candidate
  through a terminal-state cleanup trigger. Existing expiry pruning releases known
  expired candidates. Unknown provider outcomes remain held for reconciliation.
- A transient/lost publication acknowledgement returns an honest processing/cache
  state. Same-key retry resumes the stored candidate without another Meta request;
  it cannot duplicate a revision or successful credit. Successful publication
  returns `ready`; existing cached products retain `already_exists`.
- The public sanitizer explicitly allowlists explanation/provenance and rule
  reference/threshold/portion/evidence fields. Contributor UUID/email, request image
  hashes, private jobs, arbitrary nested fields and tokens are not projected. Name
  and brand stay unknown rather than being invented from caller input.

## Photo handling and remaining client dependency

There is **no server-side original-photo file or Storage object** to delete. The
analysis endpoint accepts bounded binary input, converts it only for the private
provider request and clears its image references after extraction/failure. An
outer finally now also clears them for cache hits, admission failures and RPC
failures. This is release of request-local references for garbage collection, not
a claim of immediate secure memory erasure. Tests forbid image data URLs in SQL
requests and forbid any Storage call in the analysis workflow.

Existing mobile `ScannerMediaService` deletes temporary camera-picker output,
keeps at most two owned prepared images, and removes prior-process draft directories
at startup. `LabelCaptureCubit` has one-hour expiry, independent retake/discard/close,
late-result disposal and bounded retry when file deletion fails. These existing
mechanisms were inspected, not rewritten or re-certified on hardware in this task.

**Still missing:** Flutter currently performs only the OTP preflight, not a real
analysis upload. The submission/result handoff must call and await
`LabelCaptureCubit.discard()` after a terminal accepted response and surface cleanup
failure. Until that is connected, immediate successful-submission deletion of the
mobile draft is not claimed. Retake/uncertain-transport drafts may remain transient
for safe recovery. The server has no abandoned original-photo objects; structured
candidate retention still depends on opportunistic pruning or scheduled maintenance.
Automatic Cron scheduling remains an existing operational prerequisite, not silently
enabled here.

## Actual targeted validation

**76 tests passed, zero failures/skips**, using real Native Runtime Auth/REST/SQL,
a mocked provider and the existing isolated PostgreSQL schema suite:

```sh
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 \
  supabase/tests/analyze_product.test.mjs \
  supabase/tests/analysis_validation.test.mjs \
  supabase/tests/get_product.test.mjs \
  supabase/tests/security_boundary.test.mjs \
  supabase/spikes/meta-vision/core.test.mjs \
  supabase/tests/catalog_schema.test.mjs
```

Verified actual handler publication, sealed revision/findings, exactly one used
credit, another guest's `get-product` ready response with no new provider invocation,
12 parallel publication retries, lost acknowledgement, rollback on a bad finding,
recovery without paid retry, no-colour per-serving publication, operator-only
correction, changed-candidate retake, failed/expired cleanup, retained provider
metrics, client RPC/table denials and sensitive nested projection. Synthetic
fixtures exercise the flow; they are not evidence of real Meta extraction accuracy.
An initial SQL expression failure was caught locally before deployment, corrected,
and the final clean native/schema runs passed.

Pinned Supabase CLI 2.122.0 ran the existing isolated Native Runtime without Docker.
Only the guarded loopback test database was reset. The migration runner/schema
suite verifies clean application and replay without losing existing sentinel data.
The runtime was stopped afterward and its loopback endpoint verified unreachable.
JS syntax, diff whitespace and secret scans passed. No blanket regression or new
physical-device, OTP-delivery or real-food inference test was performed.

## Cloud deployment and observed outcomes

Read-only preflight confirmed the actual nine-migration schema, one demo product and
analysis, zero production jobs/provider calls, the legacy finding guard, and no
conflicting new columns/RPC. A dry run listed only the new migration. Executed:

```sh
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --skip-vault --yes
npx --yes supabase@2.122.0 functions deploy analyze-product --project-ref bzmqgjinbjykhqqswdva --use-api
npx --yes supabase@2.122.0 functions deploy get-product --project-ref bzmqgjinbjykhqqswdva --use-api
```

All exited successfully. **Eleven hosted checks passed:** analyzer guest/public-key/
forged bearer 401; malformed verified input 400; valid unknown input 503
`inference_disabled`; analyzer cached demo 200; guest lookup 200 with eight demo
nutrients and safe metadata; both new private RPCs deny public-key callers 401 and
verified-user callers 403. No live production analysis was published for testing.

Final read-only verification: ten migrations, three new revision/view metadata
fields, active cleanup trigger, all 29 public tables retain RLS, no client grants or
new RPC execution privileges. The existing demo product/analysis remain one each;
production jobs/candidates/provider ledger rows remain zero. Inference and billing
remain false. Normal cache validation only adds its private fingerprint receipt.
No database reset, seeds, Vault writes, billing activation or extra provider spend
occurred in the cloud.

## Files and task status

Changed files:

- `supabase/migrations/20261103000200_pickwell_publish_analysis.sql`
- `supabase/functions/_shared/analysis_publication.mjs`
- `supabase/functions/_shared/analyze_product.mjs`
- `supabase/functions/_shared/catalog_boundary.mjs`
- `supabase/tests/analyze_product.test.mjs`
- `supabase/tests/security_boundary.test.mjs`
- `supabase/README.md`
- `docs/PICKWELL_PUBLICATION.md`
- `docs/PICKWELL_TASKS.md`

Verified TASKS items: atomic publication/credit, rejection accounting, public privacy.
Photo disposal remains unchecked overall because successful client-submission cleanup
is not wired, although server non-retention and backend candidate cleanup pass.
Full end-to-end/device acceptance remains deferred. No extra credentials or artwork
are needed for this backend change; clearer real label fixtures are still needed
for the previously recorded T05.2 gate.

Next is **T06.1 — Product results and accountable findings**, with the directly
required client submission/result/disposal handoff. Do not start it automatically.
This backend work is prepared for the requested commit. Private runtime/receipt/
session files and label photos remain ignored and excluded. T06.1 may proceed
with the client submission/result/disposal handoff; T05.3 stays partial until that
handoff and its cleanup are verified. Keep normal inference disabled while the
recorded T05.2 real-label quality and deferred end-to-end checks remain open.
