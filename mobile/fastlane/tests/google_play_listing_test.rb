# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "fastlane"
require "deliver/loader"
require_relative "../scripts/google_play_listing"

class GooglePlayListingTest < Minitest::Test
  def setup
    @root = Pathname(Dir.mktmpdir)
    @metadata = @root.join("metadata")
    @android = @root.join("android")
    @screenshots = @root.join("screenshots")
    @output = @root.join("generated")
    locale("en-US")
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def locale(ios, play = ios)
    { @metadata.join(ios, "name.txt") => "Test App",
      @metadata.join(ios, "description.txt") => "App description",
      @android.join(play, "short_description.txt") => "Short description",
      @android.join(play, "changelogs", "default.txt") => "Release notes" }.each do |path, text|
      FileUtils.mkdir_p(path.dirname)
      path.write(text)
    end
  end

  def image(path, width, height, color = ChunkyPNG::Color::BLACK)
    FileUtils.mkdir_p(path.dirname)
    ChunkyPNG::Image.new(width, height, color).save(path.to_s)
    path
  end

  def generate(output: @output, screenshots: true)
    capture_io do
      GooglePlayListing.new(metadata_path: @metadata, android_source_path: @android,
        screenshots_path: @screenshots, output_path: output, include_screenshots: screenshots).run
    end
  end

  def test_mixed_iphone_and_ipads_keep_their_apple_families_and_only_phone_goes_to_play
    image(@screenshots.join("en-US", "01-iphone.png"), 1242, 2208)
    image(@screenshots.join("en-US", "01-ipad-13.png"), 2064, 2752)
    image(@screenshots.join("en-US", "02-ipad-landscape.png"), 2752, 2064)
    image(@screenshots.join("en-US", "03-ipad-129.png"), 2048, 2732)
    image(@screenshots.join("en-US", "04-ipad-11.png"), 1668, 2388)
    original_files = @screenshots.glob("en-US/*").map { |path| [path, path.binread] }.to_h
    # Exercise Deliver's actual local loader, without connecting to App Store Connect.
    screenshots = Deliver::Loader.load_app_screenshots(@screenshots.to_s, false)
    assert_equal 5, screenshots.size
    assert_equal 4, screenshots.count { |shot| shot.display_type.start_with?("APP_IPAD_") }
    assert_equal "APP_IPAD_PRO_3GEN_129", screenshots.find { |shot| shot.path.end_with?("03-ipad-129.png") }.display_type
    generate
    assert_equal ["01-iphone.png"], @output.glob("en-US/images/phoneScreenshots/*").map { |p| p.basename.to_s }
    original_files.each { |path, bytes| assert_equal bytes, path.binread }
    refute @output.join("en-US/images/tenInchScreenshots").exist?
  end

  def test_android_tablets_copy_without_ios_images_and_use_mapped_locale_sources
    locale("es-MX", "es-419")
    seven = image(@android.join("es-419/images/sevenInchScreenshots/01-home.png"), 1200, 1920)
    ten = image(@android.join("es-419/images/tenInchScreenshots/01-home.png"), 1600, 2560)
    generate
    assert_equal seven.binread, @output.join("es-419/images/sevenInchScreenshots/01-home.png").binread
    assert_equal ten.binread, @output.join("es-419/images/tenInchScreenshots/01-home.png").binread
    refute @output.join("es-419/images/phoneScreenshots").exist?
  end

  def test_in_place_sync_clears_old_phone_images_for_ipad_only_locale_and_preserves_tablets
    image(@screenshots.join("en-US/01-ipad.png"), 2064, 2752)
    stale = image(@android.join("en-US/images/phoneScreenshots/old-ipad.png"), 320, 640)
    tablet = image(@android.join("en-US/images/tenInchScreenshots/01-home.png"), 1600, 2560)
    bytes = tablet.binread
    2.times { generate(output: @android) }
    refute stale.exist?
    assert_equal bytes, tablet.binread
  end

  def test_skip_screenshots_keeps_authored_images_unchanged
    phone = image(@android.join("en-US/images/phoneScreenshots/01-home.png"), 320, 640)
    tablet = image(@android.join("en-US/images/sevenInchScreenshots/01-home.png"), 1200, 1920)
    generate(output: @android, screenshots: false)
    assert phone.file?
    assert tablet.file?
  end

  def test_phone_padding_still_obeys_play_aspect_ratio_with_portable_processor
    image(@screenshots.join("en-US/01-iphone.png"), 1290, 2796)
    previous = ENV["GOOGLE_PLAY_FORCE_PORTABLE_IMAGES"]
    ENV["GOOGLE_PLAY_FORCE_PORTABLE_IMAGES"] = "true"
    generate
    assert_equal [1398, 2796], FastImage.size(@output.join("en-US/images/phoneScreenshots/01-iphone.png").to_s)
  ensure
    ENV["GOOGLE_PLAY_FORCE_PORTABLE_IMAGES"] = previous
  end

  def test_corrupt_image_is_reported_locally
    path = @screenshots.join("en-US/01-corrupt.png")
    FileUtils.mkdir_p(path.dirname)
    path.write("not an image")
    error = assert_raises(GooglePlayListingError) { generate }
    assert_match(/Unable to read image dimensions/, error.message)
  end
end
