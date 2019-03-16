# frozen_string_literal: true

module Underpass
  module QL
    # Provides a shortcut method that makes it easy to work with the library
    class Query
      # Shortcut method that glues together the whole library.
      # * +bounding_box+ an RGeo polygon
      # * +query+ is the Overpass QL query
      def self.perform(bounding_box, query)
        op_bbox = Underpass::QL::BoundingBox.from_geometry(bounding_box)
        response = Underpass::QL::Request.new(query, op_bbox).run
        Underpass::QL::Parser.new(response).parse.matches
      end
    end
  end
end
