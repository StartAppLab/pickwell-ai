# T07.1B — Product Identity & Data Integrity Audit

**Date:** 2026-11-04 (Asia/Manila)

**Reviewed revision:** `469ba36` (`Update pubspec.yaml`), following the committed Home/icon polish. Working tree was clean at audit start.

**Scope:** Read-only source/schema review and offline probes. No application code, migrations, deployments, credentials, configuration or production data changed. This file is the audit deliverable. T07.1 remains complete for its recorded hackathon testing profile; this report adds a different threat model. T07.1C/D are not implemented or signed off.

## Verdict

**An authenticated contributor can potentially contaminate an uncached barcode with another product's readable label data.** The server binds the supplied barcode to image hashes for idempotency, not to independently established product identity. Neither the model request nor the validator has evidence connecting those labels to the code. Accurate, schema-valid extraction from the wrong product can therefore reach publication. The shared cache then amplifies that first association.

This is a **P0 integrity gap for unrestricted public contributions**, even with working authentication, RLS and quotas. It is not evidence that any current production record has been poisoned. No malicious submission was sent to the hosted service. Publication RPC behavior was inspected in SQL; its JavaScript caller was exercised with an in-memory mock, not a real database.

Existing ready records are substantially better protected: new submissions return the existing record, publication rechecks the cache transactionally, revisions are immutable, and clients cannot directly overwrite them. The observed problem is **first accepted submission wins**, not an identified arbitrary-update or duplicate-row exploit.

## 1. Evidence and execution boundaries

Read root/mobile instructions, Supabase README, PRD v1.5, SPEC v1.3, DATABASE v1.1, TASKS v1.2 and [T07.1 evidence](PICKWELL_END_TO_END_QA.md). Reviewed current Flutter capture/submission, Edge handler, Meta adapter, validator, publication/admission/lookup migrations and existing tests. The planning documents' future Passport/identity protections are not treated as implemented.

| Check | Observed result |
| --- | --- |
| `node /tmp/pickwell_identity_audit.mjs` | **10/10 offline probes passed**: several intentionally assert acceptance of unsafe identity/content cases, demonstrating gaps rather than safety. Synthetic image bytes and model output; actual parser/adapter/validator/publication wrapper/sanitizer; all external interfaces mocked. |
| `env -u PICKWELL_NATIVE_STATUS node --test supabase/tests/analysis_validation.test.mjs supabase/tests/interpretation.test.mjs supabase/tests/analysis_authorization.test.mjs supabase/tests/security_boundary.test.mjs supabase/tests/get_product.test.mjs` | **54 passed, 0 failed, 2 skipped**. Native Auth/REST/DB cases explicitly skipped; no database started/reset. |
| Migration/constraint/transaction review | Static inspection of versioned SQL; fresh SQL execution, concurrency measurement and hosted schema drift are **not verified in this audit**. Prior successful native/hosted tests remain historical evidence in T07.1. |
| Live images/model/hardware/hosted service | **Not exercised**. No credential files read, OTP sent, provider/network call made, or production data inspected/mutated. No new provider latency, tokens or cost measurement; audit provider cost is zero. |

The temporary probe script is outside the repository. Its cases are specified below so T07.1C can promote the relevant reproductions into permanent regression tests with the fixes. No source or test files were added by this audit.

## 2. Primary scenario traced through the real implementation

