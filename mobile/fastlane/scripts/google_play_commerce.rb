#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "bigdecimal"
require "json"
require "net/http"
require "openssl"
require "uri"
require_relative "../lib/fastlane_env"

class GooglePlayCommerceError < StandardError; end

FastlaneEnv.load!

class GoogleServiceAccountToken
  TOKEN_URI = URI("https://oauth2.googleapis.com/token")
  SCOPE = "https://www.googleapis.com/auth/androidpublisher"

  def initialize
    json = load_json_key
    @client_email = json.fetch("client_email")
    @private_key = json.fetch("private_key")
  end

  def fetch
    now = Time.now.to_i
    payload = {
      iss: @client_email,
      scope: SCOPE,
      aud: TOKEN_URI.to_s,
      iat: now,
      exp: now + 3600
    }

    assertion = sign_jwt(payload)
    request = Net::HTTP::Post.new(TOKEN_URI)
    request.set_form_data(
      "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
      "assertion" => assertion
    )

    response = Net::HTTP.start(TOKEN_URI.host, TOKEN_URI.port, use_ssl: true) { |http| http.request(request) }
    parsed = JSON.parse(response.body.to_s)
    return parsed.fetch("access_token") if response.is_a?(Net::HTTPSuccess)

    raise GooglePlayCommerceError, "Google OAuth error: #{parsed}"
  rescue JSON::ParserError => e
    raise GooglePlayCommerceError, "Failed to parse Google OAuth response: #{e.message}"
  end

  private

  def load_json_key
    raw = ENV["PLAY_STORE_JSON_KEY_DATA"].to_s.strip
    if raw.empty?
      path = ENV["PLAY_STORE_JSON_KEY_PATH"].to_s.strip
      raise GooglePlayCommerceError, "Set PLAY_STORE_JSON_KEY_PATH or PLAY_STORE_JSON_KEY_DATA" if path.empty?

      expanded = File.expand_path(path, FastlaneEnv.project_root)
      raise GooglePlayCommerceError, "Play Store JSON key not found: #{expanded}" unless File.file?(expanded)

      raw = File.read(expanded)
    end

    json = raw.start_with?("{") ? raw : Base64.strict_decode64(raw)
    parsed = JSON.parse(json)
    %w[client_email private_key].each do |key|
      raise GooglePlayCommerceError, "Play Store credentials JSON missing #{key}" if parsed[key].to_s.strip.empty?
    end
    parsed
  rescue ArgumentError => e
    raise GooglePlayCommerceError, "PLAY_STORE_JSON_KEY_DATA must contain raw JSON or base64 JSON: #{e.message}"
  rescue JSON::ParserError
    raise GooglePlayCommerceError, "Invalid Play Store credentials JSON"
  end

  def sign_jwt(payload)
    header = { alg: "RS256", typ: "JWT" }
    signing_input = [header, payload].map { |part| Base64.urlsafe_encode64(JSON.generate(part), padding: false) }.join(".")
    key = OpenSSL::PKey::RSA.new(@private_key)
    signature = key.sign(OpenSSL::Digest::SHA256.new, signing_input)
    "#{signing_input}.#{Base64.urlsafe_encode64(signature, padding: false)}"
  end
end

