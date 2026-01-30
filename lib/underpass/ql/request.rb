# frozen_string_literal: true

module Underpass
  module QL
    # Prepares the Overpass query
    class Request
      QUERY_TEMPLATE = <<-TEMPLATE
        [out:json][timeout:TIMEOUT]BBOX;
        (
          QUERY
        );
        out body;
        RECURSE
        out skel qt;
      TEMPLATE

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

      def initialize(query, bbox = nil, recurse: '>', area_name: nil)
        @overpass_query = query
        @global_bbox = bbox ? "[#{bbox}]" : ''
        @recurse = recurse
        @area_name = area_name
      end

      # Converts the object to a query string
      # to be used in the next step (Client.perform)
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
