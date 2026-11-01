#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "date"
require "json"
require "securerandom"
require "uri"
require_relative "../lib/app_store_connect_client"
require_relative "../lib/fastlane_env"

class AppStoreCommerceError < StandardError; end

FastlaneEnv.load!

class AppStoreCommerceConfig
  attr_reader :bundle_id, :in_app_purchases, :subscriptions

  def self.load(path, default_bundle_id:)
    data = JSON.parse(File.read(path))
    new(
      bundle_id: data["bundle_id"] || default_bundle_id,
      in_app_purchases: data.fetch("in_app_purchases", []),
      subscriptions: data.fetch("subscriptions", [])
    )
  rescue JSON::ParserError => e
    raise AppStoreCommerceError, "Invalid App Store commerce JSON: #{e.message}"
  end

  def initialize(bundle_id:, in_app_purchases:, subscriptions:)
    @bundle_id = bundle_id.to_s.strip
    raise AppStoreCommerceError, "bundle_id is missing and could not be inferred" if @bundle_id.empty?

    @in_app_purchases = normalize_products(in_app_purchases, kind: :in_app_purchase)
    @subscriptions = normalize_products(subscriptions, kind: :subscription)
  end

  private

  def normalize_products(items, kind:)
    unless items.is_a?(Array)
      raise AppStoreCommerceError, "#{kind} entries must be an array"
    end

    items.map do |item|
      raise AppStoreCommerceError, "#{kind} entry must be an object" unless item.is_a?(Hash)

      product_id = item.fetch("product_id").to_s.strip
      raise AppStoreCommerceError, "#{kind} product_id is missing" if product_id.empty?

      pricing = item["pricing"]
      if pricing
        raise AppStoreCommerceError, "#{product_id} pricing must be an object" unless pricing.is_a?(Hash)

        pricing = {
          "base_territory" => normalize_territory(pricing.fetch("base_territory")),
          "base_customer_price" => normalize_decimal(pricing.fetch("base_customer_price")),
          "start_date" => normalize_date(pricing["start_date"]),
          "manual_prices" => normalize_price_map(pricing.fetch("manual_prices", {}))
        }
      end

      item.merge(
        "product_id" => product_id,
        "pricing" => pricing
      )
    end
  end

  def normalize_price_map(map)
    raise AppStoreCommerceError, "manual_prices must be an object" unless map.is_a?(Hash)

    map.each_with_object({}) do |(territory, price), out|
      out[normalize_territory(territory)] = normalize_decimal(price)
    end
  end

  def normalize_territory(value)
    code = value.to_s.strip.upcase
    raise AppStoreCommerceError, "Territory code is missing" if code.empty?
    raise AppStoreCommerceError, "App Store territory codes must be ISO-3166 alpha-3 ids like USA or PHL" unless code.match?(/\A[A-Z]{3}\z/)

    code
  end

  def normalize_decimal(value)
    BigDecimal(value.to_s).to_s("F")
  rescue ArgumentError
    raise AppStoreCommerceError, "Invalid price value: #{value.inspect}"
  end

  def normalize_date(value)
    cleaned = value.to_s.strip
    return Date.today.iso8601 if cleaned.empty?

    Date.iso8601(cleaned).iso8601
  rescue Date::Error
    raise AppStoreCommerceError, "start_date must be YYYY-MM-DD"
  end
end