class GooglePlayClient
  API_BASE = "https://androidpublisher.googleapis.com/androidpublisher/v3".freeze

  def initialize
    @token = GoogleServiceAccountToken.new.fetch
  end

  def get_json(path, query: nil)
    request_json(Net::HTTP::Get.new(build_uri(path, query)))
  end

  def patch_json(path, body:, query: nil)
    request = Net::HTTP::Patch.new(build_uri(path, query))
    request["Content-Type"] = "application/json"
    request.body = JSON.pretty_generate(body)
    request_json(request)
  end

  def post_json(path, body:, query: nil)
    request = Net::HTTP::Post.new(build_uri(path, query))
    request["Content-Type"] = "application/json"
    request.body = JSON.pretty_generate(body)
    request_json(request)
  end

  private

  def build_uri(path, query = nil)
    uri = URI("#{API_BASE}#{path}")
    uri.query = URI.encode_www_form(flatten_query(query)) if query && !query.empty?
    uri
  end

  def flatten_query(query, prefix = nil, out = [])
    query.each do |key, value|
      name = prefix ? "#{prefix}.#{key}" : key.to_s
      if value.is_a?(Hash)
        flatten_query(value, name, out)
      else
        out << [name, value]
      end
    end
    out
  end

  def request_json(request)
    request["Authorization"] = "Bearer #{@token}"

    response = Net::HTTP.start(request.uri.host, request.uri.port, use_ssl: true) { |http| http.request(request) }
    body = response.body.to_s
    parsed = body.empty? ? {} : JSON.parse(body)
    return parsed if response.is_a?(Net::HTTPSuccess)

    message = parsed["error"].is_a?(Hash) ? parsed["error"]["message"] : body
    raise GooglePlayCommerceError, "Google Play API error: #{message}"
  rescue JSON::ParserError => e
    raise GooglePlayCommerceError, "Failed to parse Google Play response: #{e.message}"
  end
end

