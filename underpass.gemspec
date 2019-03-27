# frozen_string_literal: true

require 'date'
require File.expand_path('lib/underpass/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'underpass'
  s.version = Underpass::Version.version_string
  s.date = Date.today

  s.summary = <<-SUMMARY
    A library that translates Overpass API responses into RGeo objects
  SUMMARY

  s.description = <<-DESCRIPTION
    A library that makes it easy to query the Overpass API and translate its responses into RGeo objects
  DESCRIPTION

  s.authors = ['Janos Rusiczki']
  s.email = 'janos.rusiczki@gmail.com'
  s.homepage = 'http://github.com/haiafara/underpass'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md'].to_a
  s.required_ruby_version = '>= 2.3.0'
  s.rubygems_version = '3.0.1'

  s.add_runtime_dependency 'rgeo', '~> 2.0', '>= 2.0.0'

  s.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  s.add_development_dependency 'simplecov', '~> 0.16.0'
end
