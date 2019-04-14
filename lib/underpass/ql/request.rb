# frozen_string_literal: true

module Underpass
  module QL
    # Deals with performing the Overpass API request
    class Request
      API_URI = 'https://overpass-api.de/api/interpreter'
      QUERY_TEMPLATE = <<-TEMPLATE
        [out:json][timeout:25]BBOX;
        (
          QUERY
        );
        out body;
        >;
        out skel qt;
      TEMPLATE

      def initialize(query, bbox)
        @overpass_query = query
        @global_bbox ||= "[#{bbox}]"
      end

      # Performs the API request
      def run
        Net::HTTP.post_form(URI(API_URI), data: build_query)
      end

      private

      def build_query
        QUERY_TEMPLATE.sub('BBOX', @global_bbox)
                      .sub('QUERY', @overpass_query)
      end
    end
  end
end
