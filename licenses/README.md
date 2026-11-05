# License evidence and inventory

Collected November 5, 2026 for T07.2A.1. These documents preserve third-party rights;
they do not apply an open-source license to original Pickwell code. Start with
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) for attribution scope and exceptions.

| File | Coverage |
| --- | --- |
| [asset-inventory.csv](asset-inventory.csv) | 216 asset path/blob variants across 124 paths in reachable history; 122 current records. Includes binary assets and inline website artwork. Owner attestations and verified license evidence are distinct. |
| [dart-dependencies.csv](dart-dependencies.csv) | 282 resolved pub-cache packages, versions, upstream URLs, license filenames and SHA-256 digests |
| [dart-dependencies.txt](dart-dependencies.txt) | Exact root license texts for those Dart packages, including Hugeicons |
| [npm-dependencies.csv](npm-dependencies.csv) | 1,081 distinct name/version pairs from both pnpm lockfiles; exact-version registry license metadata, with zod-to-ts release-text fallback |
| [ruby-dependencies.csv](ruby-dependencies.csv) | 103 exact Gemfile.lock versions; RubyGems metadata, with release-license fallback for babosa and colored |
| [sources.json](sources.json) | Retrieved upstream notices, flag comparisons and four exact native iOS source pins |
| [icon-source-matches.json](icon-source-matches.json) | Exact normalized path-geometry comparisons for matched icons only |
| [manifest.json](manifest.json) | SHA-256 of the evidence files in this directory, excluding itself |

Readable full texts include Manrope OFL and its embedded notices, flag-icons MIT,
shadcn/ui MIT, Hugeicons MIT, Font Awesome Free notices, Simple Icons CC0,
Flutter, Pillow, zod-to-ts, babosa, colored and the four pinned native licenses:
[PostHog](posthog-ios-LICENSE),
[RevenueCat hybrid](purchases-hybrid-common-LICENSE),
[RevenueCat iOS](purchases-ios-spm-LICENSE),
[Sentry Cocoa](sentry-cocoa-LICENSE.md).

Method: enumerate every reachable commit's tree for asset paths/versions; inspect
font name tables and copied component configuration; compare public SVG geometry;
read exact local resolved Dart package notices; fetch pinned native notices and
exact npm/Ruby release metadata over HTTPS. No downloaded package code was executed
for the license inventory. Archive fallbacks read license files in memory.

Limits: registry metadata is a declaration, not a complete legal opinion or proof
of every transitive binary obligation. Platform SDK/Maven and built-app notices
need release-specific review before binary redistribution. Existing ignored build
artifacts and private validation environments are not included in this repository.
No third-party trademark grant is inferred. Original and historical free-asset
source gaps are explicitly recorded under the owner's requested review boundary.

Upstream legal texts are preserved byte-for-byte. The local `.gitattributes`
disables whitespace diagnostics only for copied license-text files; generated
CSV inventories use LF endings. Source hashes remain independently checked.
