# frozen_string_literal: true

module Underpass
  # Wraps an RGeo geometry with OSM metadata (tags, id, type).
  #
  # Returned by {QL::Query.perform} and {Matcher#matches} for each matched
  # element in the Overpass API response.
  class Feature
    # @return [RGeo::Feature::Geometry] the RGeo geometry object
    attr_reader :geometry

    # @return [Hash{Symbol => String}] the OSM tags for this element
    attr_reader :properties

    # @return [Integer, nil] the OSM element ID
    attr_reader :id

    # @return [String, nil] the OSM element type ("node", "way", or "relation")
    attr_reader :type

    # Creates a new Feature.
    #
    # @param geometry [RGeo::Feature::Geometry] the RGeo geometry
    # @param properties [Hash] the OSM tags
    # @param id [Integer, nil] the OSM element ID
    # @param type [String, nil] the OSM element type
    def initialize(geometry:, properties: {}, id: nil, type: nil)
      @geometry = geometry
      @properties = properties
      @id = id
      @type = type
    end
  end
end
