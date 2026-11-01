# frozen_string_literal: true

module FastlaneEnv
  module_function

  def project_root
    File.expand_path("../..", __dir__)
  end

  def fastlane_root
    File.expand_path("..", __dir__)
  end

  def load!(path = File.join(project_root, ".env.fastlane"))
    return unless File.exist?(path)

    File.readlines(path, chomp: true).each do |line|
      entry = line.strip
      next if entry.empty? || entry.start_with?("#")

      key, value = entry.split("=", 2)
      next if key.nil? || value.nil?

      key = key.strip
      value = value.strip
      value = value[1..-2] if value.start_with?('"') && value.end_with?('"')
      value = value[1..-2] if value.start_with?("'") && value.end_with?("'")
      ENV[key] = value unless ENV.key?(key)
    end
  end
end
