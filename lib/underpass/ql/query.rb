# frozen_string_literal: true

module Underpass
  module QL
    # Provides a shortcut method that makes it easy to work with the library
    class Query
      # Shortcut method that glues together the whole library.
      # * +bounding_box+ an RGeo polygon
      # * +query+ an Overpass QL query
      def self.perform(bounding_box, query)
        op_bbox      = Underpass::QL::BoundingBox.from_geometry(bounding_box)
        request      = Underpass::QL::Request.new(query, op_bbox)
        api_response = Underpass::Client.perform(request)
        response     = Underpass::QL::Response.new(api_response)
        matcher      = Underpass::Matcher.new(response)

        matcher.matches
      end
    end
  end
end