class GooglePlayCommerceConfig
  attr_reader :package_name, :regions_version, :one_time_products, :subscriptions

  def self.load(path, default_package_name:)
    data = JSON.parse(File.read(path))
    new(
      package_name: data["package_name"] || default_package_name,
      regions_version: data.fetch("regions_version"),
      one_time_products: data.fetch("one_time_products", []),
      subscriptions: data.fetch("subscriptions", [])
    )
  rescue JSON::ParserError => e
    raise GooglePlayCommerceError, "Invalid Google Play commerce JSON: #{e.message}"
  end

  def initialize(package_name:, regions_version:, one_time_products:, subscriptions:)
    @package_name = package_name.to_s.strip
    raise GooglePlayCommerceError, "package_name is missing and could not be inferred" if @package_name.empty?

    @regions_version = regions_version.to_s.strip
    raise GooglePlayCommerceError, "regions_version is required" if @regions_version.empty?

    @one_time_products = normalize_one_time_products(one_time_products)
    @subscriptions = normalize_subscriptions(subscriptions)
  end

  private

  def normalize_one_time_products(items)
    raise GooglePlayCommerceError, "one_time_products must be an array" unless items.is_a?(Array)

    items.map do |item|
      product_id = item.fetch("product_id").to_s.strip
      raise GooglePlayCommerceError, "one_time product_id is missing" if product_id.empty?

      item.merge(
        "product_id" => product_id,
        "listings" => normalize_listings(item.fetch("listings")),
        "purchase_options" => normalize_purchase_options(item.fetch("purchase_options"))
      )
    end
  end

  def normalize_subscriptions(items)
    raise GooglePlayCommerceError, "subscriptions must be an array" unless items.is_a?(Array)

    items.map do |item|
      product_id = item.fetch("product_id").to_s.strip
      raise GooglePlayCommerceError, "subscription product_id is missing" if product_id.empty?

      item.merge(
        "product_id" => product_id,
        "listings" => normalize_subscription_listings(item.fetch("listings")),
        "base_plans" => normalize_base_plans(item.fetch("base_plans"))
      )
    end
  end

  def normalize_listings(items)
    raise GooglePlayCommerceError, "listings must be an array" unless items.is_a?(Array)
    items.map do |item|
      {
        "languageCode" => item.fetch("language_code"),
        "title" => item.fetch("title"),
        "description" => item.fetch("description")
      }
    end
  end

  def normalize_subscription_listings(items)
    raise GooglePlayCommerceError, "listings must be an array" unless items.is_a?(Array)
    items.map do |item|
      {
        "languageCode" => item.fetch("language_code"),
        "title" => item.fetch("title"),
        "description" => item["description"],
        "benefits" => item.fetch("benefits", [])
      }.compact
    end
  end

  def normalize_purchase_options(items)
    raise GooglePlayCommerceError, "purchase_options must be an array" unless items.is_a?(Array)
    items.map do |item|
      pricing = normalize_region_pricing(item.fetch("pricing"), availability: :one_time_product)
      option = {
        "purchaseOptionId" => item.fetch("purchase_option_id"),
        "regionalPricingAndAvailabilityConfigs" => pricing.fetch("regional_configs")
      }
      option["newRegionsConfig"] = pricing["other_regions_config"] if pricing["other_regions_config"]
      if item["purchase_type"] == "rent"
        option["rentOption"] = {
          "rentalPeriod" => item.fetch("rental_period_duration"),
          "expirationPeriod" => item["expiration_period_duration"]
        }
      else
        option["buyOption"] = item.fetch("buy_option", {})
      end
      option["offers"] = normalize_one_time_product_offers(item.fetch("offers", []))
      option["activate"] = item["activate"] != false
      option["_pricing"] = pricing
      option
    end
  end

  def normalize_one_time_product_offers(items)
    raise GooglePlayCommerceError, "offers must be an array" unless items.is_a?(Array)

    items.map do |item|
      {
        "offerId" => item.fetch("offer_id"),
        "regionalPricingAndAvailabilityConfigs" => item.fetch("regional_configs"),
        "discountedOffer" => item.fetch("discounted_offer", {}),
        "offerTags" => item["offer_tags"],
        "activate" => item["activate"] == true,
        "_all_regions" => item["all_regions"] == true,
        "_all_regions_config" => normalize_one_time_offer_all_regions_config(item)
      }.compact
    end
  end

  def normalize_base_plans(items)
    raise GooglePlayCommerceError, "base_plans must be an array" unless items.is_a?(Array)
    items.map do |item|
      pricing = normalize_region_pricing(item.fetch("pricing"), availability: :subscription)
      base_plan = {
        "basePlanId" => item.fetch("base_plan_id"),
        "regionalConfigs" => pricing.fetch("regional_configs")
      }
      base_plan["otherRegionsConfig"] = pricing["other_regions_config"] if pricing["other_regions_config"]

      case item.fetch("plan_type")
      when "auto_renewing"
        base_plan["autoRenewingBasePlanType"] = {
          "billingPeriodDuration" => item.fetch("billing_period_duration"),
          "gracePeriodDuration" => item["grace_period_duration"],
          "accountHoldDuration" => item["account_hold_duration"],
          "resubscribeState" => item["resubscribe_state"],
          "prorationMode" => item["proration_mode"]
        }.compact
      when "prepaid"
        base_plan["prepaidBasePlanType"] = {
          "billingPeriodDuration" => item.fetch("billing_period_duration"),
          "timeExtension" => item["time_extension"]
        }.compact
      else
        raise GooglePlayCommerceError, "Unsupported plan_type #{item['plan_type'].inspect}"
      end

      base_plan["offers"] = normalize_subscription_offers(item.fetch("offers", []))
      base_plan["activate"] = item["activate"] != false
      base_plan["price_migrations"] = item.fetch("price_migrations", [])
      base_plan["_pricing"] = pricing
      base_plan
    end
  end

  def normalize_subscription_offers(items)
    raise GooglePlayCommerceError, "offers must be an array" unless items.is_a?(Array)
    items.map do |item|
      {
        "offerId" => item.fetch("offer_id"),
        "phases" => normalize_subscription_offer_phases(item.fetch("phases")),
        "regionalConfigs" => item.fetch("regional_configs"),
        "activate" => item["activate"] == true,
        "targeting" => item["targeting"],
        "offerTags" => item["offer_tags"],
        "otherRegionsConfig" => item["other_regions_config"],
        "_all_regions" => item["all_regions"] == true
      }.compact
    end
  end

  def normalize_subscription_offer_phases(items)
    raise GooglePlayCommerceError, "offer phases must be an array" unless items.is_a?(Array)

    items.map do |item|
      if item["pricing"]
        pricing = normalize_region_pricing(item.fetch("pricing"), availability: :price_only)
        {
          "duration" => item.fetch("duration"),
          "recurrenceCount" => item.fetch("recurrenceCount"),
          "regionalConfigs" => pricing.fetch("regional_configs"),
          "otherRegionsConfig" => item["other_regions_config"],
          "_pricing" => pricing
        }.compact
      else
        item
      end
    end
  end

  def normalize_one_time_offer_all_regions_config(item)
    return nil unless item["all_regions"] == true

    if item.key?("relative_discount")
      { "relativeDiscount" => item.fetch("relative_discount") }
    elsif item.key?("absolute_discount")
      {
        "absoluteDiscount" => {},
        "_absolute_discount_pricing" => normalize_region_pricing(item.fetch("absolute_discount"), availability: :price_only)
      }
    elsif item.key?("no_override")
      { "noOverride" => item.fetch("no_override") }
    else
      raise GooglePlayCommerceError, "one-time product offers with all_regions require relative_discount, absolute_discount, or no_override"
    end
  end

  def normalize_region_pricing(pricing, availability:)
    raise GooglePlayCommerceError, "pricing must be an object" unless pricing.is_a?(Hash)

    base_currency = pricing.fetch("base_currency").to_s.strip.upcase
    base_price = normalize_decimal(pricing.fetch("base_price"))
    manual_prices = pricing.fetch("manual_prices", {})
    raise GooglePlayCommerceError, "manual_prices must be an object" unless manual_prices.is_a?(Hash)

    regional_configs = manual_prices.map do |region, amount|
      config = {
        "regionCode" => normalize_region(region),
        "_amount" => normalize_decimal(amount)
      }
      if availability == :one_time_product
        config["availability"] = "AVAILABLE"
      elsif availability == :subscription
        config["newSubscriberAvailability"] = true
      end
      config
    end

    {
      "base_currency" => base_currency,
      "base_price" => base_price,
      "regional_configs" => regional_configs,
      "all_regions" => pricing["all_regions"] == true,
      "other_regions_config" => pricing["other_regions"]&.transform_keys(&:to_s)
    }
  end

  def normalize_region(value)
    code = value.to_s.strip.upcase
    raise GooglePlayCommerceError, "Region code is missing" if code.empty?
    raise GooglePlayCommerceError, "Google Play region codes must be ISO-3166 alpha-2 ids like US or PH" unless code.match?(/\A[A-Z]{2}\z/)
    code
  end

  def normalize_decimal(value)
    BigDecimal(value.to_s).to_s("F")
  rescue ArgumentError
    raise GooglePlayCommerceError, "Invalid price value: #{value.inspect}"
  end
