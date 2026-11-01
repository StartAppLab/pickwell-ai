# Store Automation with Fastlane

This setup manages:

- iOS App Store Connect metadata, localized screenshots, and paid-app pricing
- Android Google Play metadata, screenshots, and changelogs generated from the iOS sources
- App Store and Google Play commerce catalogs for subscriptions and in-app purchases

It does not manage app binaries.

Google Play's supported Publishing API does not expose paid-app pricing or the
app category. Those two Android fields must currently be applied in Play
Console; Fastlane cannot upload them. The equivalent source values are
`fastlane/pricing/prices.json` and `fastlane/metadata/primary_category.txt`.

Run all commands from the directory containing `Gemfile` (`mobile/` in this repository). Internal paths and `.env.fastlane` resolution are anchored to the Fastlane directory.

## Requirements

- Ruby 3.4 or newer (below 4.0, as specified in `Gemfile`)
- Bundler 2.4.22
- Fastlane 2.238.0, installed from `Gemfile.lock`
- Existing store records for the platforms being managed
- An App Store Connect API key for iOS operations
- A Google Play service account with access to the Android app

On macOS with Homebrew Ruby, ensure it appears before the system Ruby:

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

Install dependencies:

```bash
gem install bundler -v 2.4.22
bundle _2.4.22_ install
```

## Configuration

Copy `.env.fastlane.example` to `.env.fastlane` and fill in the values for the stores you manage:

```bash
APP_STORE_BUNDLE_ID="com.example.myapp"
APP_STORE_TEAM_ID="YOUR_DEVELOPER_TEAM_ID"
APP_STORE_CONNECT_ISSUER_ID="YOUR_ISSUER_ID"
APP_STORE_CONNECT_KEY_ID="YOUR_KEY_ID"
APP_STORE_CONNECT_KEY_CONTENT="BASE64_ENCODED_P8_CONTENT"
APP_STORE_PRICE_TIER="0"

PLAY_STORE_PACKAGE_NAME="com.example.myapp"
PLAY_STORE_JSON_KEY_PATH=".secrets/google-play-service-account.json"
PLAY_STORE_TRACK="production"
```

Generate the single-line base64 key content with:

```bash
base64 -i /path/to/AuthKey_XXXXXX.p8 | tr -d '\n'
```

`.env.fastlane` contains secrets and must remain ignored by Git.

For Google Play, set exactly one of:

- `PLAY_STORE_JSON_KEY_PATH` for a local service-account JSON file
- `PLAY_STORE_JSON_KEY_DATA` for raw JSON or base64-encoded JSON content

## Metadata and Screenshots

Localized App Store text lives in `fastlane/metadata/<locale>/`, for example:

- `name.txt`
- `subtitle.txt`
- `description.txt`
- `keywords.txt`
- `promotional_text.txt`
- `release_notes.txt`

Localized screenshots live in `fastlane/screenshots/<locale>/`, for example:

```text
fastlane/screenshots/
  en-US/
    01-iphone-home.png
    02-iphone-editor.png
    01-ipad-home.png
    02-ipad-editor.png
```

Keep iPhone and iPad images directly inside each locale folder. Do not add
`iphone/` or `ipad/` subfolders: Deliver infers the Apple display family from the
image dimensions, then orders each family's screenshots by filename. The existing
`ios upload_screenshots` and `ios upload_listing` lanes upload both families using
the same `screenshots_path`; no iPad flag or separate lane is needed.

