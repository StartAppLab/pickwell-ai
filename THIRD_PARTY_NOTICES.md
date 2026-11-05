# Third-party notices

Original Pickwell materials are governed by [LICENSE](LICENSE). The owner's
StartAppLab foundation and owner-supplied artwork are described in
[COPYRIGHT.md](COPYRIGHT.md). Third-party materials retain their own copyrights
and licenses; the proprietary notice does not relicense or restrict them.

## Bundled fonts, icons and copied components

| Material / scope | Source and license | Preserved notice / evidence |
| --- | --- | --- |
| Seven `mobile/assets/fonts/Manrope/*.ttf` fonts | [Manrope](https://github.com/googlefonts/manrope), SIL OFL 1.1 | [Full OFL](licenses/Manrope-OFL.txt), [embedded copyright/license fields](licenses/Manrope-embedded-notices.txt). Embedded fonts identify the 2019 authors; the upstream OFL also preserves its 2018 notice. Fonts remain OFL, not Pickwell proprietary code. |
| Twelve `mobile/assets/icons/flags/ic_*.svg` flags | [flag-icons](https://github.com/lipis/flag-icons), MIT, Panayiotis Lipiridis | [MIT notice](licenses/flag-icons-MIT.txt). SVG IDs/designs identify this family; nine current files match current upstream after whitespace normalization, six byte-for-byte. Remaining variants are not claimed as exact current-version copies. |
| `web/src/components/ui/` and `website/src/components/ui/` copied components | [shadcn/ui](https://github.com/shadcn-ui/ui), MIT, shadcn | [MIT notice](licenses/shadcn-ui-MIT.txt). Both projects retain shadcn component configuration. Preserve notices for upstream portions when adapting them. |
| Hugeicons Flutter package 1.2.0 | [Package](https://pub.dev/packages/hugeicons/versions/1.2.0), MIT, Halal Labs | [Exact package notice](licenses/Hugeicons-1.2.0-MIT.txt); also in the Dart notice bundle. No Hugeicons Pro grant is claimed. |
| Website `facebook-icon.tsx` geometry | [Simple Icons](https://github.com/simple-icons/simple-icons), CC0 1.0 | [CC0 text](licenses/Simple-Icons-CC0.txt); normalized geometry matches public releases. Brand/trademark rights are separate. |
| Website `quote-icon.tsx` geometry | [Font Awesome Free 6.4.0 quote-left](https://github.com/FortAwesome/Font-Awesome/blob/6.4.0/svgs/solid/quote-left.svg), CC BY 4.0 for icons, Fonticons, Inc. | [Matching release notice](licenses/Font-Awesome-Free-6.4.0-LICENSE.txt). Adapted SVG wrapper; no claim that every website icon comes from this pack. [License terms](https://creativecommons.org/licenses/by/4.0/). |
| Other provider marks, store badges and starter icons | Owner reports that these assets are free and directed no further license-source research on November 5, 2026 | Exact sources/grants remain unverified. See [asset inventory](licenses/asset-inventory.csv). They are not declared Pickwell-owned or assigned an invented MIT/CC0 license. |

Original authors retain attribution in the linked full texts. Normalized-path
comparisons establish matching geometry, not a grant in unrelated files or a
complete record of the version originally downloaded. See
[icon matches](licenses/icon-source-matches.json) and [sources](licenses/sources.json).

Apple, Google and social-provider names/logos remain their owners' marks. No
copyright permission in an icon drawing grants a trademark endorsement or certifies
store availability. Provider policies include
[Google sign-in branding](https://developers.google.com/identity/branding-guidelines),
[Apple App Store marketing](https://developer.apple.com/app-store/marketing/guidelines/)
and [Google Play badges](https://play.google.com/intl/en_us/badges/).

## Source dependencies and tools

- **Dart/Flutter:** [282 resolved package records](licenses/dart-dependencies.csv)
  and their [exact installed license texts](licenses/dart-dependencies.txt), plus
  [Flutter's license](licenses/Flutter-LICENSE.txt). This includes development and
  optional/disabled integrations, not only shipped features. Individual notices may
  contain multiple licenses. The root LICENSE does not supersede them.
- **JavaScript:** [1,081 unique package/version records](licenses/npm-dependencies.csv)
  from both pnpm lockfiles, with exact-version npm metadata. These are fetched
  dependencies, not committed `node_modules`. The absent `zod-to-ts@1.2.0` registry
  field was resolved using its [release LICENSE](licenses/zod-to-ts-1.2.0-LICENSE).
  Metadata inventory is not a replacement for the licenses/notices in actual
  packages or a source-offer audit of a built binary. Inter is OFL-licensed through
  `@fontsource-variable/inter`; its upstream notices must accompany redistributed fonts.
- **iOS native pins:** PostHog iOS 3.92.0, RevenueCat purchases-hybrid-common 19.10.0,
  purchases-ios-spm 5.94.0 and Sentry Cocoa 9.27.0 have notices fetched at the exact
  commits in `Package.resolved`; see [source hashes](licenses/sources.json) and
  [license directory](licenses/README.md). Their presence does not enable analytics,
  purchases or crash reporting in the hackathon configuration.
- **Ruby tooling:** [103 locked gem records](licenses/ruby-dependencies.csv).
  Missing babosa/colored metadata was resolved from their exact gem releases:
  [babosa](licenses/babosa-1.0.4-MIT-LICENSE), [colored](licenses/colored-1.2-LICENSE).
- **Python tooling:** The operator's pinned Pillow 13.0.0 uses its
  [MIT-CMU/PIL notice](licenses/Pillow-13.0.0-LICENSE). It is operator/test tooling,
  not a new Flutter or Edge image-processing dependency.

The dependency inventory includes MPL and LGPL-covered components and alternative
Ruby license grants. An All Rights Reserved application notice does not remove
those components' obligations. Preserve the applicable license/NOTICE and source
availability/relinking requirements when distributing covered files or built apps.
Android SDK/Maven libraries and platform SDKs have additional upstream terms;
those binaries are not vendored or newly redistributed by this documentation task.
No package upgrade, paid asset purchase, provider agreement acceptance or full
native-binary compliance certification is implied.

## Ownership and review boundary

The project owner confirmed permission to publish the SaaS framework and bundled
reference/website artwork. The 2026-11-05 audit inventories current and historical
assets; owner attestations are labeled separately from upstream license evidence.
At the owner's direction, further research on remaining free icons/badges is
out of scope. Unverified files are retained with their status recorded, rather
than relabeled under a new license. Current-file replacement would not clear an
unknown historical grant in the preserved Git history.
