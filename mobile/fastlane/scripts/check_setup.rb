#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "app_store_commerce"
require_relative "google_play_commerce"

# Loading config classes does not initialize either store client.
class StoreSetupCheck
  attr_reader :errors

  def initialize(root: FastlaneEnv.fastlane_root, env: ENV)
    @root = root
    @env = env
    @errors = []
  end

  def check(platform:, ios_config:, android_config:, forbidden: [])
    check_catalog(:ios, ios_config) if %w[both ios].include?(platform)
    check_catalog(:android, android_config) if %w[both android].include?(platform)
    check_leftovers(forbidden, [ios_config, android_config])
    errors.empty?
  end

  private

  def check_catalog(platform, path)
    env_key, identity_key = platform == :ios ? %w[APP_STORE_BUNDLE_ID bundle_id] : %w[PLAY_STORE_PACKAGE_NAME package_name]
    identity = @env[env_key].to_s.strip
    raise ArgumentError, "Set #{env_key} in .env.fastlane" if identity.empty?
    raise ArgumentError, "Replace the example identity in #{env_key}" if identity.start_with?("com.example.")

    data = JSON.parse(File.read(path))
    configured = data[identity_key] || identity
    raise ArgumentError, "#{identity_key} does not match #{env_key}" unless configured == identity
    raise ArgumentError, "Replace placeholder values" if JSON.generate(data).match?(/REPLACE_WITH_|com\.example\.|pickwell\./i)

    if platform == :ios
      config = AppStoreCommerceConfig.load(path, default_bundle_id: identity)
      products = config.in_app_purchases + config.subscriptions
      config.in_app_purchases.each do |item|
        raise ArgumentError, "#{item['product_id']}: lifetime purchases must use NON_CONSUMABLE" unless item["in_app_purchase_type"] == "NON_CONSUMABLE"
      end
      config.subscriptions.each do |item|
        raise ArgumentError, "#{item['product_id']}: set subscription_group_id or existing id" if item["subscription_group_id"].to_s.empty? && item["id"].to_s.empty?
        raise ArgumentError, "#{item['product_id']}: use ONE_WEEK, ONE_MONTH, or ONE_YEAR" unless %w[ONE_WEEK ONE_MONTH ONE_YEAR].include?(item["subscription_period"])
      end
    else
      config = GooglePlayCommerceConfig.load(path, default_package_name: identity)
      products = config.one_time_products + config.subscriptions
      data.fetch("one_time_products", []).each do |item|
        options = item.fetch("purchase_options")
        raise ArgumentError, "#{item['product_id']}: add a buy purchase option" if options.empty? || options.any? { |option| option["purchase_type"] != "buy" }
        unique_ids!(options, "purchase_option_id")
      end
      data.fetch("subscriptions", []).each do |item|
        plans = item.fetch("base_plans")
        raise ArgumentError, "#{item['product_id']}: add a base plan" if plans.empty?
        unique_ids!(plans, "base_plan_id")
        plans.each do |plan|
          raise ArgumentError, "#{item['product_id']}: use auto_renewing with P1W, P1M, or P1Y" unless plan["plan_type"] == "auto_renewing" && %w[P1W P1M P1Y].include?(plan["billing_period_duration"])
        end
      end
    end
    raise ArgumentError, "Commerce catalog is empty" if products.empty?
    unique_ids!(products, "product_id")
    check_prices(data)
    puts "OK: #{platform} commerce config"
  rescue StandardError => e
    errors << "#{path}: #{e.message}"
  end

  def unique_ids!(items, key)
    values = items.map { |item| item.fetch(key).to_s.strip }
    raise ArgumentError, "#{key} must be nonempty and unique" if values.any?(&:empty?) || values.uniq.size != values.size
  end

  def check_prices(value)
    case value
    when Hash
      value.each do |key, child|
        prices = if %w[base_price base_customer_price].include?(key)
          [child]
        elsif key == "manual_prices"
          child.values
        else
          []
        end
        prices.each do |price|
          decimal = BigDecimal(price.to_s)
          raise ArgumentError, "Commerce prices must be finite and positive" unless decimal.finite? && decimal.positive?
        end
        check_prices(child)
      end
    when Array
      value.each { |child| check_prices(child) }
    end
  end

  def check_leftovers(words, config_paths)
    return if words.empty?

    paths = Dir.glob(File.join(@root, "metadata", "**", "*.txt")) +
            Dir.glob(File.join(@root, "commerce", "*.json")) + config_paths
    paths.uniq.select { |path| File.file?(path) && !path.end_with?(".example.json") }.sort.each do |path|
      content = File.read(path).downcase
      errors << "#{path}: contains a forbidden app reference" if words.any? { |word| content.include?(word.downcase) }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    platform: "both",
    ios_config: File.join(FastlaneEnv.fastlane_root, "commerce", "app_store.json"),
    android_config: File.join(FastlaneEnv.fastlane_root, "commerce", "google_play.json"),
    forbidden: []
  }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby fastlane/scripts/check_setup.rb [options] (offline; no credentials required)"
    opts.on("--platform PLATFORM", %w[both ios android]) { |value| options[:platform] = value }
    opts.on("--ios-config PATH") { |value| options[:ios_config] = File.expand_path(value, FastlaneEnv.project_root) }
    opts.on("--android-config PATH") { |value| options[:android_config] = File.expand_path(value, FastlaneEnv.project_root) }
    opts.on("--forbid WORDS", "Comma-separated previous app names, domains, or IDs; repeatable") { |value| options[:forbidden].concat(value.split(",").map(&:strip).reject(&:empty?)) }
  end
  begin
    parser.parse!
    raise OptionParser::InvalidArgument, ARGV.join(" ") unless ARGV.empty?
    checker = StoreSetupCheck.new
    success = checker.check(**options)
    checker.errors.each { |error| warn error }
    exit(success ? 0 : 1)
  rescue OptionParser::ParseError => e
    warn e.message
    warn parser
    exit 1
  end
end
