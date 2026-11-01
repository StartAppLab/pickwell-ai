.PHONY: test check-native init-mason mason-init

test:
	fvm flutter test --no-pub

# Install Mason and resolve the pinned feature scaffolds.
init-mason:
	fvm dart pub global activate mason_cli
	mason get

mason-init: init-mason

# Development
doctor:
	fvm flutter doctor

analyze:
	fvm flutter analyze

fix:
	fvm dart fix --apply

format:
	fvm dart format lib test

clean:
	fvm flutter clean

get:
	fvm flutter pub get

launcher-icons:
	$(MAKE) get
	fvm dart run flutter_launcher_icons

native-splash:
	$(MAKE) get
	fvm dart run flutter_native_splash:create

fluttergen:
	$(MAKE) get
	fluttergen

build-runner:
	fvm dart run build_runner build

rebuild:
	@echo "Rebuilding the project..."
	$(MAKE) get
	$(MAKE) launcher-icons
	$(MAKE) native-splash
	$(MAKE) fluttergen
	$(MAKE) build-runner
	
run:
	@echo "Running development build..."
	fvm flutter run --debug $(if $(wildcard .secrets/dev.secrets),--dart-define-from-file=.secrets/dev.secrets,)

clean-run:
	$(MAKE) clean
	$(MAKE) rebuild
	$(MAKE) run

check-native:
	fvm flutter build apk --debug
	fvm flutter build ios --debug --simulator

clean-gradle:
	cd android && ./gradlew clean && cd ..

adb:
	adb kill-server
	adb start-server
	adb tcpip 5555

# Staging
build-android-stg:
	@echo "Building Android staging build..."
	fvm flutter build apk --profile --dart-define-from-file=.secrets/stg.secrets

build-ios-stg:
	@echo "Building iOS staging build..."
	fvm flutter build ipa --profile --dart-define-from-file=.secrets/stg.secrets

clean-build-android-stg:
	$(MAKE) clean
	$(MAKE) rebuild
	$(MAKE) build-android-stg

clean-build-ios-stg:
	$(MAKE) clean
	$(MAKE) rebuild
	$(MAKE) build-ios-stg

# Production: validate the exact define file used by Flutter.
APP_CONFIG ?= .secrets/prod.secrets
FEATURE_CATALOG ?= config/features.json
SUPABASE_DIR ?= ../supabase
PLATFORM ?= android
BILLING_PREFLIGHT = python3 tool/check_billing_config.py --config "$(APP_CONFIG)" --catalog "$(FEATURE_CATALOG)" --supabase-dir "$(SUPABASE_DIR)"

.PHONY: preflight-billing preflight-billing-android preflight-billing-ios build-android build-ios
preflight-billing:
	$(BILLING_PREFLIGHT) --platform "$(PLATFORM)"

preflight-billing-android:
	$(BILLING_PREFLIGHT) --platform android

preflight-billing-ios:
	$(BILLING_PREFLIGHT) --platform ios

build-android: preflight-billing-android
	@echo "Building Android production build..."
	fvm flutter build appbundle --release --dart-define-from-file="$(APP_CONFIG)"

build-ios: preflight-billing-ios
	@echo "Building iOS production build..."
	fvm flutter build ipa --release --dart-define-from-file="$(APP_CONFIG)"

clean-build-android:
	$(MAKE) clean
	$(MAKE) rebuild
	$(MAKE) build-android

clean-build-ios:
	$(MAKE) clean
	$(MAKE) rebuild
	$(MAKE) build-ios

# Store automation
HOMEBREW_RUBY_BIN := /opt/homebrew/opt/ruby/bin
ifeq ($(wildcard $(HOMEBREW_RUBY_BIN)/ruby),$(HOMEBREW_RUBY_BIN)/ruby)
export PATH := $(HOMEBREW_RUBY_BIN):$(PATH)
RUBY_BIN := $(HOMEBREW_RUBY_BIN)/ruby
else
RUBY_BIN := ruby
endif

BUNDLE = $(RUBY_BIN) -S bundle _2.4.22_
FASTLANE_IOS = $(BUNDLE) exec fastlane ios
FASTLANE_ANDROID = $(BUNDLE) exec fastlane android
RUBY_REQUIRED_VERSION = 3.4
PRICE_TIER ?=
PRICING_CONFIG ?= $(shell if [ -f fastlane/pricing/prices.json ]; then echo fastlane/pricing/prices.json; elif [ -f fastlane/pricing/prices.csv ]; then echo fastlane/pricing/prices.csv; fi)
SELF_MAKEFILE := $(lastword $(MAKEFILE_LIST))
SELF_MAKE = $(MAKE) -f $(SELF_MAKEFILE)

# Fastlane
fastlane-setup:
	@$(RUBY_BIN) -e 'required = Gem::Version.new("$(RUBY_REQUIRED_VERSION)"); current = Gem::Version.new(RUBY_VERSION); exit(current >= required ? 0 : 1)' || \
		( echo "Ruby >= $(RUBY_REQUIRED_VERSION) is required for Fastlane. Current: $$($(RUBY_BIN) -v)"; \
		  echo "If Homebrew Ruby is installed, run: export PATH=\"/opt/homebrew/opt/ruby/bin:\$$PATH\""; \
		  exit 1 )
	@$(BUNDLE) check >/dev/null 2>&1 || $(BUNDLE) install

