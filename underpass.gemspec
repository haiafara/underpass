# frozen_string_literal: true

require 'date'
require File.expand_path('lib/underpass/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'underpass'
  s.version = Underpass.gem_version

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
  s.metadata = {
    'source_code_uri' => s.homepage,
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md'].to_a
  s.required_ruby_version = '>= 3.4.0'

  s.add_dependency 'rgeo', '~> 3.1'
  s.add_dependency 'rgeo-geojson', '~> 2.2'
end
