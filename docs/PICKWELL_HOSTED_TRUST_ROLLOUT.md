# T07.1D.1 — Hosted Product Trust rollout

> **Current rollout:** T07.1C.4 deployed the C.3 private-result and thumbnail schema/handlers. This document preserves its original dated findings; its earlier “not deployed”/version notes are historical. See [current hosted versions, verification and genuine-product/device/cleanup limitations](PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md).

Date: 2026-11-04 (Asia/Manila).
**Decision: PASS WITH LIMITATIONS for the protected hackathon testing deployment.**
The missing hosted publication gate is resolved. The owner explicitly deferred the
real-product/Muse/device/operator-approval test during this task; those checks are
**not passed** and no full real-product release certification is claimed.

## Committed source and target

Committed the previously tested T07.1D changes first:
**`a9891ec64d3ed390e2d92b2ef801a85c467a2659`** —
`Verify T07.1D integrated regression and record hosted release blockers`.
The working tree was clean before deployment. Application/trust implementation is
unchanged from `667aa34`; `a9891ec` contains the tested native fixtures and QA docs.
No application source or migration was modified for this rollout.

Verified target: existing Pickwell project **`bzmqgjinbjykhqqswdva`**, matching the
existing public Flutter configuration. Pinned CLI **2.122.0**, API-based Edge
bundling, no Docker. Read applicable repository instructions and current PRD, SPEC,
DATABASE, TASKS, prompts, [release gate](PICKWELL_RELEASE_GATE.md),
[Product Trust](PICKWELL_PRODUCT_TRUST.md) and
[front packaging](PICKWELL_FRONT_PACKAGING.md).

## Safe rollout and deployed versions

Preflight found cloud migration `20261103000900`, analysis v20, lookup v7, no trust
gate/table, inference enabled, zero in-flight/unknown provider calls and zero staged
candidates. Dry run listed **exactly** the two requested migrations, with no seeds
or roles. Existing data and native compatibility evidence were reviewed.

1. Temporarily set `inference_enabled=false` under the existing provider/admission
   transaction lock, with an audited rollout reason. Confirmed no work needed draining.
   Guest cache reads remained available. No model request was submitted during pause.
2. Applied both forward migrations in order; no reset, migration repair, sample seed,
   record removal or approval bypass. The old intermediate publisher could not accept
   new inference while these migrations/functions were being installed.
3. Deployed compatible handlers/shared dependencies and verified actual hosted
   database guards/grants and Edge behavior while inference stayed paused.
4. Restored `inference_enabled=true` only after hosted tests and secret-name checks
   passed. Limits/spend controls were unchanged; billing remains false.
5. Final migration dry run reports **up to date**, with zero migrations/seeds/roles.

| Migration | Deployed SHA-256 of repository file |
| --- | --- |
| `20261104000100_pickwell_front_packaging.sql` | `abab4b23713ce1c4cca0f8d56467fbb80adde7dd595511c4c83f63b770b08ae5` |
| `20261104000200_pickwell_product_trust.sql` | `7657fd05a688b45f25d53c7d27dcbfd4dacd3fd8c7bf2d1420de92caccfa0553` |

| Edge function | Hosted version / state | JWT boundary |
| --- | --- | --- |
| `analyze-product` | **21 / ACTIVE** | Gateway verification plus persistent confirmed-user Auth check |
| `get-product` | **8 / ACTIVE** | Public sanitized cache read with existing rate/quota controls |
| `cancel-analysis-review` | **1 / ACTIVE** | Handler verifies confirmed nonanonymous identity, ownership and throttle; gateway JWT disabled deliberately |
| `get-analysis-status` | **1 / ACTIVE** | Gateway and owner-scoped handler; updated shared sanitized projection |

`get-analysis-status` was also deployed because it imports the changed shared
projection. No unrelated functions, model modes, credentials, Auth provider settings
or billing services were changed. Required private server secret **names** were
confirmed present; values/digests were not included in reports or Flutter.

