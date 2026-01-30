# frozen_string_literal: true

module Underpass
  # Wraps an RGeo geometry with OSM metadata (tags, id, type)
  class Feature
    attr_reader :geometry, :properties, :id, :type

    def initialize(geometry:, properties: {}, id: nil, type: nil)
      @geometry = geometry
      @properties = properties
      @id = id
      @type = type
    end
  end
end
