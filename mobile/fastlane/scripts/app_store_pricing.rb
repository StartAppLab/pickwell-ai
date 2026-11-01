#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "csv"
require "date"
require "json"
require "securerandom"
require "uri"
require_relative "../lib/app_store_connect_client"
require_relative "../lib/fastlane_env"

class PricingError < StandardError; end

FastlaneEnv.load!

class PricingConfig
  attr_reader :bundle_id, :base_territory, :base_customer_price, :start_date, :manual_prices

  def self.load(path, default_bundle_id:)
    ext = File.extname(path).downcase
    case ext
    when ".json" then load_json(path, default_bundle_id: default_bundle_id)
    when ".csv" then load_csv(path, default_bundle_id: default_bundle_id)
    else
      raise PricingError, "Unsupported pricing config format: #{ext}. Use .json or .csv"
    end
  end

  def self.load_json(path, default_bundle_id:)
    data = JSON.parse(File.read(path))
    new(
      bundle_id: (data["bundle_id"] || default_bundle_id),
      base_territory: data.fetch("base_territory"),
      base_customer_price: data.fetch("base_customer_price"),
      start_date: data["start_date"],
      manual_prices: data.fetch("manual_prices", {})
    )
  rescue JSON::ParserError => e
    raise PricingError, "Invalid JSON pricing config: #{e.message}"
  rescue KeyError => e
    raise PricingError, "Missing JSON pricing key: #{e.message}"
  end

  def self.load_csv(path, default_bundle_id:)
    rows = CSV.read(path, headers: true)
    raise PricingError, "CSV pricing config is empty" if rows.empty?

    expected_headers = %w[territory customer_price is_base start_date bundle_id]
    unless (expected_headers - rows.headers.compact).empty?
      missing = expected_headers - rows.headers.compact
      raise PricingError, "CSV pricing config is missing headers: #{missing.join(', ')}"
    end

    base_row = rows.find { |row| truthy?(row["is_base"]) }
    raise PricingError, "CSV pricing config must mark exactly one row with is_base=true" unless base_row
    raise PricingError, "CSV pricing config must mark only one row with is_base=true" if rows.count { |row| truthy?(row["is_base"]) } > 1

    start_dates = rows.map { |row| clean_optional(row["start_date"]) }.compact.uniq
    raise PricingError, "CSV pricing config can only contain one distinct start_date value" if start_dates.size > 1

    bundle_ids = rows.map { |row| clean_optional(row["bundle_id"]) }.compact.uniq
    raise PricingError, "CSV pricing config can only contain one distinct bundle_id value" if bundle_ids.size > 1

    manual_prices = {}
    rows.each do |row|
      territory = normalize_territory(row["territory"])
      manual_prices[territory] = normalize_price_string(row["customer_price"])
    end

    base_territory = normalize_territory(base_row["territory"])

    new(
      bundle_id: (bundle_ids.first || default_bundle_id),
      base_territory: base_territory,
      base_customer_price: normalize_price_string(base_row["customer_price"]),
      start_date: start_dates.first,
      manual_prices: manual_prices.reject { |territory, _| territory == base_territory }
    )
  end

  def self.truthy?(value)
    value.to_s.strip.downcase == "true"
  end

  def self.clean_optional(value)
    cleaned = value.to_s.strip
    cleaned.empty? ? nil : cleaned
  end

  def self.normalize_territory(value)
    territory = value.to_s.strip.upcase
    raise PricingError, "Territory code is missing" if territory.empty?

    territory
  end

  def self.normalize_price_string(value)
    number = BigDecimal(value.to_s)
    number.to_s("F")
  rescue ArgumentError
    raise PricingError, "Invalid price value: #{value.inspect}"
  end

  private_class_method :truthy?, :clean_optional, :normalize_territory, :normalize_price_string

  def initialize(bundle_id:, base_territory:, base_customer_price:, start_date:, manual_prices:)
    @bundle_id = bundle_id.to_s.strip
    @base_territory = self.class.send(:normalize_territory, base_territory)
    @base_customer_price = self.class.send(:normalize_price_string, base_customer_price)
    @start_date = normalize_start_date(start_date)

    normalized_manual_prices = {}
    manual_prices.each do |territory, price|
      normalized_manual_prices[self.class.send(:normalize_territory, territory)] = self.class.send(:normalize_price_string, price)
    end
    @manual_prices = normalized_manual_prices

    raise PricingError, "bundle_id is missing and could not be inferred" if @bundle_id.empty?
  end

  def all_prices
    { @base_territory => @base_customer_price }.merge(@manual_prices)
  end

  def price_targets
    all_prices.map do |territory, customer_price|
      {
        territory: territory,
        customer_price: customer_price,
        base: territory == @base_territory
      }
    end
  end

  def normalize_start_date(value)
    cleaned = value.to_s.strip
    return Date.today.iso8601 if cleaned.empty?

    Date.iso8601(cleaned).iso8601
  rescue Date::Error
    raise PricingError, "start_date must be YYYY-MM-DD"
  end

  public :all_prices, :price_targets