## Hosted checks actually executed

| Check | Observed outcome |
| --- | --- |
| Existing hosted boundary harness | **30 passed**: refreshed existing verified session, guest cache/miss, malformed/forged input, protected table writes/jobs reads, guest/forged analysis denial |
| New targeted Edge checks | **14 passed**: guest/verified review-table and inspect/gate/approve/publish RPC denial; guest cancel rejected; extra cancellation authority field rejected; missing front rejected; three bounded images pass parser but paused inference returns `inference_disabled` before any provider call |
| Hosted SQL transaction fixture | **12 passed**, all fixture changes **rolled back**: unapproved candidate stays private; barcode/input/candidate/policy binding; changed input digest denied; rejection/cancellation/real timed expiry clear candidates and release reserved allowance without increasing successful usage |
| Hosted grants/function definitions | Review RLS enabled; no ordinary review read/approval/publication authority; service publisher callable. Both publisher and lower usage finalizer contain the operator-approval enforcement |
| Maintenance | Existing active `*/5 * * * *` job calls `pickwell_prune_analysis()` and `pickwell_reconcile_expired()`; new prune function applied. Timed expiry/cleanup behavior executed inside rollback fixture; scheduled success at **2026-11-04 02:00:00 UTC** after restoration, with no recorded failure |
| State preservation | Provider rows **15 → 15**; candidates **0 → 0**; Storage objects **0 → 0**. Original catalog records preserved; rollback fixtures leave no fake products, jobs, usage or review rows |
| Final config/dry run | Inference restored, billing false, original 1000/100 and spend/concurrency settings unchanged; no pending migrations |

The transaction fixture temporarily enabled inference **inside its uncommitted
transaction only**, while outside readers saw the paused configuration. It simulated
provider metrics to exercise SQL lifecycle functions but made **no Meta request**.
Those metrics, usage/audit records, jobs/candidates/reviews and temporary result
tables were rolled back. They are not real product evidence or a successful live
analysis. It did not approve or publish any real or synthetic product permanently.

Hosted review bindings were checked against canonical fixture JSONB and its digest.
Actual ordered-image digest parsing/model request structure remains covered by the
committed T07.1D native/fixture tests. This run does not pretend it tested genuine
package identity from photographs.

Prior committed T07.1D verification remains **150 Flutter, 181 backend/native tests,
142 SQL assertions, 21 tooling tests**, analyzer/build/APK scans passed. Those broad
checks were not unnecessarily rerun for unchanged source. This task adds the fresh
hosted results above. No failed hosted assertion remains. Fresh real product,
physical device and inbox-delivery checks are deferred/unexecuted, not counted as
passing mocked tests.

## Commands and receipts

From repository root, using the existing authenticated CLI and explicit project:

```sh
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --dry-run --skip-vault
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --skip-vault --yes
npx --yes supabase@2.122.0 functions deploy analyze-product --project-ref bzmqgjinbjykhqqswdva --use-api
npx --yes supabase@2.122.0 functions deploy get-product --project-ref bzmqgjinbjykhqqswdva --use-api
npx --yes supabase@2.122.0 functions deploy cancel-analysis-review --project-ref bzmqgjinbjykhqqswdva --use-api
npx --yes supabase@2.122.0 functions deploy get-analysis-status --project-ref bzmqgjinbjykhqqswdva --use-api
```

The guarded private harness used explicit `db query --linked --project-ref ...
--file ... --output json` for preflight/pause/enforcement/rollback-test/restore
queries. Logs/results remain under ignored `.secrets/t071d1-*`; no credentials or
user identifiers were put in public documentation. Baseline security harness:
`node .secrets/t071-hosted-boundary.mjs`; targeted test helpers:
`.secrets/t071d1-edge-checks.mjs` and `.secrets/t071d1-hosted-sql-test.mjs`.
Do not run the pause-only Edge assertion helper after restoration: its expected
`inference_disabled` response intentionally depends on the rollout pause.

