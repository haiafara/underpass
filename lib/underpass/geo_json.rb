# frozen_string_literal: true

require 'rgeo/geo_json'

module Underpass
  # Encodes Underpass::Feature arrays as GeoJSON FeatureCollections
  module GeoJSON
    def self.encode(features)
      geo_features = features.map do |f|
        RGeo::GeoJSON::Feature.new(f.geometry, f.id, f.properties)
      end
      RGeo::GeoJSON.encode(RGeo::GeoJSON::FeatureCollection.new(geo_features))
    end
  end
end
