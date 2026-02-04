# frozen_string_literal: true

module Underpass
  module QL
    # Prepares the full Overpass QL query string from a user query,
    # bounding box, and configuration options.
    #
    # Supports both bounding-box and named-area query templates.
    class Request
      # @api private
      QUERY_TEMPLATE = <<-TEMPLATE
        [out:json][timeout:TIMEOUT]BBOX;
        (
          QUERY
        );
        out body;
        RECURSE
        out skel qt;
      TEMPLATE

      # @api private
      AREA_QUERY_TEMPLATE = <<-TEMPLATE
        [out:json][timeout:TIMEOUT];
        area["name"="AREA_NAME"]->.searchArea;
        (
          QUERY(area.searchArea);
        );
        out body;
        RECURSE
        out skel qt;
      TEMPLATE

      # Creates a new request.
      #
      # @param query [String] the Overpass QL query body
      # @param bbox [String, nil] the bounding box string from {BoundingBox}
      # @param recurse [String, nil] the recurse operator (default: +">"+)
      # @param area_name [String, nil] an OSM area name for area-based queries
      def initialize(query, bbox = nil, recurse: '>', area_name: nil)
        @overpass_query = query
        @global_bbox = bbox ? "[#{bbox}]" : ''
        @recurse = recurse
        @area_name = area_name
      end

      # Converts the request into a complete Overpass QL query string.
      #
      # @return [String] the full query string ready for the API
      def to_query
        template = @area_name ? AREA_QUERY_TEMPLATE : QUERY_TEMPLATE
        timeout = Underpass.configuration.timeout.to_s

        result = template.sub('TIMEOUT', timeout)
        result = result.sub('AREA_NAME', @area_name) if @area_name
        result = result.sub('BBOX', @global_bbox) unless @area_name
        result.sub('QUERY', @overpass_query)
              .sub('RECURSE', recurse_statement)
      end

      private

      def recurse_statement
        return '' unless @recurse

        "#{@recurse};\n"
      end
    end
  end
end
