# frozen_string_literal: true

module Underpass
  module QL
    # Parses the JSON body of an Overpass API response into
    # node, way, and relation lookup hashes keyed by element ID.
    class Response
      # Creates a new response by parsing the API response body.
      #
      # @param api_response [Net::HTTPResponse] the raw HTTP response
      def initialize(api_response)
        parsed_json = JSON.parse(api_response.body, symbolize_names: true)
        @elements = parsed_json[:elements]
      end

      # Returns all node elements as a hash keyed by ID.
      #
      # @return [Hash{Integer => Hash}] node elements
      def nodes
        mapped_hash('node')
      end

      # Returns all way elements as a hash keyed by ID.
      #
      # @return [Hash{Integer => Hash}] way elements
      def ways
        mapped_hash('way')
      end

      # Returns all relation elements as a hash keyed by ID.
      #
      # @return [Hash{Integer => Hash}] relation elements
      def relations
        mapped_hash('relation')
      end

      private

      def mapped_hash(type)
        mapped_elements = elements_of_type(type).map do |element|
          [element[:id], element]
        end
        mapped_elements.to_h
      end

      def elements_of_type(type)
        @elements.select { |e| e[:type] == type }
      end
    end
  end
end
