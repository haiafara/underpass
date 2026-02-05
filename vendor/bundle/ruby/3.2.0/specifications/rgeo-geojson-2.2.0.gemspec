# -*- encoding: utf-8 -*-
# stub: rgeo-geojson 2.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rgeo-geojson".freeze
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Azuma".freeze, "Tee Parham".freeze]
  s.date = "2024-07-22"
  s.description = "Convert RGeo data to and from GeoJSON. rgeo-geojson is an extension to the rgeo gem that converts RGeo data types to and from GeoJSON.".freeze
  s.email = ["dazuma@gmail.com".freeze, "parhameter@gmail.com".freeze, "kfdoggett@gmail.com".freeze]
  s.homepage = "https://github.com/rgeo/rgeo-geojson".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Convert RGeo data to and from GeoJSON.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rgeo>.freeze, [">= 1.0.0"])
  s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.15"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
end