end

class PricingApplier
  def initialize(config:, dry_run:)
    @config = config
    @dry_run = dry_run
    @client = AppStoreConnectClient.new(error_class: PricingError)
  end

  def run
    app_id = fetch_app_id
    puts "Resolved App Store app id #{app_id} for #{@config.bundle_id}"
    puts "Preparing #{@config.price_targets.size} territory price entries with start date #{@config.start_date}"

    included = @config.price_targets.each_with_index.map do |target, index|
      price_point = fetch_price_point(app_id, target[:territory], target[:customer_price])
      puts "Matched #{target[:territory]} => #{target[:customer_price]} using appPricePoint #{price_point.fetch('id')}"

      {
        "id" => "${price-#{index}-#{SecureRandom.hex(4)}}",
        "type" => "appPrices",
        "attributes" => {
          "startDate" => @config.start_date,
          "endDate" => nil
        },
        "relationships" => {
          "appPricePoint" => {
            "data" => {
              "type" => "appPricePoints",
              "id" => price_point.fetch("id")
            }
          }
        }
      }
    end

    payload = {
      "data" => {
        "type" => "appPriceSchedules",
        "relationships" => {
          "app" => {
            "data" => {
              "type" => "apps",
              "id" => app_id
            }
          },
          "baseTerritory" => {
            "data" => {
              "type" => "territories",
              "id" => @config.base_territory
            }
          },
          "manualPrices" => {
            "data" => included.map { |entry| { "type" => "appPrices", "id" => entry.fetch("id") } }
          }
        }
      },
      "included" => included
    }

    if ENV["APP_STORE_PRICING_VERBOSE_PAYLOAD"].to_s == "true"
      puts JSON.pretty_generate(payload)
    else
      puts "Prepared payload for #{included.size} appPrices entries"
    end

    if @dry_run
      puts "Dry run only. No price schedule was sent to App Store Connect."
      return
    end

    puts "Submitting price schedule to App Store Connect..."
    response = @client.post_json("/v1/appPriceSchedules", body: payload)
    puts "Created App Store price schedule #{response.dig('data', 'id')}"
  end

  private

  def fetch_app_id
    response = @client.get_json("/v1/apps", query: { "filter[bundleId]" => @config.bundle_id, "limit" => 2 })
    data = response.fetch("data")
    raise PricingError, "No App Store app found for bundle id #{@config.bundle_id}" if data.empty?
    raise PricingError, "Multiple App Store apps found for bundle id #{@config.bundle_id}" if data.size > 1

    data.first.fetch("id")
  end

  def fetch_price_point(app_id, territory, desired_price)
    next_path = "/v1/apps/#{app_id}/appPricePoints"
    query = { "filter[territory]" => territory, "limit" => 200 }

    while next_path
      response = @client.get_json(next_path, query: query)
      query = nil

      match = response.fetch("data").find do |point|
        prices_equal?(point.dig("attributes", "customerPrice"), desired_price)
      end
      return match if match

      next_url = response.dig("links", "next")
      next_path = next_url ? URI(next_url).request_uri : nil
    end

    raise PricingError, "No app price point found for territory #{territory} at price #{desired_price}"
  end

  def prices_equal?(left, right)
    BigDecimal(left.to_s) == BigDecimal(right.to_s)
  end
end

def usage
  <<~TEXT
    Usage:
      ruby fastlane/scripts/app_store_pricing.rb fastlane/pricing/prices.json [--dry-run]
      ruby fastlane/scripts/app_store_pricing.rb fastlane/pricing/prices.csv [--dry-run]

    Required environment variables:
      APP_STORE_CONNECT_KEY_ID
      APP_STORE_CONNECT_ISSUER_ID
      APP_STORE_CONNECT_KEY_CONTENT
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

  config = PricingConfig.load(path, default_bundle_id: default_bundle_id)
  if !default_bundle_id.empty? && config.bundle_id != default_bundle_id
    raise PricingError, "Pricing config bundle_id #{config.bundle_id} does not match APP_STORE_BUNDLE_ID #{default_bundle_id}"
  end

  PricingApplier.new(config: config, dry_run: dry_run).run
end
