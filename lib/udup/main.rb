# frozen_string_literal: true

require 'uri'
require 'set'

class Udup
  def initialize(options = {})
    @valid_urls = {}
    @skip_exts = options[:skip_exts] || %w[.css .png .jpg .jpeg .svg .ico .webp .ttf .otf .woff .woff2 .gif .pdf .bmp
                                           .eot .mp3 .mp4 .avi]
    @content_to_skip = options[:content_to_skip] || %w[blog docs post support]
    @bad_char_path = options[:bad_char_path] || %w[+ ' " ( ) \\ <]
  end

  def filter(urls)
    final_urls = Set[]

    urls.each do |url|
      next unless url.start_with?('http')

      begin
        uri = URI.parse(url)
      rescue URI::InvalidURIError
        next
      end
      next unless uri
      next if @bad_char_path.any? { |char| uri.path.include?(char) }

      uri_ext = File.extname(uri.path)
      next if @skip_exts.include?(uri_ext) || human_content?(uri.path) || content_to_skip?(uri.path)

      base_url = without_query(uri)
      params = uri_params(uri.query)

      if @valid_urls.key?(base_url)
        @valid_urls[uri.to_s] = { params: {} } if @valid_urls[base_url][:params].empty?
        @valid_urls[base_url][:params].merge!(params)
      else
        @valid_urls[base_url] = { params: params }
      end
    end

    @valid_urls.each do |url, data|
      final_url = url
      final_url += "?#{URI.encode_www_form(data[:params])}" unless data[:params].empty?
      final_urls << final_url
    end

    final_urls.to_a
  end

  private

  def without_query(uri)
    uri.to_s.split('?', 2).first.to_s
  end

  def uri_params(query)
    params = {}
    query&.split('&')&.each do |param|
      splitted = param.split('=')
      params[splitted[0]] = splitted[1]
    end

    params
  end

  def human_content?(path)
    human_content = false
    path&.split('/')&.each { |part| human_content = true if part.count('-') >= 3 }

    human_content
  end

  def content_to_skip?(path)
    @content_to_skip.any? { |content| path.include?(content) }
  end
end