check-fastlane:
	$(RUBY_BIN) fastlane/scripts/check_setup.rb --platform both --ios-config fastlane/commerce/app_store.json --android-config fastlane/commerce/google_play.json $(if $(FORBID),--forbid "$(FORBID)")

# App Store - listing
preflight-app-store:
	@echo "Checking App Store Fastlane configuration..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) preflight

preflight-app-store-listing:
	@echo "Checking App Store metadata and screenshot inputs..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) preflight screenshots:true

validate-metadata:
	@echo "Validating App Store metadata..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) validate_metadata

download-app-store-metadata:
	@echo "Downloading current App Store metadata..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) download_metadata

push-metadata:
	@echo "Uploading App Store metadata..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) upload_metadata

push-screenshots:
	@echo "Uploading App Store screenshots..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) upload_screenshots

push-listing:
	@echo "Uploading App Store metadata and screenshots..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) upload_listing

# App Store - pricing and commerce
# Pricing is iOS-only. Commerce sync manages subscriptions and in-app purchases.
# Depending on the app setup, pricing and commerce can overlap; delete the block
# you do not manage through Fastlane.
push-pricing:
	@$(SELF_MAKE) fastlane-setup
	@if [ -z "$(PRICING_CONFIG)" ]; then \
		echo "No pricing config found. Expected fastlane/pricing/prices.json or fastlane/pricing/prices.csv"; \
		exit 1; \
	fi
	@echo "Applying App Store pricing from $(PRICING_CONFIG)..."
	$(FASTLANE_IOS) apply_pricing config:$(PRICING_CONFIG)

push-pricing-dry-run:
	@$(SELF_MAKE) fastlane-setup
	@if [ -z "$(PRICING_CONFIG)" ]; then \
		echo "No pricing config found. Expected fastlane/pricing/prices.json or fastlane/pricing/prices.csv"; \
		exit 1; \
	fi
	@echo "Dry run for App Store pricing from $(PRICING_CONFIG)..."
	$(FASTLANE_IOS) apply_pricing config:$(PRICING_CONFIG) dry_run:true

push-price-tier:
	@$(SELF_MAKE) fastlane-setup
	@if [ -z "$(PRICE_TIER)" ]; then \
		echo "Provide PRICE_TIER, for example: make push-price-tier PRICE_TIER=0"; \
		exit 1; \
	fi
	@echo "Updating App Store price tier to $(PRICE_TIER)..."
	$(FASTLANE_IOS) update_price price_tier:$(PRICE_TIER)

push-app-store-commerce:
	@echo "Syncing App Store subscriptions and in-app purchases..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) sync_commerce config:fastlane/commerce/app_store.json

push-app-store-commerce-dry-run:
	@echo "Dry run for App Store subscriptions and in-app purchases..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_IOS) sync_commerce config:fastlane/commerce/app_store.json dry_run:true

# App Store - workflows
push-app-store:
	$(SELF_MAKE) push-listing
	$(SELF_MAKE) push-pricing

push-app-store-fastlane:
	$(SELF_MAKE) preflight-app-store-listing
	$(SELF_MAKE) validate-metadata
	$(SELF_MAKE) push-listing
	$(SELF_MAKE) push-pricing

# Play Store - listing
preflight-play-store:
	@echo "Checking Google Play Fastlane configuration..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) preflight

preflight-play-store-listing:
	@echo "Checking generated Google Play listing inputs..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) preflight metadata:true screenshots:true skip_sync:true

sync-play-listing:
	@echo "Generating Google Play listing files..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) sync_listing

validate-play-listing:
	@echo "Validating Google Play listing..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) validate_listing skip_sync:true

download-play-metadata:
	@echo "Downloading current Google Play metadata snapshot..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) download_metadata

push-play-metadata:
	@echo "Uploading Google Play metadata and changelogs..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) upload_metadata skip_sync:true

push-play-metadata-only:
	@echo "Uploading Google Play metadata without changelogs..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) upload_metadata_only skip_sync:true

push-play-screenshots:
	@echo "Uploading Google Play screenshots..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) upload_screenshots skip_sync:true

push-play-listing:
	@echo "Uploading Google Play metadata, changelogs, and screenshots..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) upload_listing skip_sync:true

# Play Store - commerce
# Google Play has no price-tier push target here. Commerce sync manages
# subscriptions and one-time products; delete this block if unused.
push-play-commerce:
	@echo "Syncing Google Play subscriptions and one-time products..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) sync_commerce config:fastlane/commerce/google_play.json

push-play-commerce-dry-run:
	@echo "Dry run for Google Play subscriptions and one-time products..."
	@$(SELF_MAKE) fastlane-setup
	$(FASTLANE_ANDROID) sync_commerce config:fastlane/commerce/google_play.json dry_run:true

# Play Store - workflows
push-play-store-fastlane:
	$(SELF_MAKE) preflight-play-store-listing
	$(SELF_MAKE) validate-play-listing
	$(SELF_MAKE) push-play-listing

# Store workflows
push-fastlane:
	@echo "Uploading Fastlane-managed store content for iOS and Android..."
	$(SELF_MAKE) push-app-store-fastlane
	$(SELF_MAKE) push-play-store-fastlane