For an iPad-capable app, supply the required 13-inch iPad set. Apple currently
accepts **2064 × 2752** or **2048 × 2732** portrait images, and the reversed sizes
for landscape. Use actual iPad captures/layouts. Other supported iPad sizes may be
included for their display families. In the pinned Fastlane 2.238.0, the shared
2048 × 2732 size defaults to the modern iPad family; only a deliberate legacy
2nd-generation upload needs the filename hint `APP_IPAD_PRO_129`.
See [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
and [Deliver's device detection](https://docs.fastlane.tools/actions/appstore/#screenshots_path).

Only keep locale folders that this repository should manage. Screenshot uploads
use `overwrite_screenshots: true`, so review the complete intended screenshot sets
before uploading replacements. No screenshots are uploaded by local tests.

This template uploads supplied images. Automatic capture is a separate setup:
iOS Snapshot normally selects iPhone and iPad simulators in a `Snapfile` and needs
a working UI-test target; Android Screengrab uses its device types. No capture
harness or native test target is currently configured here.

Google Play metadata uses Fastlane's standard Supply path:
`fastlane/metadata/android/<play-locale>/`. Keep Android-only short
descriptions in `short_description.txt` and default release notes in
`changelogs/default.txt`. The generated fields are refreshed from the existing
iOS fields. The mapping is:

- `name.txt` to `title.txt`
- `description.txt` to `full_description.txt`
- iPhone images in `fastlane/screenshots/<locale>/` to `images/phoneScreenshots/`
- Authored Android tablet screenshots in `images/sevenInchScreenshots/` and
  `images/tenInchScreenshots/` are preserved in place or copied to a separate output

App Store subtitles and App Store release notes remain iOS-only and are not
copied into Play short descriptions or Play changelogs. The generator maps
locale identifiers where Google differs from Apple and pads screenshots when
necessary to satisfy Play's maximum 2:1 aspect ratio. It uses native image
tooling when available and a bundled portable PNG processor otherwise.
iPad images are excluded from the generated Android phone set using the pinned
Fastlane device-size registry, in both orientations. They are not automatically
converted into Android tablet screenshots. Supply native Android tablet captures
using the standard [Supply folder names](https://docs.fastlane.tools/actions/supply/#images-and-screenshots):

```text
fastlane/metadata/android/en-US/images/
  phoneScreenshots/          # generated from the iPhone set
  sevenInchScreenshots/      # authored Android 7-inch tablet captures
    01-home.png
  tenInchScreenshots/        # authored Android 10-inch tablet captures
    01-home.png
```

Use Play locale names (for example `es-419`, rather than Apple's `es-MX`) for
Android tablet assets. Tablet screenshots are optional and independent of the
iOS screenshot set. Repeated generation preserves
the authored tablet files. New iPad-only locales do not create a phone set, and
obsolete generated phone images are cleared when a locale now contains only iPads.
Files are ordered by name within each device category. Generation with
`screenshots:false` leaves images untouched when editing the standard Android
metadata directory in place. Generated temporary output is ignored by Git.

For an existing app, download its current metadata before editing:

```bash
bundle exec fastlane ios download_metadata
bundle exec fastlane android download_metadata
```

Android downloads are stored as timestamped, ignored snapshots under
`fastlane/downloads/` so they never overwrite source or generated files. Pass
`output:<path>` to select a different empty destination.

## Commands

### iOS

Check required values, key format, and metadata locally:

```bash
bundle exec fastlane ios preflight
```

Require screenshot and pricing inputs in the same check:

```bash
bundle exec fastlane ios preflight screenshots:true config:fastlane/pricing/prices.json
```

Validate or upload listing content:

```bash
bundle exec fastlane ios validate_metadata
bundle exec fastlane ios upload_metadata
bundle exec fastlane ios upload_screenshots
bundle exec fastlane ios upload_listing
```

Add `edit_live:true` to a metadata or screenshot upload only when intentionally editing the live listing.

## Paid-App Pricing

For a simple Apple price tier:

```bash
bundle exec fastlane ios update_price price_tier:0
```

For per-territory pricing, use either JSON or CSV. Passing a config is required:

```bash
bundle exec fastlane ios apply_pricing config:fastlane/pricing/prices.json dry_run:true
bundle exec fastlane ios apply_pricing config:fastlane/pricing/prices.json
bundle exec fastlane ios apply_pricing config:fastlane/pricing/prices.csv
```

Territories use App Store Connect IDs such as `USA`, `DEU`, and `PHL`, not locale codes. The config's bundle ID must match `APP_STORE_BUNDLE_ID`. Preview with `dry_run:true` before applying a new schedule.

### Commerce Catalog

Create or update App Store subscriptions and in-app purchases from a JSON file:

```bash
bundle exec fastlane ios sync_commerce config:fastlane/commerce/app_store.json dry_run:true
bundle exec fastlane ios sync_commerce config:fastlane/commerce/app_store.json
```

The current App Store commerce pass supports:

- creating subscriptions and in-app purchases
- applying territory-specific prices to those products

The current Google Play commerce pass supports:

- creating and updating one-time products
- creating and updating subscriptions, base plans, and subscription offers
- applying per-country regional prices
- activating base plans and offers
- migrating subscription price cohorts

### Android

Check credentials only:

```bash
bundle exec fastlane android preflight
```

Require local metadata files in the same check:

```bash
bundle exec fastlane android preflight metadata:true
```

Validate or upload Play Store content:

```bash
bundle exec fastlane android sync_listing
bundle exec fastlane android validate_listing
bundle exec fastlane android upload_metadata
bundle exec fastlane android upload_metadata_only
bundle exec fastlane android upload_screenshots
bundle exec fastlane android upload_listing
```

The upload lanes regenerate their inputs first and never upload an APK or AAB.
They resolve the latest version code from `PLAY_STORE_TRACK` (production by
default) so Supply can attach localized changelogs to an existing release. Set
`PLAY_STORE_VERSION_CODE` or pass `version_code:<code>` to target a specific
release.
Use `upload_metadata_only` when the service account has Store Listing access
but not the release-note permissions needed for changelog updates.
Pass `changes_not_sent_for_review:true` when you explicitly want the edit held
for review in Play Console.

Create or update Google Play subscriptions and one-time products from a JSON file:

```bash
bundle exec fastlane android sync_commerce config:fastlane/commerce/google_play.json dry_run:true
bundle exec fastlane android sync_commerce config:fastlane/commerce/google_play.json
```

## Project Configuration

Fastlane is embedded in every project generated from this template. Configure
`.env.fastlane` with the new app's store identities and credentials, then copy
the generic commerce examples to `commerce/app_store.json` and
`commerce/google_play.json` and replace their product IDs, prices, and listing
text. Keep the generated production files out of the template until a project
has its real store configuration.

Run `make check-fastlane` before store commands. The generic
`*.example.json` files cover a free app with a lifetime unlock and recurring
weekly, monthly, or yearly subscriptions. Paid-app pricing is optional.

## Local automation checks

Run the Fastlane Ruby regression tests without store credentials or uploads:

```bash
bundle exec ruby -I fastlane/tests -e 'Dir["fastlane/tests/*_test.rb"].sort.each { |file| require File.expand_path(file) }'
```

These cover the local setup validator, mixed iPhone/iPad detection, Android tablet
folders, locale mapping, repeated generation, and portable phone-image padding.
Store authentication and remote upload acceptance still require a configured app.
