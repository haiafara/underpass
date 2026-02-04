# frozen_string_literal: true

module Underpass
  # Namespace for Overpass Query Language related classes.
  module QL
    # High-level entry point for querying the Overpass API.
    #
    # Glues together {Request}, {Client}, {Response}, {QueryAnalyzer}, and
    # {Matcher} to provide a single-call interface.
    #
    # @example Query with a bounding box
    #   features = Underpass::QL::Query.perform(bbox, 'way["building"="yes"];')
    #
    # @example Query with a named area
    #   features = Underpass::QL::Query.perform_in_area('Romania', 'node["place"="city"];')
    class Query
      # Queries the Overpass API within a bounding box.
      #
      # @param bounding_box [RGeo::Feature::Geometry] an RGeo polygon defining the search area
      # @param query [String, Builder] an Overpass QL query string or a {Builder} instance
      # @return [Array<Feature>] the matched features
      # @raise [RateLimitError] when rate limited after exhausting retries
      # @raise [TimeoutError] when the API times out after exhausting retries
      # @raise [ApiError] when the API returns an unexpected error
      def self.perform(bounding_box, query)
        query_string     = resolve_query(query)
        op_bbox          = Underpass::QL::BoundingBox.from_geometry(bounding_box)
        request          = Underpass::QL::Request.new(query_string, op_bbox)
        execute(request, query_string)
      end

      # Queries the Overpass API within a named area (e.g. "Romania").
      #
      # @param area_name [String] an OSM area name
      # @param query [String, Builder] an Overpass QL query string or a {Builder} instance
      # @return [Array<Feature>] the matched features
      # @raise [RateLimitError] when rate limited after exhausting retries
      # @raise [TimeoutError] when the API times out after exhausting retries
      # @raise [ApiError] when the API returns an unexpected error
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