| Stage | Actual behavior and references | Identity consequence |
| --- | --- | --- |
| Scanner | [catalog_view.dart:67](../mobile/lib/src/features/catalog/presentation/views/catalog_view.dart#L67) takes the first detected barcode and stops scanning; [catalog_cubit.dart:26](../mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart#L26) normalizes it. Miss routes to `/capture/<barcode>` at [catalog_view.dart:190](../mobile/lib/src/features/catalog/presentation/views/catalog_view.dart#L190). | Syntax/check digit is checked; product versus shelf context is not. No barcode/package evidence is retained from this scan. |
| Capture and OTP resume | [label_capture_cubit.dart:171](../mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart#L171) activates a draft by normalized code; captures are separate. [analysis_submission_cubit.dart:70](../mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart#L70) snapshots the barcode and both photos; [capture_entry_view.dart:160](../mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart#L160) gates submission through OTP. | Protects against stale async state/capture loss, not the user's choice of a different package. No verified name/brand/front-package evidence is established. |
| Flutter upload | [analysis_api_service.dart:100](../mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart#L100) sends barcode, UUID key and exactly nutrition/ingredient image files using the signed-in session. | Name and brand are not accepted as identity authorities; they are not fields in the submission contract. A modified client can call the same API directly. |
| Server input/auth | [analysis_authorization.mjs:9](../supabase/functions/_shared/analysis_authorization.mjs#L9) checks Auth's confirmed non-anonymous user. [analysis_input.mjs:50](../supabase/functions/_shared/analysis_input.mjs#L50) enforces exact fields, barcode format/check digit, UUID, image byte/dimension/structure bounds and distinct bytes. Its digest includes barcode plus both image hashes. | Verified email establishes who submitted, not which product was photographed. Different valid barcodes can accompany the same image pair. Hash binding prevents changed same-key retries; it is not physical identity verification. |
| Admission | [orchestration migration:71](../supabase/migrations/20261103000100_pickwell_analysis_orchestration.sql#L71) checks cache, input digest replay and reservation. [analyze_product.mjs:81](../supabase/functions/_shared/analyze_product.mjs#L81) applies admission before provider work. | Prevents duplicate provider work and returns existing results, but no catalog/label association is checked for a new code. |
| Muse request | [analyze_product.mjs:110](../supabase/functions/_shared/analyze_product.mjs#L110) passes only `input.images`; [core.mjs:140](../supabase/spikes/meta-vision/core.mjs#L140) sends two images to `muse-spark-1.3` at `https://api.meta.ai/v1/chat/completions`. The user message says the images are “for the same product.” | Requested barcode is absent from the model input. There is no required visible barcode field, independent catalog reference or package association check. The prompt frames sameness as an assumption, although other instructions request mismatch detection. |
| Extraction/validation | [analysis_validation.mjs:14](../supabase/functions/_shared/analysis_validation.mjs#L14) has nullable names, `consistent/unknown/mismatch` and food form, without brand/variant/package-size/barcode evidence. [line 130](../supabase/functions/_shared/analysis_validation.mjs#L130) rejects model-reported mismatch; unknown is allowed and adds a warning at [line 216](../supabase/functions/_shared/analysis_validation.mjs#L216). | No independent comparison of the two names or comparison with the scanned barcode. Two truthful Product B labels can be `consistent` and pass under Product A's code. Model certainty has no verified-identity meaning; no numeric identity confidence exists. |
| Revalidation/publication | [analysis_publication.mjs:3](../supabase/functions/_shared/analysis_publication.mjs#L3) recomputes validation and compares it to the immutable staged result. [publish migration:55](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L55) binds model/version/ownership/candidate; [line 77](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L77) creates a product using the request's barcode, and [quota finalizer:284](../supabase/migrations/20261102000300_pickwell_quota_controls.sql#L284) publishes atomically with one successful credit. | Re-running the same validator cannot supply missing identity evidence. No identity approval predicate is required. Normal new publication inserts only the barcode into `products`; name/brand may stay null. |
| Public cache | [published view:8](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L8) filters on `status='ready'`; [lookup migration:39](../supabase/migrations/20261102000500_pickwell_product_lookup.sql#L39) retrieves by barcode; [get_product.mjs:80](../supabase/functions/_shared/get_product.mjs#L80) checks response code and sanitizes. | Guest gets the wrong associated facts without an OTP wall or another model call. Response-barcode equality proves internal consistency, not package identity. [catalog_model.dart:18](../mobile/lib/src/features/catalog/data/models/catalog_model.dart#L18) likewise checks the code only. |

**No independent trusted identity catalog was found in these active paths.** `products/published_products` is the contribution cache, with an explicitly marked demo seed; the reviewed ingredient/nutrition reference catalog explains ingredients/thresholds, not ownership of retail barcodes. No manufacturer/GS1/other authoritative product lookup is used here. Two back-label photos can sometimes reveal names or even a barcode, but the current contract does not require or verify such evidence; nameless panels cannot establish their association on their own.

## 3. A — Critical before unrestricted public contribution/submission

Public repository/demo submission can describe a restricted testing service truthfully. These findings must be resolved or the affected shared-publication capability explicitly restricted before claiming public contribution integrity. Warnings or lower quotas alone do not fix A1.

### A1 — P0: Unverified barcode-to-label association can become a shared ready record

**Demonstrable path:** Start with an uncached valid A barcode, attach two real/readable B panels, authenticate normally and stay within limits. If Muse extracts B accurately with `consistent` or `unknown`, validation succeeds. Publication uses the request's A barcode and has no independent association predicate. Other users then retrieve B's facts by A. Same-product variants, a valid shelf GTIN and deliberately manufactured labels have the same missing trust boundary.

**Observed probes:** Same two synthetic image inputs parsed successfully with two different valid codes and different request digests. The real provider adapter omitted the requested code. A B-labelled candidate passed validation and the real publication wrapper reached `pickwell_publish_analysis`; the mocked database returned its B facts under A and the sanitizer preserved them. This establishes the application acceptance gap; successful poisoning of a live SQL database was not attempted.

**Existing safeguards:** Auth/verified email, input validation, quotas/spend admission, hashes/idempotency, server-only candidate staging and publication. None verifies product identity. A perfect model extraction does not fix an incorrect input association.

**Minimal viable mitigation (T07.1C):** Put an explicit server-owned association/review gate before shared `ready` publication. For the hackathon, restrict shared writes to reviewed demo contributions and approved barcode/input-digest associations or an equivalently explicit operator-reviewed candidate. Bind approval to the exact barcode, evidence/input digest and accepted candidate/revision; an account allowlist or a barcode-only allowlist is insufficient by itself. Unapproved requests must stop safely without publishing or consuming a successful-analysis credit. Keep guest reads and existing accepted cache records accessible. If a safe approval path cannot be completed, keep new shared publication restricted and document that limitation rather than claim unrestricted identity verification. Broad self-service verification is C1, not a prerequisite to invent before the deadline.

**Backend/DB impact:** Admission/handler and the atomic publication RPC both need policy enforcement; do not rely on Flutter or on a post-write warning. A small versioned server-owned approval mapping may suffice for restricted testing; a durable general review queue would require a reviewed migration and belongs to broader design. Reuse existing safe failure/credit-release behavior for rejected attempts; do not leave indefinite `processing` jobs or quota holds. Do not fabricate a verification flag from model output.

**Tests:** A/B pairs, shelf barcode, no evidence, changed approved bytes/candidate, same-key replay and new-key bypass, two users racing approved/unapproved candidates, direct service-boundary publication without approval, no ready record on rejection, exactly-once settlement, guest cache reuse with zero Meta calls. SQL tests are required in T07.1C/D.

**Regression risk:** Medium–high: publication/admission and error responses are security-sensitive. Test existing cache hits, OTP resume, retained drafts, failures, quota release and lost-acknowledgement recovery.

### A2 — High: Cross-photo consistency is a model assertion, with no contradiction backstop

**Evidence:** [validator:129](../supabase/functions/_shared/analysis_validation.mjs#L129) acts on `identity.consistency`; it does not compare `nutrition_name` and `ingredients_name`. A probe with `Product A plain oats 500g` versus `Product B chocolate cookies 150g` and `consistent` returned `validated` and no identity warning. Explicit `mismatch` correctly returned retakes for both photos. Brand/variant/package size have no dedicated observed fields in [the schema](../supabase/functions/_shared/analysis_validation.mjs#L14).

**Minimal mitigation:** Treat contradictory observed identity as a review/negative-evidence condition independent of the model's favorable enum. For T07.1C, the A1 review gate must include both observed names and any visible variant/size conflict; preserve explicit mismatch rejection. Do not reject every spelling/abbreviation difference, require optional names on all photos, or treat matching names as proof of barcode ownership. A deterministic lexical check can flag a potential conflict for review; it cannot reliably resolve semantic identity by itself.

**Backend/DB impact:** Validator/review contract and bounded safe reasons; a separate identity-policy version is preferable to disguising new semantics under extraction confidence. Enforce the decision at publication. No new database table is inherently required for a narrowly restricted review gate.

**Tests:** Contradictory names with `consistent` and `unknown`; explicit mismatch; same legitimate abbreviated/bilingual name; missing names; differently sized/flavored variants. Prove negative evidence cannot be discarded during normalized-candidate replay.

**Regression risk:** Medium: naive string matching would recreate unnecessary retakes. Restrict the fix to identity review, retaining readable partial OCR and other captured photos.

### A3 — High: Identity observations are discarded, and public output lacks a distinct identity state

**Evidence:** Validation stores names/consistency in `provenance.identity` at [validator:218](../supabase/functions/_shared/analysis_validation.mjs#L218), but [publication SQL:84](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L84) removes that object before storage. Terminal candidates are deleted by [the cleanup trigger:101](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L101); the interpretation refresh also strips identity at [refresh:34](../supabase/migrations/20261103000800_pickwell_interpretation_refresh.sql#L34). [Public sanitizer:115](../supabase/functions/_shared/catalog_boundary.mjs#L115) has no identity-method/result allowlist. Unknown consistency leaves only a prose warning; `consistent` has no warning even though barcode association remains unverified. The offline sanitizer probe confirmed the structured state is absent.

**Minimal mitigation:** Keep a small explicit distinction between extraction validated, cross-photo observations, and barcode association unverified/operator-reviewed. Preserve only safe observed names, consistency, policy/method, review reference/time and revision/input binding where justified. Public output should state the limited identity status; no independently verified badge or invented percentage. Existing records must default to unverified/legacy status, never be retroactively certified.

**Backend/DB impact:** Preserve allowlisted non-image provenance in existing bounded JSON, adjust publication/refresh and sanitized read/model contracts. Existing JSON columns can support a minimal addition; any historical backfill or new constraints require a later reviewed migration. Photo retention is not needed and must not be reintroduced.

**Tests:** Unknown/consistent/operator-reviewed are distinct, legacy default, public PII stripping, provenance survives publication and immutable refresh, stale approval cannot bless a new revision, completed candidates/photos still cleaned.

**Regression risk:** Low–medium with optional additive fields and backward-compatible parsing. This is observability/transparency support for A1, not a substitute for its publication gate.

### A4 — High: Unsupported structured ingredient items can acquire source-backed-looking explanations

**Evidence:** [validator:137](../supabase/functions/_shared/analysis_validation.mjs#L137) notes raw/item wording/order differences but retains unmatched items. [interpretation:84](../supabase/functions/_shared/interpretation.mjs#L84) validates against the extracted item and reference catalog, without checking that item's presence in raw ingredient text. The probe appended `Soy Lecithin` to an oats/wheat/salt-only raw transcription and selected its valid reviewed emulsifier reference: result was `validated`, with a Soy Lecithin explanation despite its absence from raw. The catalog source can verify the general function of an ingredient without establishing its presence in this product.

**Minimal mitigation:** Exclude unsupported ingredient selections from product assertions/summary/background attribution, or explicitly retain them as uncertain observations requiring review. Keep raw text and partial OCR accessible. Use conservative formatting normalization; do not require a whole-image retake for an unmatched item and do not silently certify raw transcription as independent OCR. Fully fabricated matching raw+items still require A1's identity/evidence policy; this backstop fixes only an internal contradiction.

**Backend/DB impact:** Validator/composer changes, versioned interpretation semantics and targeted reference refresh if needed. No table is inherently required. Do not mutate immutable old facts or call the model on ordinary lookup.

**Tests:** Inserted/deleted/reordered items, compound/bilingual ingredients, punctuation/OCR variants, partial unknown spans, unmatched selected/summary ingredient, and retained valid additive explanations. Raw-absent items must not acquire product-presence authority from a reference citation.

**Regression risk:** Low–medium: preserve useful raw extraction and known supported explanations; avoid reverting the approved forgiving OCR behavior.

## 4. B — Safe to defer with the shared-publication restriction in place

### B1 — Medium: Nonempty but nearly unusable extraction can be called validated

[Validator:133](../supabase/functions/_shared/analysis_validation.mjs#L133) and [line 146](../supabase/functions/_shared/analysis_validation.mjs#L146) check nonempty raw text. The probe `Nutrition facts [unknown]`, no nutrient rows, and ingredient raw `[unknown]` was accepted; ingredient items became `['[unknown]']`. Latest [DB nutrition validator:8](../supabase/migrations/20261103000700_pickwell_nutrient_label_units.sql#L8) likewise permits unknown basis and an empty nutrient array. Empty raw labels still fail. This is partly the approved OCR-first policy, not permission to invent missing amounts; it must not be mistaken for a complete product or verified identity.

**Later mitigation:** Distinguish partial/unusable/complete extraction explicitly; show missing data and suppress unsupported conclusions while retaining readable text. Keep identity review independent of nutrition completeness. No new mandatory nutrient minimum or blanket retake is recommended here. Tests: text-only versus wholly unknown labels, no fabricated quantities/findings, existing partial-label publication and draft recovery. Backend/optional JSON quality metadata, no necessary new table. **Risk:** Medium if quality becomes another whole-photo gate.

### B2 — Medium: Already-ready/invalidated records have no contributor conflict-review intake

Existing ready data wins before new inference at [admission:90](../supabase/migrations/20261103000100_pickwell_analysis_orchestration.sql#L90); a conflicting new image pair is not analyzed for differences or quarantined. It cannot overwrite ready data, but also cannot correct a poisoned/stale association. An invalidated row is excluded from cache yet rejected later by [publication:71](../supabase/migrations/20261103000200_pickwell_publish_analysis.sql#L71) with `correction_review_required`; admission/provider checks look for ready records, so such a request can incur model cost before this known block. This latter path is a static finding, not a live cost measurement.

**Later mitigation:** Fail early into an explicit review-required state for invalidated/correction cases; define a small operator correction/invalidation runbook before relying on manual recovery. Never grant contributor overwrite rights. Tests: existing-ready conflicting request yields unchanged cache/zero model; invalidated request avoids provider spend; reviewed correction creates a new revision and preserves old history. Backend/error contracts; general intake/queue schema belongs to C2. **Risk:** Low–medium for early block, higher for a full correction workflow.

### B3 — Medium: Repeated abuse is volume-limited, not trust-aware

[Provider admission:210](../supabase/migrations/20261102000300_pickwell_quota_controls.sql#L210) enforces replay, global/user/IP concurrency, spending and daily user/IP/barcode call limits. [Network hashing:13](../supabase/functions/_shared/quota_boundary.mjs#L13) uses configured proxy trust, else a shared unknown-network bucket. Authenticated users still can submit false facts within limits, and account rotation is not product verification. No active contributor reputation, poisoning-specific blocklist or discrepancy escalation was found. Current hosted caps/proxy deployment were not re-read; the historical QA testing allowance exception is not evidence of today's exact runtime values.

**Later mitigation:** Restricted publication plus minimal redacted identity-conflict events/operator suspension, without permanent images or identity-score profiling. Tests: fresh keys/accounts cannot bypass approval; repeated rejection bounded before model, shared-IP fairness, spoofed proxy headers and retention. Dedicated abuse metadata/migration only if justified. **Risk:** Medium for account/IP policy; defer broad reputation design.

## 5. C — Broader post-hackathon design

| Item | Required design/change | Tests and risk |
| --- | --- | --- |
| C1 — Actual product identity verification (T08.1/T08.3) | Define evidence tiers and verification method; conditional front/package/barcode evidence, independent source/license/freshness when available, product/brand/variant/size matching and explicit unknown/conflict handling. Two nameless back panels cannot establish identity by themselves. Merely sending the barcode to Muse, matching names, or asking a user to confirm does not solve malicious substitution. Review bounded non-image provenance and separate identity/extraction/publication state. | Shelf codes, same-brand variants/sizes, edited labels, copied barcodes, adversarial model assertions, real-product evidence; high design/regression risk. No verified badge until the method has actually run. |
| C2 — Reformulation, barcode reuse, disputes and safe corrections (T08.1/T08.3) | Versioned formulation identity/effective context, immutable history, review authority, invalidation and disputed/replacement current-pointer rules. Current single normalized-code uniqueness solves duplication, not timeless formulation identity. Operator reference refresh cannot change nutrition/ingredients/findings ([refresh:26](../supabase/migrations/20261103000800_pickwell_interpretation_refresh.sql#L26)). | Old/new formulations, ambiguous simultaneous variants, concurrent corrections, stale refresh/replay, guest projection and history; high risk to data model/cache correctness. |
| C3 — Bounded evidence investigation and mature abuse review (T08.4) | Specific server-validated requests for missing evidence, allowed actions, finite rounds/cost, authorization, cancel/expiry, privacy and escalation. Not general chat or self-authorized model publication. | Prompt injection, evidence laundering, bad actions, loops, budgets and malicious retries; medium–high architectural risk. |

None of these broader features is implemented by this report or required to pretend an unrestricted verification system exists before submission. CKD-related information remains educational; no diagnosis, personalized prescriptions or safety certification.

## 6. Scenario results

| Scenario | Current outcome | Evidence level / finding |
| --- | --- | --- |
| Primary: A barcode, both photos B | Can pass and reach publication under A if A is uncached; schema and good OCR do not establish identity. | Actual parser/adapter/validator/publication-wrapper probes; DB association statically traced. A1. |
| 1. Nutrition A, ingredients B | Explicit model mismatch rejected; `unknown` or erroneous `consistent` accepted. | Validator probes, including clearly conflicting names. A2. |
| 2. Name/brand absent or contradictory | Name/brand not accepted as verified client fields; nullable observed names are allowed; contradictions are not independently checked. Normal creation does not populate product name/brand from those observations. | Input schema, validator probe, SQL insert. A2/A3. |
| 3. Same barcode, different variant/size | No dedicated variant/size evidence; first accepted uncached submission can win. Later submission hits ready cache. | Schema/SQL inspection and conflicting-name probe. A1/C1/C2. |
| 4. Two conflicting users simultaneously | Global advisory lock, unique active barcode job and unique product barcode protect duplicate writes/provider admission. Other user sees processing without another owner's job; later gets winning cache. No content consensus or conflict arbitration. | Static SQL; historical T07.1 concurrency tests, not rerun here. A1 remains. |
| 5. Existing ready product differs | New submission returns existing data; no demonstrated contributor overwrite, conflict quarantine or correction intake. | Admission/publication SQL and immutable-revision review. Safeguard plus B2. |
| 6. Repeat poisoning attempts | Auth/rate/quota/spend bounds constrain volume; allowed attempts can still poison new codes. Fresh keys cannot alter same-key binding but are not a trust check. | Static admission/limits; no hosted abuse attempt. A1/B3. |
| 7. Muse accurately/confidently reads wrong product | Still accepted if schema/content checks pass; no independent verification or confidence-based defense exists. | Offline B-labelled response reaches real wrapper's publish RPC. A1. |
| 8. Incomplete but schema-valid extraction | Readable partial/unknown fields intentionally proceed; empty raw rejected. Near-empty placeholder case also passes. Unsupported structured ingredient attribution reproduced. | Probes. B1/A4; do not restore blanket OCR rejection. |
| 9. Shelf barcode | Invalid/non-GTIN/check-digit failure rejected. A valid shelf code/another product's retail GTIN cannot be distinguished from intended package ownership by normalization. | Scanner/check-digit source and A/B parser probe; no live shelf scan. A1/C1. |
| 10. Legitimate label/formulation change | Ready cache remains; contributor cannot replace it. Basic invalidation/history exists, but no complete formulation/dispute workflow. | SQL and operator refresh review. B2/C2. |

## 7. Existing protections to preserve

- Trusted server-side confirmed non-anonymous identity; no client-supplied Premium/verified/publication authority.
- Strict upload bounds/format checks, two different image byte hashes, canonical/check-digit barcode, exact form fields, image-bound idempotency.
- RLS/revoked client grants and service-only RPCs; staged candidates tied to owned successful provider attempts and immutable versions.
- Transaction-scoped advisory lock `725021003`, unique active barcode job and unique canonical product barcode; repeated and simultaneous requests share one outcome, not a quality vote.
- Publication cache recheck, refusal to replace non-processing/already-revised rows, immutable analyses/findings and compare-and-swap operator interpretation refresh.
- Deterministic nutrient rules, explicit unknowns, source/reference/prose restrictions and explicit mismatched-photo rejection. Source citations establish a rule/background statement, not that its input ingredient belongs to the scanned product.
- Atomic successful-credit settlement; failed/retake/cache-hit attempts release rather than spend successful-analysis allowance; provider costs remain independently accounted.
- Images are request-local server memory and are nulled after provider/finally paths ([handler:120](../supabase/functions/_shared/analyze_product.mjs#L120)); completed local drafts are discarded ([submission:102](../mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart#L102)). Existing bounded recovery is distinct from permanent photo retention. No public contributor email/image payload is introduced by the proposed mitigations.

## 8. Minimal next task and release disposition

**Recommended T07.1C order:** (1) enforce restricted, evidence-bound shared publication; (2) include contradictory identity observations in its review decision and preserve minimal explicit identity provenance/status; (3) suppress unsupported structured ingredient attribution while retaining readable raw/partial OCR; (4) run negative API and real isolated SQL publication/race/quota/cleanup regression. Do not auto-certify existing cache entries; assess any suspicious records through authorized operator review later. No production record was inspected or changed here.

Do not broaden retake thresholds, add confidence scores, build a trusted global catalog, retain label photos permanently or implement the full T08 queue/investigator in this fix. A prompt-only change or generic “check the package” disclaimer cannot satisfy A1. If the necessary publication control cannot be safely verified, keep public shared contributions restricted and demo only reviewed records, with the limitation accurately documented.

**T07.1B report delivered. T07.1C is the next implementation dependency; T07.1D must verify its fixes before unrestricted release.** No safety mitigation was implemented, no release gate passed, and no existing TASKS checkbox or historical T07.1 result was altered. RevenueCat remains deferred; billing/configuration were untouched.