end

class GooglePlayCommerceSync
  def initialize(config:, dry_run:)
    @config = config
    @dry_run = dry_run
    @client = GooglePlayClient.new
    @currency_cache = {}
  end

  def run
    puts "Preparing Google Play commerce sync for #{@config.package_name}"
    @config.one_time_products.each { |product| sync_one_time_product(product) }
    @config.subscriptions.each { |subscription| sync_subscription(subscription) }
  end

  private

  def sync_one_time_product(product)
    purchase_options = product["purchase_options"].map do |purchase_option|
      purchase_option.reject { |key, _| %w[offers activate].include?(key) }
    end

    payload = {
      "packageName" => @config.package_name,
      "productId" => product["product_id"],
      "listings" => product["listings"],
      "purchaseOptions" => decorate_region_prices(purchase_options),
      "offerTags" => product["offer_tags"],
      "restrictedPaymentCountries" => product["restricted_payment_countries"]
    }.compact

    upsert(
      path: "/applications/#{@config.package_name}/onetimeproducts/#{product['product_id']}",
      payload: payload,
      update_mask: "listings,purchaseOptions,offerTags,restrictedPaymentCountries",
      label: "Google Play one-time product #{product['product_id']}"
    )

    product["purchase_options"].each do |purchase_option|
      activate_one_time_product_purchase_option(product["product_id"], purchase_option["purchaseOptionId"]) if purchase_option["activate"]
    end

    sync_one_time_product_offers(product)
  end

  def sync_one_time_product_offers(product)
    product["purchase_options"].each do |purchase_option|
      offers = purchase_option.fetch("offers", [])
      next if offers.empty?

      offers = offers.map { |offer| expand_one_time_offer_regions(offer, purchase_option) }

      requests = offers.map do |offer|
        {
          "oneTimeProductOffer" => offer.reject { |key, _| key == "activate" || key.start_with?("_") }.merge(
            "packageName" => @config.package_name,
            "productId" => product["product_id"],
            "purchaseOptionId" => purchase_option["purchaseOptionId"]
          ),
          "updateMask" => "regionalPricingAndAvailabilityConfigs,discountedOffer,offerTags",
          "regionsVersion" => { "version" => @config.regions_version },
          "allowMissing" => true,
          "latencyTolerance" => "PRODUCT_UPDATE_LATENCY_TOLERANCE_LATENCY_TOLERANT"
        }
      end

      if @dry_run
        puts "Dry run: would upsert Google Play one-time product offers for #{product['product_id']}/#{purchase_option['purchaseOptionId']}"
        puts JSON.pretty_generate("requests" => requests)
      else
        @client.post_json(
          "/applications/#{@config.package_name}/oneTimeProducts/#{product['product_id']}/purchaseOptions/#{purchase_option['purchaseOptionId']}/offers:batchUpdate",
          body: { "requests" => requests }
        )
        puts "Upserted Google Play one-time product offers for #{product['product_id']}/#{purchase_option['purchaseOptionId']}"
      end

      offers.each do |offer|
        activate_one_time_product_offer(product["product_id"], purchase_option["purchaseOptionId"], offer["offerId"]) if offer["activate"]
      end
    end
  end

  def sync_subscription(subscription)
    base_plans = decorate_region_prices(subscription["base_plans"])
    payload = {
      "packageName" => @config.package_name,
      "productId" => subscription["product_id"],
      "listings" => subscription["listings"],
      "basePlans" => base_plans.map { |base_plan| subscription_payload_base_plan(base_plan) },
      "restrictedPaymentCountries" => subscription["restricted_payment_countries"]
    }.compact

    upsert(
      path: "/applications/#{@config.package_name}/subscriptions/#{subscription['product_id']}",
      payload: payload,
      update_mask: "listings,basePlans,restrictedPaymentCountries",
      label: "Google Play subscription #{subscription['product_id']}"
    )

    base_plans.each do |base_plan|
      activate_base_plan(subscription["product_id"], base_plan["basePlanId"]) if base_plan["activate"]
      migrate_base_plan_prices(subscription["product_id"], base_plan)
      sync_subscription_offers(subscription["product_id"], base_plan)
    end
  end

  def sync_subscription_offers(product_id, base_plan)
    base_plan.fetch("offers", []).each do |offer|
      offer = expand_subscription_offer_regions(offer, base_plan)
      payload = {
        "packageName" => @config.package_name,
        "productId" => product_id,
        "basePlanId" => base_plan["basePlanId"],
        "offerId" => offer["offerId"],
        "phases" => expand_subscription_offer_phase_regions(offer["phases"], offer),
        "regionalConfigs" => offer["regionalConfigs"],
        "targeting" => offer["targeting"],
        "offerTags" => offer["offerTags"],
        "otherRegionsConfig" => offer["otherRegionsConfig"]
      }.compact

      upsert(
        path: "/applications/#{@config.package_name}/subscriptions/#{product_id}/basePlans/#{base_plan['basePlanId']}/offers/#{offer['offerId']}",
        payload: payload.reject { |key, _| key.start_with?("_") },
        update_mask: "phases,regionalConfigs,targeting,offerTags,otherRegionsConfig",
        label: "Google Play subscription offer #{product_id}/#{base_plan['basePlanId']}/#{offer['offerId']}"
      )
      activate_offer(product_id, base_plan["basePlanId"], offer["offerId"]) if offer["activate"]
    end
  end

  def subscription_payload_base_plan(base_plan)
    base_plan.reject { |key, _| %w[offers activate price_migrations _pricing].include?(key) }
  end

  def migrate_base_plan_prices(product_id, base_plan)
    requests = base_plan.fetch("price_migrations", [])
    return if requests.empty?

    payload = {
      "requests" => requests.map do |request|
        {
          "packageName" => @config.package_name,
          "productId" => product_id,
          "basePlanId" => base_plan["basePlanId"],
          "regionalPriceMigrations" => request.fetch("regional_price_migrations"),
          "regionsVersion" => { "version" => @config.regions_version },
          "latencyTolerance" => "PRODUCT_UPDATE_LATENCY_TOLERANCE_LATENCY_TOLERANT"
        }
      end
    }

    if @dry_run
      puts "Dry run: would migrate Google Play subscriber price cohorts for #{product_id}/#{base_plan['basePlanId']}"
      puts JSON.pretty_generate(payload)
      return
    end

    @client.post_json(
      "/applications/#{@config.package_name}/subscriptions/#{product_id}/basePlans:batchMigratePrices",
      body: payload
    )
    puts "Migrated Google Play subscriber price cohorts for #{product_id}/#{base_plan['basePlanId']}"
  end

  def upsert(path:, payload:, update_mask:, label:)
    if @dry_run
      puts "Dry run: would upsert #{label}"
      puts JSON.pretty_generate(payload)
      return
    end

    @client.patch_json(
      path,
      body: payload,
      query: {
        "updateMask" => update_mask,
        "allowMissing" => true,
        "regionsVersion" => { "version" => @config.regions_version }
      }
    )
    puts "Upserted #{label}"
  end

  def activate_base_plan(product_id, base_plan_id)
    if @dry_run
      puts "Dry run: would activate Google Play base plan #{product_id}/#{base_plan_id}"
      return
    end

    @client.post_json(
      "/applications/#{@config.package_name}/subscriptions/#{product_id}/basePlans/#{base_plan_id}:activate",
      body: {}
    )
    puts "Activated Google Play base plan #{product_id}/#{base_plan_id}"
  end

  def activate_offer(product_id, base_plan_id, offer_id)
    if @dry_run
      puts "Dry run: would activate Google Play offer #{product_id}/#{base_plan_id}/#{offer_id}"
      return
    end

    @client.post_json(
      "/applications/#{@config.package_name}/subscriptions/#{product_id}/basePlans/#{base_plan_id}/offers/#{offer_id}:activate",
      body: {}
    )
    puts "Activated Google Play offer #{product_id}/#{base_plan_id}/#{offer_id}"
  end

  def activate_one_time_product_offer(product_id, purchase_option_id, offer_id)
    if @dry_run
      puts "Dry run: would activate Google Play one-time product offer #{product_id}/#{purchase_option_id}/#{offer_id}"
      return
    end

    @client.post_json(
      "/applications/#{@config.package_name}/oneTimeProducts/#{product_id}/purchaseOptions/#{purchase_option_id}/offers/#{offer_id}:activate",
      body: {}
    )
    puts "Activated Google Play one-time product offer #{product_id}/#{purchase_option_id}/#{offer_id}"
  end

  def activate_one_time_product_purchase_option(product_id, purchase_option_id)
    if @dry_run
      puts "Dry run: would activate Google Play one-time product purchase option #{product_id}/#{purchase_option_id}"
      return
    end

    @client.post_json(
      "/applications/#{@config.package_name}/oneTimeProducts/#{product_id}/purchaseOptions:batchUpdateStates",
      body: {
        "requests" => [
          {
            "activatePurchaseOptionRequest" => {
              "packageName" => @config.package_name,
              "productId" => product_id,
              "purchaseOptionId" => purchase_option_id,
              "latencyTolerance" => "PRODUCT_UPDATE_LATENCY_TOLERANCE_LATENCY_TOLERANT"
            }
          }
        ]
      }
    )
    puts "Activated Google Play one-time product purchase option #{product_id}/#{purchase_option_id}"
  end

  def decorate_region_prices(items)
    items.map do |item|
      if item["regionalConfigs"]
        expand_item_regions(item, "regionalConfigs", availability: :subscription)
      elsif item["regionalPricingAndAvailabilityConfigs"]
        expand_item_regions(item, "regionalPricingAndAvailabilityConfigs", availability: :one_time_product)
      else
        item
      end
    end
  end

  def expand_item_regions(item, regional_key, availability:)
    configs = materialize_money(item.fetch(regional_key))
    pricing = item["_pricing"]
    return item.merge(regional_key => configs).reject { |key, _| key == "_pricing" } unless pricing&.fetch("all_regions", false)

    conversion = converted_region_prices(pricing.fetch("base_price"), pricing.fetch("base_currency"))
    converted_configs = conversion.fetch("convertedRegionPrices").values.each_with_object({}) do |converted, by_region|
      config = {
        "regionCode" => converted.fetch("regionCode"),
        "price" => converted.fetch("price")
      }
      if availability == :one_time_product
        config["availability"] = "AVAILABLE"
      else
        config["newSubscriberAvailability"] = true
      end
      by_region[config.fetch("regionCode")] = config
    end
    configs.each { |config| converted_configs[config.fetch("regionCode")] = config }

    expanded = item.merge(regional_key => converted_configs.keys.sort.map { |region| converted_configs.fetch(region) })
    if conversion["convertedOtherRegionsPrice"]
      other_regions_config = conversion.fetch("convertedOtherRegionsPrice")
      if availability == :one_time_product
        expanded["newRegionsConfig"] ||= other_regions_config.merge("availability" => "AVAILABLE")
      else
        expanded["otherRegionsConfig"] ||= other_regions_config.merge("newSubscriberAvailability" => true)
      end
    end
    expanded.reject { |key, _| key == "_pricing" }
  end

  def expand_one_time_offer_regions(offer, purchase_option)
    return offer unless offer.fetch("_all_regions", false)

    pricing = purchase_option.fetch("_pricing")
    conversion = converted_region_prices(pricing.fetch("base_price"), pricing.fetch("base_currency"))
    template = offer.fetch("_all_regions_config")
    absolute_discount_pricing = template.delete("_absolute_discount_pricing")
    absolute_discount_conversion = if absolute_discount_pricing
      converted_region_prices(absolute_discount_pricing.fetch("base_price"), absolute_discount_pricing.fetch("base_currency"))
    end
    converted_configs = conversion.fetch("convertedRegionPrices").values.each_with_object({}) do |converted, by_region|
      region = converted.fetch("regionCode")
      config = template.merge(
        "regionCode" => converted.fetch("regionCode"),
        "availability" => "AVAILABLE"
      )
      if absolute_discount_conversion
        config["absoluteDiscount"] = absolute_discount_conversion.fetch("convertedRegionPrices").fetch(region).fetch("price")
      end
      by_region[region] = config
    end
    offer.fetch("regionalPricingAndAvailabilityConfigs").each do |config|
      converted_configs[config.fetch("regionCode")] = config
    end

    offer.merge(
      "regionalPricingAndAvailabilityConfigs" => converted_configs.keys.sort.map { |region| converted_configs.fetch(region) }
    )
  end

  def expand_subscription_offer_regions(offer, base_plan)
    return offer unless offer.fetch("_all_regions", false)

    base_regions = base_plan.fetch("regionalConfigs").map { |config| config.fetch("regionCode") }
    existing = offer.fetch("regionalConfigs").each_with_object({}) do |config, by_region|
      by_region[config.fetch("regionCode")] = config
    end
    base_regions.each do |region|
      existing[region] ||= {
        "regionCode" => region,
        "newSubscriberAvailability" => true
      }
    end
    if base_plan["otherRegionsConfig"]
      offer["otherRegionsConfig"] ||= {
        "otherRegionsNewSubscriberAvailability" => base_plan.fetch("otherRegionsConfig").fetch("newSubscriberAvailability", true)
      }
    end

    offer.merge("regionalConfigs" => existing.keys.sort.map { |region| existing.fetch(region) })
  end

  def expand_subscription_offer_phase_regions(phases, offer)
    offer_regions = offer.fetch("regionalConfigs").map { |config| config.fetch("regionCode") }
    phases.map do |phase|
      pricing = phase["_pricing"]
      configs = materialize_money(phase.fetch("regionalConfigs"))
      if pricing&.fetch("all_regions", false)
        conversion = converted_region_prices(pricing.fetch("base_price"), pricing.fetch("base_currency"))
        converted_configs = conversion.fetch("convertedRegionPrices").values.each_with_object({}) do |converted, by_region|
          next unless offer_regions.include?(converted.fetch("regionCode"))

          by_region[converted.fetch("regionCode")] = {
            "regionCode" => converted.fetch("regionCode"),
            "price" => converted.fetch("price")
          }
        end
        configs.each do |config|
          converted_configs[config.fetch("regionCode")] = config
        end
        expanded = phase.merge("regionalConfigs" => offer_regions.sort.map { |region| converted_configs.fetch(region) })
        if conversion["convertedOtherRegionsPrice"]
          expanded["otherRegionsConfig"] ||= {
            "otherRegionsPrices" => conversion.fetch("convertedOtherRegionsPrice")
          }
        end
        expanded.reject { |key, _| key == "_pricing" }
      else
        phase.merge("regionalConfigs" => configs).reject { |key, _| key == "_pricing" }
      end
    end
  end

  def materialize_money(items)
    items.map do |item|
      item = item.dup
      amount = item.delete("_amount")
      next item unless amount

      currency = item.delete("_currency") || currency_for_region(item.fetch("regionCode"))
      item.merge("price" => money(amount, currency))
    end
  end

  def currency_for_region(region_code)
    return @currency_cache[region_code] if @currency_cache.key?(region_code)

    response = @client.post_json(
      "/applications/#{@config.package_name}/pricing:convertRegionPrices",
      body: {
        "price" => {
          "currencyCode" => "USD",
          "units" => "1",
          "nanos" => 0
        }
      }
    )
    response.fetch("convertedRegionPrices").each_value do |converted|
      @currency_cache[converted.fetch("regionCode")] = converted.fetch("price").fetch("currencyCode")
    end
    @currency_cache.fetch(region_code)
  end

  def converted_region_prices(base_price, base_currency)
    @price_conversion_cache ||= {}
    cache_key = [base_price, base_currency].join(":")
    return @price_conversion_cache[cache_key] if @price_conversion_cache.key?(cache_key)

    @price_conversion_cache[cache_key] = @client.post_json(
      "/applications/#{@config.package_name}/pricing:convertRegionPrices",
      body: {
        "price" => money(base_price, base_currency)
      }
    )
  end

  def money(amount, currency)
    {
      "currencyCode" => currency,
      "units" => units(amount),
      "nanos" => nanos(amount)
    }
  end

  def units(amount)
    decimal = BigDecimal(amount)
    decimal.truncate(0).to_i.to_s
  end

  def nanos(amount)
    decimal = BigDecimal(amount)
    fractional = decimal.frac
    (fractional * 1_000_000_000).to_i
  end
end

def usage
  <<~TEXT
    Usage:
      ruby fastlane/scripts/google_play_commerce.rb fastlane/commerce/google_play.json [--dry-run]

    This automation supports:
      - one-time product creation and updates
      - subscription and base plan creation and updates
      - per-country pricing for products and base plans
      - base plan activation
      - subscription offer upserts and activation
      - subscriber price cohort migration
  TEXT
end

if __FILE__ == $PROGRAM_NAME
  path = ARGV.find { |arg| !arg.start_with?("--") }
  dry_run = ARGV.include?("--dry-run")

  unless path
    warn usage
    exit 1
  end

  default_package_name = ENV.fetch("PLAY_STORE_PACKAGE_NAME", "").strip
  config = GooglePlayCommerceConfig.load(path, default_package_name: default_package_name)
  if !default_package_name.empty? && config.package_name != default_package_name
    raise GooglePlayCommerceError, "Commerce config package_name #{config.package_name} does not match PLAY_STORE_PACKAGE_NAME #{default_package_name}"
  end

  GooglePlayCommerceSync.new(config: config, dry_run: dry_run).run
end
