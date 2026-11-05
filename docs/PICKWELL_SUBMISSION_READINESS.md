# T07.2A — Final hackathon repository readiness

> Historical audit. See [T07.2A.1 remediation](PICKWELL_PUBLIC_REPOSITORY_REMEDIATION.md)
> for subsequent README/notices, owner attestations and complete available GitHub
> inventory. The original checks and dated decision below are preserved.

Date: **November 5, 2026 (Philippine time)**.
**Decision: BLOCKED for an unconditional public-submission recommendation.**
Deadline supplied by owner: November 5, 2026, 10:00 AM Philippine time. This check
neither verifies organizer portal requirements nor claims submission occurred.

## Revision, commits and repository

Application source reviewed/built: **`e57a103a6c655233e3d8ac9328f004695954ce9d`**.
The working tree was clean at entry. Approved UI, backend, migrations, tests and
existing docs were already committed. No untracked nonignored source was pending.
Live `git ls-remote origin` confirmed HEAD/main at that exact revision and no other
advertised branches or tags. Local history is non-shallow, 69 commits, with main
and origin/main at the same revision. Existing repository:
**https://github.com/StartAppLab/pickwell-ai**; GitHub metadata confirms **private**.
Visibility was not changed. This task adds documentation only in a subsequent
ordinary commit; the tested application source is unchanged. No history rewrite.

## Actual final-source checks

| Check | Observed result |
| --- | --- |
| `cd mobile && fvm flutter analyze --no-pub` | PASS, no issues |
| `fvm flutter test --no-pub test/catalog test/app_config_security_test.dart` | **223 passed** |
| `fvm flutter build apk --debug --no-pub --dart-define-from-file=.secrets/dev.secrets` | PASS, Android debug APK; no new install/device acceptance or signed release claim |
| Root `python3 -m unittest discover -s mobile/tool -p 'test_*.py'` | **21 passed** |
| Root `node --test --test-concurrency=1 supabase/tests/product_trust.test.mjs supabase/tests/private_analysis.test.mjs supabase/tests/private_analysis_endpoint.test.mjs supabase/tests/product_thumbnail.test.mjs` | **42 passed, zero skipped**; isolated PostgreSQL/fixtures, not hosted inference |
| `python3 mobile/tool/check_environment.py --config mobile/.secrets/dev.secrets --artifact mobile/build/app/outputs/flutter-apk/app-debug.apk` | PASS, repository/public-config/APK known-pattern checks |
| `git diff --check` | PASS before handoff |

Fresh APK SHA-256:
`6d571a9cb4e8a7551a3427c69c088dd44e134bb72a46ce1040cbaeda54885f8b`.
Artifact: `mobile/build/app/outputs/flutter-apk/app-debug.apk` (ignored).
Build warnings: future Kotlin-plugin compatibility for in_app_review/location/
posthog_flutter; 41 untranslated strings per non-English locale reported. English
build succeeds; this is not full multilingual or iOS device certification.
No new model call, OTP delivery, quota/billing change or deployment was performed.

## Focused full-reachable-history security/privacy audit

No prior full-history **security and IP publication clearance** was located.
The existing [product identity audit](PICKWELL_PRODUCT_IDENTITY_AUDIT.md) concerns
product association threats and is not such clearance. Earlier known-secret checks
explicitly excluded Git history.

Executed a focused audit over `git rev-list --objects --all` and `git cat-file`:
**69 commits, 1,244 trees, 2,033 unique file blobs**. All blob content was scanned,
including historical versions. Commit metadata was inspected for identity exposure.
The local object coverage includes every advertised remote branch/tag because
remote main matches the local complete main and there are no other advertised refs.
No dangling-object, private GitHub server backup or hidden pull-request-ref audit
is claimed.

Patterns: repository scanner's private-key, Supabase secret, provider/Meta token,
credential-URL and privileged service-role JWT checks, plus AWS/Slack/Google key
patterns and broad credential-assignment candidates. Findings print paths/categories
only. **No matching actual credential was identified.** All 26 broad-assignment
candidate blobs were resolved as placeholders, empty examples, fixture-only strings
or source expressions (including password-state/property references). The lone
sensitive-filename candidate was the intentional `.env.fastlane.example`, not a
populated environment. Populated `.secrets`, signing keys and private photo fixtures
were not found among reachable tracked files. The current tree/config/APK scanner
also passed. Temporary audit tooling/output remained outside the repository.

Privacy limits: source/document email candidates include examples/support contacts;
one author/committer email identity exists in history and will become public with
it. Do not publish raw identity/secret scan output. Owner review of that intentional
identity exposure is still required. **58 historical binary assets** (51 PNGs and
seven TTFs) were inventoried, but no comprehensive visual/OCR/person/photo-consent
clearance or arbitrary encoded-secret detection is claimed. Documentation includes
public project identifiers and operational architecture, which are not service
credentials. No secret values are included in this report.

There are no current tracked GitHub workflow files. GitHub reports **zero workflow
runs for the tested commit**. Repository-wide historical workflow runs, logs,
artifacts, releases and attachments could not be enumerated with the available
connector endpoint; an attempted repository-wide artifact endpoint was unsupported.
Their absence is **not verified**. A maintainer must inventory and inspect these
before making the repository public. No artifacts were deleted.

