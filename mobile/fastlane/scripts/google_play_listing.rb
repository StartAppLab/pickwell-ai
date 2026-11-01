#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "pathname"
require "chunky_png"
require "fastimage"
require "deliver/app_screenshot"

class GooglePlayListingError < StandardError; end

class GooglePlayListing
  LOCALE_MAP = {
    "es-MX" => "es-419",
    "hi" => "hi-IN",
    "it" => "it-IT",
    "ja" => "ja-JP",
    "ko" => "ko-KR",
    "ru" => "ru-RU",
    "zh-Hans" => "zh-CN"
  }.freeze

  IOS_FIELD_MAP = {
    "name.txt" => "title.txt",
    "description.txt" => "full_description.txt"
  }.freeze

  # Reuse the pinned Fastlane version's device sizes, including portrait/landscape.
  IPAD_RESOLUTIONS = Deliver::AppScreenshot::DEVICE_RESOLUTIONS
    .select { |type, _| type.start_with?("APP_IPAD_") }.values.flatten(1).uniq.freeze
  TABLET_SCREENSHOT_TYPES = %w[sevenInchScreenshots tenInchScreenshots].freeze

  LIMITS = {
    "title.txt" => 30,
    "short_description.txt" => 80,
    "full_description.txt" => 4_000,
    File.join("changelogs", "default.txt") => 500
  }.freeze

  def initialize(metadata_path:, android_source_path:, screenshots_path:, output_path:, include_screenshots:)
    @metadata_path = Pathname(metadata_path)
    @android_source_path = Pathname(android_source_path)
    @screenshots_path = Pathname(screenshots_path)
    @output_path = Pathname(output_path)
    @include_screenshots = include_screenshots
  end

  def run
    locales = source_locales
    raise GooglePlayListingError, "No iOS metadata locales found in #{@metadata_path}" if locales.empty?

    remove_generated_locales
    locales.each { |locale| sync_locale(locale) }
    puts "Generated Google Play listing for #{locales.size} locales in #{@output_path}"
  end

  private

  def source_locales
    @metadata_path.children.select do |path|
      path.directory? && IOS_FIELD_MAP.keys.all? { |filename| path.join(filename).file? }
    end.sort_by { |path| path.basename.to_s }
  end

  def remove_generated_locales
    FileUtils.mkdir_p(@output_path)
    return if @output_path.expand_path == @android_source_path.expand_path

    @output_path.children.select(&:directory?).each { |path| FileUtils.rm_rf(path) }
  end

  def sync_locale(source_locale_path)
    source_locale = source_locale_path.basename.to_s
    play_locale = LOCALE_MAP.fetch(source_locale, source_locale)
    destination = @output_path.join(play_locale)

    IOS_FIELD_MAP.each do |source_name, destination_name|
      content = fit_to_limit(destination_name, source_locale_path.join(source_name).read.strip)
      validate_length!(play_locale, destination_name, content)
      write(destination.join(destination_name), content)
    end

    short_description_path = android_source_file_path(source_locale, play_locale, "short_description.txt")
    raise GooglePlayListingError, "Missing Android short description: #{short_description_path}" unless short_description_path.file?

    short_description = short_description_path.read.strip
    validate_length!(play_locale, "short_description.txt", short_description)
    write(destination.join("short_description.txt"), short_description)

    release_notes_path = android_source_file_path(
      source_locale,
      play_locale,
      File.join("changelogs", "default.txt"),
      "release_notes.txt"
    )
    raise GooglePlayListingError, "Missing Android release notes: #{release_notes_path}" unless release_notes_path.file?

    release_notes = fit_to_limit(File.join("changelogs", "default.txt"), release_notes_path.read.strip)
    validate_length!(play_locale, File.join("changelogs", "default.txt"), release_notes)
    write(destination.join("changelogs", "default.txt"), release_notes)

    sync_screenshots(source_locale, destination) if @include_screenshots
  end

  def validate_length!(locale, filename, content)
    limit = LIMITS.fetch(filename)
    length = content.length
    return if length <= limit

    raise GooglePlayListingError, "#{locale}/#{filename} is #{length} characters; Google Play allows #{limit}"
  end

  def fit_to_limit(filename, content)
    limit = LIMITS.fetch(filename)
    return content if content.length <= limit
    return content unless filename == File.join("changelogs", "default.txt")

    selected = []
    content.lines.map(&:strip).reject(&:empty?).each do |line|
      candidate = (selected + [line]).join("\n\n")
      break if candidate.length > limit

      selected << line
    end
    return selected.join("\n\n") unless selected.empty?

    "#{content[0, limit - 1].rstrip}…"
  end

  def write(path, content)
    FileUtils.mkdir_p(path.dirname)
    path.write("#{content}\n")
  end

  def sync_screenshots(source_locale, destination)
    sync_phone_screenshots(source_locale, destination)
    play_locale = LOCALE_MAP.fetch(source_locale, source_locale)
    TABLET_SCREENSHOT_TYPES.each do |type|
      source = @android_source_path.join(play_locale, "images", type)
      next unless source.directory?

      target = destination.join("images", type)
      # The standard CLI edits metadata/android in place; keep authored tablet files intact.
      next if source.expand_path == target.expand_path

      FileUtils.mkdir_p(target)
      image_files(source).each { |image| prepare_screenshot(image, target.join(image.basename)) }
    end
  end

  def sync_phone_screenshots(source_locale, destination)
    source = @screenshots_path.join(source_locale)
    return unless source.directory?

    images = image_files(source).reject do |image|
      size = FastImage.size(image.to_s)
      raise GooglePlayListingError, "Unable to read image dimensions for #{image}" unless size

      IPAD_RESOLUTIONS.include?(size)
    end
    target = destination.join("images", "phoneScreenshots")
    # Also clear old generated phone images when this locale now contains only iPads.
    FileUtils.rm_rf(target)
    return if images.empty?

    FileUtils.mkdir_p(target)
    images.each { |image| prepare_screenshot(image, target.join(image.basename)) }
  end

  def image_files(directory)
    directory.children.select do |path|
      path.file? && %w[.png .jpg .jpeg].include?(path.extname.downcase)
    end.sort_by { |path| path.basename.to_s }
  end

  def prepare_screenshot(source, destination)
    width, height = FastImage.size(source.to_s)
    raise GooglePlayListingError, "Unable to read image dimensions for #{source}" unless width && height

    ratio = [width, height].max.fdiv([width, height].min)
    if ratio <= 2.0
      FileUtils.cp(source, destination)
      return
    end

    if height > width
      padded_width = (height / 2.0).ceil
      pad_screenshot(source, destination, padded_width, height)
    else
      padded_height = (width / 2.0).ceil
      pad_screenshot(source, destination, width, padded_height)
    end
  end

  def pad_screenshot(source, destination, width, height)
    sips = executable("sips") unless ENV["GOOGLE_PLAY_FORCE_PORTABLE_IMAGES"] == "true"
    return pad_with_sips(sips, source, destination, width, height) if sips

    pad_with_chunky_png(source, destination, width, height)
  end

  def pad_with_chunky_png(source, destination, width, height)
    image = ChunkyPNG::Image.from_file(source.to_s)
    background = ChunkyPNG::Color.rgb(247, 245, 239)
    canvas = ChunkyPNG::Image.new(width, height, background)
    canvas.compose!(image, (width - image.width) / 2, (height - image.height) / 2)
    canvas.save(destination.to_s)
  rescue ChunkyPNG::SignatureMismatch
    raise GooglePlayListingError, "#{source} must be a PNG when native macOS image tools are unavailable"
  end

  def pad_with_sips(sips, source, destination, width, height)
    _stdout, stderr, status = Open3.capture3(
      sips, "--padToHeightWidth", height.to_s, width.to_s,
      "--padColor", "F7F5EF", source.to_s, "--out", destination.to_s
    )
    return if status.success?

    warn "sips failed for #{source}, falling back to portable PNG padding: #{stderr.strip}"
    pad_with_chunky_png(source, destination, width, height)
  end

  def android_source_file_path(source_locale, play_locale, *filenames)
    [play_locale, source_locale].uniq.each do |locale|
      filenames.each do |filename|
        path = @android_source_path.join(locale, filename)
        return path if path.file?
      end
    end

    @android_source_path.join(source_locale, filenames.first)
  end

  def executable(name)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |directory|
      path = File.join(directory, name)
      return path if File.file?(path) && File.executable?(path)
    end
    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  project_root = Pathname(__dir__).join("..", "..").expand_path
  include_screenshots = !ARGV.include?("--skip-screenshots")

  GooglePlayListing.new(
    metadata_path: project_root.join("fastlane", "metadata"),
    android_source_path: project_root.join("fastlane", "metadata", "android"),
    screenshots_path: project_root.join("fastlane", "screenshots"),
    output_path: project_root.join("fastlane", "metadata", "android"),
    include_screenshots: include_screenshots
  ).run
end