## Model, spend and privacy

Model remains **Muse Spark `muse-spark-1.3`** at
`https://api.meta.ai/v1/chat/completions`, one server-side three-image request,
`label_analysis_v3` schema / `label-analysis-v3` prompt, 30-second timeout and
4,096 max completion tokens, `store=false`. No new model or credential setting.

- **Live Meta calls in this task: 0.** No latency/token/extraction-accuracy/live-cost
  measurement; rollback fixture metrics are synthetic.
- Protected hackathon allowances: **1000 barcode / 100 successful analyses per UTC
  day**, unchanged. Standard production baseline remains **30/3**, not activated.
- Existing global spend ceiling **$100/day**, reserved per-call ceiling **$1.34**,
  global call cap **500/day**, per-user **100/day**, IP **500/day**, concurrency **5**,
  unchanged. Ceilings are not measured call prices or a credit-balance claim.
- Billing false; no RevenueCat or webhook activation. Only temporary inference
  pause/restoration and corresponding audited control versions/reasons changed.
- Server label bytes remain request-local with existing cleanup; no photos were
  retained/uploaded for these tests. Private recoverable mobile drafts and minimal
  non-image review retention remain as documented in Product Trust.

## Real product, operator and device results — deferred by owner

The older real fixtures contain nutrition/ingredient pairs but no matching front
photo/exact processed three-image handoff. The owner replied **“let's not test for
that for now”**. No further live analysis or real-approval attempt was made.

| Required real workflow | Outcome |
| --- | --- |
| Actual barcode scan and three-photo camera capture | **Not executed** in this task |
| Fresh OTP inbox delivery | **Not executed**; existing session refresh and confirmed-user Auth checks passed |
| Real Muse response and identity/label extraction | **Not executed**; 0 live calls |
| Real candidate private pending review | **Not executed**; hosted rollback fixture stays private correctly |
| Exact processed-photo handoff and human packaging review | **Not supplied / deferred**; no substituted photos or false verification |
| Real operator CLI approval | **Not executed**. CLI/native behavior is covered by committed T07.1D evidence, not a real hosted review decision |
| Owner same-key check publishes without second Muse call | **Not executed for a real product** |
| Guest retrieves newly approved real result | **Not executed**; existing guest cache retrieval passed |

An iPad was detected; no new app install, camera interaction or device pass is
claimed. No fourth barcode image, dashboard, automatic model approval, comparison
feature or UI polish was implemented.

The operational gate is unchanged: a valid extraction produces private review;
operator inspects candidate and **exact submitted processed evidence** privately,
then approves/rejects exact bindings using the protected CLI. Approval alone does
not publish. The owner must check the same request key before expiry. No evidence
means no approval. Review is not independent barcode authenticity verification.

## Release disposition and next dependency

The previous **missing-hosted-gate P0 blocker is resolved**. The protected testing
deployment is **PASS WITH LIMITATIONS**, with real three-photo/Muse/operator/device
validation explicitly deferred by the owner. T07.1D/D.1 must not be marked as a
fully verified real-product flow; their deferred acceptance items stay unchecked.

T07.2 **preparation can safely proceed** using truthful functionality and the scope
above. Submission readiness and a genuine current three-photo approval demo are
**not yet signed off**. Before claiming that demo works, provide the matching real
product/barcode, exact processed photos, review honestly, and observe same-key
publication/guest reuse without another Meta call. Do not present mocked or rolled-
back fixture results as real product inference.

Human review mistakes, forged packages/barcodes, privileged service/DB compromise,
hallucinated raw transcription and unaudited legacy associations remain limits.
No automatic trust score or independent verification claim is added. Keep T07.1A
paused; no other task, especially T07.2, was begun automatically.

Deployment source remains committed at `a9891ec`. This report and status reconciliation
are subsequent uncommitted documentation only; no local work was overwritten.
