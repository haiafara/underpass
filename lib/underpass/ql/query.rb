# frozen_string_literal: true

module Underpass
  module QL
    # Provides a shortcut method that makes it easy to work with the library
    class Query
      # Shortcut method that glues together the whole library.
      # * +bounding_box+ an RGeo polygon
      # * +query+ an Overpass QL query string or a Builder instance
      def self.perform(bounding_box, query)
        query_string     = resolve_query(query)
        op_bbox          = Underpass::QL::BoundingBox.from_geometry(bounding_box)
        request          = Underpass::QL::Request.new(query_string, op_bbox)
        execute(request, query_string)
      end

      # Queries within a named area (e.g., "Romania") instead of a bounding box.
      # * +area_name+ a string matching an OSM area name
      # * +query+ an Overpass QL query string or a Builder instance
      def self.perform_in_area(area_name, query)
        query_string = resolve_query(query)
        request      = Underpass::QL::Request.new(query_string, nil, area_name: area_name)
        execute(request, query_string)
      end

      def self.resolve_query(query)
        query.respond_to?(:to_ql) ? query.to_ql : query
      end
      private_class_method :resolve_query

      def self.execute(request, query_string)
        api_response     = Underpass::Client.perform(request)
        response         = Underpass::QL::Response.new(api_response)
        query_analyzer   = Underpass::QL::QueryAnalyzer.new(query_string)
        requested_types  = query_analyzer.requested_types
        matcher          = Underpass::Matcher.new(response, requested_types)

        matcher.matches
      end
      private_class_method :execute
    end
  end
end
