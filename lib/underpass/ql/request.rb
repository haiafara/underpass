# frozen_string_literal: true

module Underpass
  module QL
    # Prepares the Overpass query
    class Request
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

      # Converts the object to a query string
      # to be used in the next step (Client.perform)
      def to_query
        QUERY_TEMPLATE.sub('BBOX', @global_bbox)
                      .sub('QUERY', @overpass_query)
      end
    end
  end
end
