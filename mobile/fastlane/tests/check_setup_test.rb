# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../scripts/check_setup"

class StoreSetupCheckTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir
    @env = { "APP_STORE_BUNDLE_ID" => "org.test.app", "PLAY_STORE_PACKAGE_NAME" => "org.test.app" }
    @paths = {}
    %w[app_store google_play].each do |store|
      data = JSON.parse(File.read(File.expand_path("../commerce/#{store}.example.json", __dir__)))
      data[store == "app_store" ? "bundle_id" : "package_name"] = "org.test.app"
      data["subscriptions"].each { |item| item["subscription_group_id"] = "12345" } if store == "app_store"
      @paths[store] = File.join(@root, "#{store}.json")
      File.write(@paths[store], JSON.generate(data).gsub("myapp.", "testapp."))
    end
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def check(platform: "both", forbidden: [])
    @checker = StoreSetupCheck.new(root: @root, env: @env)
    result = nil
    capture_io do
      result = @checker.check(platform: platform, ios_config: @paths["app_store"], android_config: @paths["google_play"], forbidden: forbidden)
    end
    result
  end

  def change(store)
    data = JSON.parse(File.read(@paths[store]))
    yield data
    File.write(@paths[store], JSON.generate(data))
  end

  def test_examples_validate_after_replacement_without_store_clients
    AppStoreConnectClient.stub(:new, ->(*) { raise "Unexpected store access" }) do
      GooglePlayClient.stub(:new, ->(*) { raise "Unexpected store access" }) do
        assert check
      end
    end
  end

  def test_rejects_identity_mismatch
    change("app_store") { |data| data["bundle_id"] = "org.other.app" }
    refute check
    assert_match(/does not match/, @checker.errors.join)
  end

  def test_rejects_duplicate_plan_ids
    change("google_play") do |data|
      data["subscriptions"][0]["base_plans"] << data["subscriptions"][0]["base_plans"].first.dup
    end
    refute check
    assert_match(/base_plan_id/, @checker.errors.join)
  end

  def test_rejects_placeholder_group
    change("app_store") { |data| data["subscriptions"][0]["subscription_group_id"] = "REPLACE_WITH_SUBSCRIPTION_GROUP_ID" }
    refute check
    assert_match(/placeholder/, @checker.errors.join)
  end

  def test_rejects_zero_commerce_price
    change("google_play") { |data| data["subscriptions"][0]["base_plans"][0]["pricing"]["base_price"] = "0" }
    refute check
    assert_match(/positive/, @checker.errors.join)
  end

  def test_rejects_invalid_subscription_period
    change("app_store") { |data| data["subscriptions"][0]["subscription_period"] = "P1W" }
    refute check
    assert_match(/ONE_WEEK/, @checker.errors.join)
  end

  def test_rejects_consumable_lifetime_unlock
    change("app_store") { |data| data["in_app_purchases"][0]["in_app_purchase_type"] = "CONSUMABLE" }
    refute check
    assert_match(/NON_CONSUMABLE/, @checker.errors.join)
  end

  def test_rejects_duplicate_products
    change("app_store") { |data| data["subscriptions"][0]["product_id"] = data["in_app_purchases"][0]["product_id"] }
    refute check
    assert_match(/product_id/, @checker.errors.join)
  end

  def test_existing_subscription_id_can_replace_group_id
    change("app_store") do |data|
      data["subscriptions"].each do |item|
        item.delete("subscription_group_id")
        item["id"] = "98765"
      end
    end
    assert check
  end

  def test_finds_old_brand_case_insensitively_without_printing_contents
    FileUtils.mkdir_p(File.join(@root, "metadata", "en-US"))
    File.write(File.join(@root, "metadata", "en-US", "name.txt"), "OldBrand secret text")
    refute check(forbidden: ["oldbrand"])
    assert_match(/name.txt/, @checker.errors.join)
    refute_match(/secret text/, @checker.errors.join)
  end

  def test_one_platform_does_not_require_other_catalog
    File.delete(@paths["app_store"])
    assert check(platform: "android")
  end

  def test_reports_missing_and_invalid_configs
    File.delete(@paths["app_store"])
    File.write(@paths["google_play"], "{")
    refute check
    assert_equal 2, @checker.errors.size
  end
end