## Intellectual property and redistribution

The root LICENSE reserves rights to original Pickwell materials and permits
hackathon evaluation; it does not grant general open-source reuse. No license was
changed or inferred for inherited third-party work.

- All **282 resolved cached Dart packages** had root license files: 162 BSD-family,
  97 MIT, 20 Apache and three MPL-family detections. This is a heuristic inventory,
  not a complete transitive native/npm/Python redistribution or vulnerability audit.
  MPL packages were `dbus`, `nm`, `upower`; preserve their source/license obligations
  if redistributing covered files/binaries. Dependencies were not upgraded.
- Hugeicons **1.2.0** supplies an MIT license (Halal Labs) in its installed package.
  Free icons and Pro assets have different grants; no Pro purchase or redistribution
  grant is inferred. [Vendor licensing](https://hugeicons.com/docs/faqs/license-questions).
- All seven bundled Manrope TTFs contain copyright, license-text and license-URL
  name-table fields. Thus lack of a separate OFL file alone does not prove missing
  embedded notices. The font uses OFL; preserve its terms and verify complete
  notices accompany the actual redistribution.
  [Upstream OFL](https://github.com/google/fonts/blob/main/ofl/manrope/OFL.txt).
- **Unresolved:** evidence of public-source redistribution rights for the inherited
  StartAppLab template/framework; provenance/permission for reference screenshots,
  starter website images, branding and copied artwork. The root proprietary notice
  cannot grant rights owned by others. Historical copies remain in scope even if
  current assets are later removed.
- No complete native/Node/Python notices manifest or verified hackathon agreement
  compatibility was found. Public inspection and commercial reuse are different
  permissions. Record owner/vendor grants and preserve required license/NOTICE
  texts before an unconditional publication clearance.

## Documentation and deployment/demo parity

Replaced the root starter README with actual Flutter public configuration,
Supabase/Meta setup, architecture, privacy, testing, limitations and licensing
instructions. Corrected current mobile two-photo/cleanup wording, added a current
backend-state pointer, and corrected the submission task's two-image description.
Historical dated evidence remains intact. No task acceptance checkbox was marked
complete. A clean-machine deployment/setup was not performed.

Current docs describe three mandatory photos, exact-bound Product Trust approval,
24-hour owner-private results with exactly-once credit, optional post-publication
front derivatives, and guest shared-cache reuse with zero Meta calls. Private
results do not enter shared recents; originals are temporary. Operator thumbnail
Storage cleanup works historically but has no established automatic cloud runner.

The [C.4 rollout](PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md) records deployed source
`5178ec1` and exact migration hashes/function versions, 130 hosted boundary
assertions, inference restored and unchanged billing/testing limits. Comparing
`5178ec1..e57a103` shows **no backend code or migration changes** (only backend README
text). The fresh pinned-CLI migration dry run reported `upToDate: true`, with empty
migrations/seeds/roles, and made no deployment. Together with function inventory
below, no pending source/deployment mismatch was found. This is not an independent
hash audit of every hosted SQL definition or live control value.
Fresh read-only hosted function inventory using pinned CLI 2.122.0 confirms
ACTIVE versions matching C.4: analyze-product 22, get-product 9,
cancel-analysis-review 2, get-analysis-status 2, get-private-analysis 1 and
get-product-thumbnail 1. Version parity is not a downloaded-bundle hash comparison.

UI changes after that rollout require the freshly built APK: the previously
installed rollout APK does not establish final UI/device parity.

The recorded end-to-end limitation remains: **no genuine current three-photo Muse
→ private result → exact operator approval → thumbnail attachment → guest reuse
pass or unlocked physical-device acceptance is established.** Historical real Muse
spike evidence is not a test of the entire new flow. No new results are fabricated.

## Exact remaining actions before public submission sign-off

1. Record owner/vendor redistribution clearance for inherited template/assets and
   reference images; complete native/npm/Python notices review and preserve required
   license/copyright/NOTICE texts. Confirm root-license compatibility with actual
   organizer submission terms.
2. Inspect GitHub's repository-wide historical Actions runs/logs/artifacts, releases
   and attachments, and review intentional author/contact metadata and binary
   privacy/provenance. If a real credential is found, revoke/rotate it before any
   publication; removing a current file does not remove history. Do not rewrite
   history under this task's restrictions.
3. Hosted migration/function version parity passed this check. Install the new APK on the demo
   device, and perform/record the actual protected three-photo Muse/private-result/
   exact-approval/thumbnail/guest-reuse flow. Use existing approved controls and
   protected manual thumbnail cleanup; do not change quotas, billing or trust rules.
   Record app/source/artifact identity and actual provider/device evidence.
4. Verify the organizer's portal cutoff and required links/materials against the
   owner's November 5, 10:00 AM Philippine-time deadline. Once blockers are resolved,
   obtain explicit authorization for any visibility change, then verify evaluator
   access. No public visibility change or submission is authorized by this report.

Stop here. The code checks pass; publication rights, external artifact/privacy
clearance and truthful final-demo evidence remain incomplete.