class AppStoreCommerceSync
  def initialize(config:, dry_run:)
    @config = config
    @dry_run = dry_run
    @client = AppStoreConnectClient.new(error_class: AppStoreCommerceError)
  end

  def run
    app_id = fetch_app_id
    puts "Resolved App Store app id #{app_id} for #{@config.bundle_id}"

    @config.in_app_purchases.each do |item|
      sync_in_app_purchase(app_id, item)
    end

    @config.subscriptions.each do |item|
      sync_subscription(item)
    end
  end

  private

  def sync_in_app_purchase(app_id, item)
    purchase_id = item["id"] || fetch_in_app_purchase_id(app_id, item["product_id"])
    if purchase_id.nil?
      purchase_id = create_in_app_purchase(app_id, item)
    else
      puts "Using existing App Store in-app purchase #{item['product_id']} (#{purchase_id})"
    end

    apply_iap_pricing(purchase_id, item["pricing"]) if purchase_id && item["pricing"]
    warn_unsupported(item, prefix: "in_app_purchases/#{item['product_id']}")
  end

  def sync_subscription(item)
    subscription_id = item["id"]
    if subscription_id.nil?
      subscription_id = create_subscription(item)
    else
      puts "Using existing App Store subscription #{item['product_id']} (#{subscription_id})"
    end

    apply_subscription_pricing(subscription_id, item["pricing"]) if subscription_id && item["pricing"]
    warn_unsupported(item, prefix: "subscriptions/#{item['product_id']}")
  end

  def fetch_app_id
    response = @client.get_json("/v1/apps", query: { "filter[bundleId]" => @config.bundle_id, "limit" => 2 })
    data = response.fetch("data")
    raise AppStoreCommerceError, "No App Store app found for bundle id #{@config.bundle_id}" if data.empty?
    raise AppStoreCommerceError, "Multiple App Store apps found for bundle id #{@config.bundle_id}" if data.size > 1

    data.first.fetch("id")
  end

  def fetch_in_app_purchase_id(app_id, product_id)
    next_path = "/v1/apps/#{app_id}/inAppPurchasesV2"
    query = { "limit" => 200 }

    while next_path
      response = @client.get_json(next_path, query: query)
      query = nil
      match = response.fetch("data").find { |item| item.dig("attributes", "productId") == product_id }
      return match.fetch("id") if match

      next_url = response.dig("links", "next")
      next_path = next_url ? URI(next_url).request_uri : nil
    end

    nil
  end

  def create_in_app_purchase(app_id, item)
    name = item.fetch("name", item["product_id"])
    purchase_type = item.fetch("in_app_purchase_type")
    payload = {
      "data" => {
        "type" => "inAppPurchases",
        "attributes" => {
          "name" => name,
          "productId" => item["product_id"],
          "inAppPurchaseType" => purchase_type,
          "familySharable" => item["family_sharable"],
          "reviewNote" => item["review_note"]
        }.compact,
        "relationships" => {
          "app" => {
            "data" => {
              "type" => "apps",
              "id" => app_id
            }
          }
        }
      }
    }

    if @dry_run
      puts "Dry run: would create App Store in-app purchase #{item['product_id']}"
      puts JSON.pretty_generate(payload)
      return item["id"] || "dry-run-#{item['product_id']}"
    end

    response = @client.post_json("/v2/inAppPurchases", body: payload)
    created_id = response.dig("data", "id")
    puts "Created App Store in-app purchase #{item['product_id']} (#{created_id})"
    created_id
  end

  def create_subscription(item)
    group_id = item.fetch("subscription_group_id")
    payload = {
      "data" => {
        "type" => "subscriptions",
        "attributes" => {
          "name" => item.fetch("name", item["product_id"]),
          "productId" => item["product_id"],
          "reviewNote" => item["review_note"],
          "familySharable" => item["family_sharable"],
          "subscriptionPeriod" => item["subscription_period"],
          "groupLevel" => item["group_level"]
        }.compact,
        "relationships" => {
          "group" => {
            "data" => {
              "type" => "subscriptionGroups",
              "id" => group_id
            }
          }
        }
      }
    }

    if @dry_run
      puts "Dry run: would create App Store subscription #{item['product_id']}"
      puts JSON.pretty_generate(payload)
      return item["id"] || "dry-run-#{item['product_id']}"
    end

    response = @client.post_json("/v1/subscriptions", body: payload)
    created_id = response.dig("data", "id")
    puts "Created App Store subscription #{item['product_id']} (#{created_id})"
    created_id
  end

  def apply_iap_pricing(purchase_id, pricing)
    targets = { pricing["base_territory"] => pricing["base_customer_price"] }.merge(pricing["manual_prices"])
    included = targets.each_with_index.map do |(territory, customer_price), index|
      price_point = fetch_iap_price_point(purchase_id, territory, customer_price)
      puts "Matched App Store IAP #{territory} => #{customer_price} using price point #{price_point.fetch('id')}"

      {
        "id" => "${in-app-price-#{index}-#{SecureRandom.hex(4)}}",
        "type" => "inAppPurchasePrices",
        "attributes" => {
          "startDate" => pricing["start_date"],
          "preserveCurrentPrice" => false
        },
        "relationships" => {
          "inAppPurchasePricePoint" => {
            "data" => {
              "type" => "inAppPurchasePricePoints",
              "id" => price_point.fetch("id")
            }
          }
        }
      }
    end

    payload = {
      "data" => {
        "type" => "inAppPurchasePriceSchedules",
        "relationships" => {
          "baseTerritory" => {
            "data" => {
              "type" => "territories",
              "id" => pricing["base_territory"]
            }
          },
          "inAppPurchase" => {
            "data" => {
              "type" => "inAppPurchases",
              "id" => purchase_id
            }
          },
          "manualPrices" => {
            "data" => included.map { |entry| { "type" => "inAppPurchasePrices", "id" => entry.fetch("id") } }
          }
        }
      },
      "included" => included
    }

    if @dry_run
      puts "Dry run: would submit App Store IAP pricing schedule for #{purchase_id}"
      puts JSON.pretty_generate(payload)
      return
    end

    response = @client.post_json("/v1/inAppPurchasePriceSchedules", body: payload)
    puts "Created App Store IAP price schedule #{response.dig('data', 'id')} for #{purchase_id}"
  end

  def apply_subscription_pricing(subscription_id, pricing)
    targets = { pricing["base_territory"] => pricing["base_customer_price"] }.merge(pricing["manual_prices"])

    targets.each do |territory, customer_price|
      price_point = fetch_subscription_price_point(subscription_id, territory, customer_price)
      payload = {
        "data" => {
          "type" => "subscriptionPrices",
          "attributes" => {
            "startDate" => pricing["start_date"],
            "preserveCurrentPrice" => false
          },
          "relationships" => {
            "subscription" => {
              "data" => {
                "type" => "subscriptions",
                "id" => subscription_id
              }
            },
            "subscriptionPricePoint" => {
              "data" => {
                "type" => "subscriptionPricePoints",
                "id" => price_point.fetch("id")
              }
            },
            "territory" => {
              "data" => {
                "type" => "territories",
                "id" => territory
              }
            }
          }
        }
      }

      if @dry_run
        puts "Dry run: would create App Store subscription price change for #{subscription_id} #{territory}"
        puts JSON.pretty_generate(payload)
      else
        @client.post_json("/v1/subscriptionPrices", body: payload)
        puts "Created App Store subscription price change for #{subscription_id} #{territory}"
      end
    end
  end

  def fetch_iap_price_point(purchase_id, territory, desired_price)
    fetch_matching_price_point("/v2/inAppPurchases/#{purchase_id}/pricePoints", territory, desired_price)
  end

  def fetch_subscription_price_point(subscription_id, territory, desired_price)
    fetch_matching_price_point("/v1/subscriptions/#{subscription_id}/pricePoints", territory, desired_price)
  end

  def fetch_matching_price_point(path, territory, desired_price)
    next_path = path
    query = { "filter[territory]" => territory, "limit" => 200 }

    while next_path
      response = @client.get_json(next_path, query: query)
      query = nil
      match = response.fetch("data").find do |point|
        BigDecimal(point.dig("attributes", "customerPrice").to_s) == BigDecimal(desired_price)
      end
      return match if match

      next_url = response.dig("links", "next")
      next_path = next_url ? URI(next_url).request_uri : nil
    end

    raise AppStoreCommerceError, "No App Store price point found for #{territory} at #{desired_price}"
  end

  def warn_unsupported(item, prefix:)
    unsupported = %w[localizations availability introductory_offer promotional_offers offer_codes review_submission]
    present = unsupported.select { |key| item.key?(key) }
    return if present.empty?

    warn "Skipping unsupported App Store keys for #{prefix}: #{present.join(', ')}"
  end
end

def usage
  <<~TEXT
    Usage:
      ruby fastlane/scripts/app_store_commerce.rb fastlane/commerce/app_store.json [--dry-run]

    Supported in this first pass:
      - Create subscriptions and in-app purchases
      - Apply country-specific App Store prices for subscriptions and in-app purchases

    Current limitations:
      - Localizations, availability, offers, and review submission are validated only as config placeholders
      - Existing subscriptions should provide an explicit `id`
  TEXT
end

if __FILE__ == $PROGRAM_NAME
  path = ARGV.find { |arg| !arg.start_with?("--") }
  dry_run = ARGV.include?("--dry-run")

  unless path
    warn usage
    exit 1
  end

  default_bundle_id = ENV.fetch("APP_STORE_BUNDLE_ID", "").strip
  config = AppStoreCommerceConfig.load(path, default_bundle_id: default_bundle_id)
  if !default_bundle_id.empty? && config.bundle_id != default_bundle_id
    raise AppStoreCommerceError, "Commerce config bundle_id #{config.bundle_id} does not match APP_STORE_BUNDLE_ID #{default_bundle_id}"
  end

  AppStoreCommerceSync.new(config: config, dry_run: dry_run).run
end
