# frozen_string_literal: true

module Underpass
  module QL
    # Provides a shortcut method that makes it easy to work with the library
    class Query
      # Shortcut method that glues together the whole library.
      # * +bounding_box+ an RGeo polygon
      # * +query+ an Overpass QL query
      def self.perform(bounding_box, query)
        op_bbox          = Underpass::QL::BoundingBox.from_geometry(bounding_box)
        request          = Underpass::QL::Request.new(query, op_bbox)
        api_response     = Underpass::Client.perform(request)
        response         = Underpass::QL::Response.new(api_response)
        query_analyzer   = Underpass::QL::QueryAnalyzer.new(query)
        requested_types  = query_analyzer.requested_types
        matcher          = Underpass::Matcher.new(response, requested_types)

        matcher.matches
      end
    end
  end
end
