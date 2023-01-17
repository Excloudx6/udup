# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'udup'
  spec.version       = '0.1.2'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'URL Deduplication'
  spec.homepage      = 'https://rubygems.org/gems/udup'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.1'

  spec.files = Dir['lib/**/*.rb']
end
