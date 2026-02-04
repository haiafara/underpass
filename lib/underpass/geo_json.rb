# frozen_string_literal: true

require 'rgeo/geo_json'

module Underpass
  # Encodes {Feature} arrays as GeoJSON FeatureCollections.
  #
  # @example Export query results to GeoJSON
  #   features = Underpass::QL::Query.perform(bbox, query)
  #   geojson = Underpass::GeoJSON.encode(features)
  module GeoJSON
    # Encodes an array of features as a GeoJSON FeatureCollection hash.
    #
    # @param features [Array<Feature>] the features to encode
    # @return [Hash] a GeoJSON FeatureCollection
    def self.encode(features)
      geo_features = features.map do |f|
        RGeo::GeoJSON::Feature.new(f.geometry, f.id, f.properties)
      end
      RGeo::GeoJSON.encode(RGeo::GeoJSON::FeatureCollection.new(geo_features))
    end
  end
end
