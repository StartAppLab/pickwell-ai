# Pickwell AI

Pickwell helps shoppers understand packaged-food labels. Scan a barcode to reuse
an approved shared result without an AI call. For an unknown product, capture
**Front packaging → Nutrition facts → Ingredients**, verify your email with
Supabase OTP, and request a server-side Meta Muse Spark analysis.

Label facts, unknown values and evidence-based explanations are distinct from
independent product verification or medical advice. There is no overall health
score. Private analysis does not automatically publish a shared product.

## Architecture and scope

- `mobile/`: Flutter iOS/Android app; Bloc/Cubit state, GoRouter, feature/domain/data
  layers, temporary local capture drafts and owner-scoped private result references.
- `supabase/`: PostgreSQL migrations/RLS, authenticated Edge analysis and private
  reads, guest-capable shared lookup, server-owned quotas and publication controls.
- Meta Muse Spark: the backend calls `https://api.meta.ai/v1/chat/completions`
  with model `muse-spark-1.3`, using three bounded images. Server validation and
  deterministic rules control accepted facts/findings; model certainty grants no
  publication authority. Provider credentials never belong in Flutter defines.
- `web/` and `website/`: inherited Next.js/Astro starter projects, not the Flutter
  hackathon demo. Their presence does not establish deployed Pickwell features.

StartAppLab supplied the application framework, reusable integration scaffolds and
web/website starters. Pickwell-specific barcode, capture, analysis, trust, private
result, thumbnail, quota and catalog work is described in [task history](docs/PICKWELL_TASKS.md).
This attribution does not establish redistribution rights for inherited materials.

## Flutter setup

Use FVM. The documented validation baseline is Flutter **3.47.7 / Dart 3.13.5**;
`mobile/.fvmrc` tracks `stable`, so it is not an immutable version pin. Android
requires Java 17 and Android SDK tooling; iOS requires macOS/Xcode and uses Swift
Package Manager (deployment target 15+). See [mobile instructions](mobile/README.md).

```sh
git clone https://github.com/StartAppLab/pickwell-ai.git
cd pickwell-ai/mobile
fvm install
fvm flutter pub get --enforce-lockfile
mkdir -p .secrets
cp config/pickwell.dev.example.json .secrets/dev.secrets
```

Edit that ignored JSON: `SERVER_BASE_URL` is your Supabase project URL and
`SERVER_API_KEY` is its **public publishable/anon key**. Keep optional auth, enabled
backend and disabled billing/analytics/notifications as supplied. Server-role,
Meta, database and signing secrets must never enter this file or the application.
Configure Email OTP and the documented callback allowlist in your own project.

```sh
fvm flutter run --dart-define-from-file=.secrets/dev.secrets
```

Running without defines starts the inherited offline configuration; it does not
exercise Pickwell's connected analysis flow. A fresh clone's placeholders cannot
access the owner's hosted demo.

## Supabase and Meta setup

Install the Supabase CLI and Docker for a disposable local backend. From repository
root:

```sh
supabase start
cp supabase/.env.example supabase/.env.dev
```

Populate only the ignored server environment: your authorized `META_API_KEY`, the
endpoint/model above, and a cryptographically random `PICKWELL_NETWORK_HASH_SECRET`
(at least 32 bytes). Supabase supplies its reserved server variables. Configure
trusted proxy headers only after verifying ingress behavior. Set the mobile URL
and public key for this local stack; local OTP delivery uses the stack's mail inbox.

```sh
supabase functions serve --env-file supabase/.env.dev
supabase test db
```

Migrations in `supabase/migrations/` define schema, RLS, trust and storage. Local
startup applies them. `supabase db reset` is destructive and is appropriate only
for a disposable local stack. Never reset the hosted demo. Inference admission,
spend, quota and billing are server-controlled; supplying a Meta key does not
activate inference. Keep the default controls unless separately authorized.

For an independently provisioned hosted project, coordinate migrations and
compatible Edge deployments using [backend setup](supabase/README.md),
[environment boundaries](docs/PICKWELL_ENVIRONMENT_SETUP.md) and
[rollout procedure](docs/PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md). Do not run
historical rollout commands blindly against an existing project.

## Privacy, Product Trust and shared reuse

- Three photos remain temporary/request-local; the existing bounded local draft
  supports retry/OTP/restart. Original captures are not uploaded to Storage by
  analysis. Bounded retention and operator handoff are documented in
  [capture/private results](docs/PICKWELL_PRIVATE_RESULTS.md).
- A validated successful analysis yields an owner-private result for up to 24 hours
  and consumes one successful-analysis credit exactly once. Rejection/cancellation
  of publication does not refund that successful private analysis.
- [Product Trust](docs/PICKWELL_PRODUCT_TRUST.md) requires an operator decision bound
  to the exact barcode, input digest, candidate and policy before shared publication.
  A front photo/model observation is not independent barcode verification.
- Only published canonical products enter guest-readable shared lookup. Cached
  barcode lookup makes zero Meta calls; private results do not become shared recents.
- [Thumbnails](docs/PICKWELL_PRODUCT_THUMBNAILS.md) are optional front-only JPEG
  derivatives attached by protected operator tooling after publication. They use a
  private bucket and an eligibility-checking public read endpoint. Missing images
  have placeholders. Original front/nutrition/ingredient images remain nonpublic.
  Storage cleanup currently requires the protected operator command; an automatic
  cloud cleanup scheduler is not established.

## Validation

From `mobile/`:

```sh
fvm flutter analyze --no-pub
fvm flutter test --no-pub test/catalog test/app_config_security_test.dart
python3 tool/check_environment.py --config .secrets/dev.secrets
fvm flutter build apk --debug --no-pub --dart-define-from-file=.secrets/dev.secrets
python3 tool/check_environment.py --config .secrets/dev.secrets --artifact build/app/outputs/flutter-apk/app-debug.apk
```

From repository root, `python3 -m unittest discover -s mobile/tool -p 'test_*.py'`
checks configuration/security tooling. `supabase test db` requires the running local
stack. Backend Node SQL suites additionally require the documented isolated
PGlite/native harness; thumbnail tests need the pinned
`supabase/scripts/thumbnail-requirements.txt`. See the feature evidence documents
for exact harness commands and their limits. Unit tests do not establish real
Muse responses, hosted deployment parity or physical-device acceptance.

## Submission status and licensing

See [T07.2A readiness report](docs/PICKWELL_SUBMISSION_READINESS.md) for the reviewed
revision, actual checks and publication blockers. The November 4 hosted rollout
passed with limitations; a genuine current three-photo → private result → operator
approval → thumbnail → guest reuse demonstration remains unverified.

The root [LICENSE](LICENSE) reserves rights to original Pickwell materials while
allowing hackathon inspection/evaluation; it is not an open-source grant.
Third-party components retain their own licenses. Public redistribution rights
for inherited template/assets and required notices must be resolved before
publication. Repository visibility is not changed by this readiness check.
