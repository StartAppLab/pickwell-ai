# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "openssl"
require "uri"

class AppStoreConnectClient
  API_BASE = "https://api.appstoreconnect.apple.com".freeze

  def initialize(error_class:)
    @error_class = error_class
    @key_id = fetch_env("APP_STORE_CONNECT_KEY_ID")
    @issuer_id = fetch_env("APP_STORE_CONNECT_ISSUER_ID")
    @token = build_token(fetch_key_material)
  end

  def get_json(path, query: nil)
    request_json(Net::HTTP::Get.new(build_uri(path, query)))
  end

  def post_json(path, body:)
    request = Net::HTTP::Post.new(build_uri(path))
    request["Content-Type"] = "application/json"
    request.body = JSON.pretty_generate(body)
    request_json(request)
  end

  private

  attr_reader :error_class

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

  def fetch_env(key)
    value = ENV[key]
    raise error_class, "Missing required environment variable #{key}" if value.nil? || value.strip.empty?

    value
  end

  def fetch_key_material
    raw = fetch_env("APP_STORE_CONNECT_KEY_CONTENT")
    return raw if raw.include?("BEGIN PRIVATE KEY")

    Base64.decode64(raw)
  rescue ArgumentError => e
    raise error_class, "APP_STORE_CONNECT_KEY_CONTENT is not valid PEM or base64 PEM: #{e.message}"
  end

  def build_token(key_content)
    header = { alg: "ES256", kid: @key_id, typ: "JWT" }
    payload = {
      iss: @issuer_id,
      aud: "appstoreconnect-v1",
      exp: Time.now.to_i + (20 * 60)
    }

    signing_input = [header, payload].map { |part| base64url(JSON.generate(part)) }.join(".")
    key = OpenSSL::PKey.read(key_content)
    der_signature = key.sign(OpenSSL::Digest::SHA256.new, signing_input)
    signature = ecdsa_der_to_jose(der_signature)

    "#{signing_input}.#{base64url(signature)}"
  rescue OpenSSL::PKey::PKeyError => e
    raise error_class, "Unable to parse App Store Connect private key: #{e.message}"
  end

  def base64url(value)
    Base64.urlsafe_encode64(value).delete("=")
  end

  def ecdsa_der_to_jose(signature)
    sequence = OpenSSL::ASN1.decode(signature)
    integers = sequence.value
    raise error_class, "Unexpected ECDSA signature format" unless sequence.is_a?(OpenSSL::ASN1::Sequence) && integers.size == 2

    integers.map do |integer|
      hex = integer.value.to_i.to_s(16)
      raise error_class, "Unexpected ES256 signature component size" if hex.length > 64

      [hex.rjust(64, "0")].pack("H*")
    end.join
  rescue OpenSSL::ASN1::ASN1Error => e
    raise error_class, "Unable to decode ECDSA signature: #{e.message}"
  end

  def request_json(request)
    request["Authorization"] = "Bearer #{@token}"

    response = Net::HTTP.start(request.uri.host, request.uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    body = response.body.to_s
    parsed = body.empty? ? {} : JSON.parse(body)
    return parsed if response.is_a?(Net::HTTPSuccess)

    details = parsed["errors"]&.map do |error|
      [error["status"], error["title"], error["detail"]].compact.join(" ")
    end

    raise error_class, "App Store Connect API error: #{details&.join(' | ') || body}"
  rescue JSON::ParserError => e
    raise error_class, "Failed to parse App Store Connect response: #{e.message}"
  end
end
