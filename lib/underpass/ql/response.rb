# frozen_string_literal: true

module Underpass
  module QL
    # Deals with parsing the API response into easily digestable
    # nodes and ways objects
    class Response
      def initialize(api_response)
        parsed_json = JSON.parse(api_response.body, symbolize_names: true)
        @elements = parsed_json[:elements]
      end

      # Returns all node type elements from the response
      def nodes
        mapped_hash('node')
      end

      # Returns all way type elements from the response
      def ways
        mapped_hash('way')
      end

      # Returns all relation type elements from the response
      def relations
        mapped_hash('relation')
      end

      private

      # Returns a hash of elements where the key is the element's id
      # This makes it easy to quickly access an element knowing its id
      def mapped_hash(type)
        mapped_elements = elements_of_type(type).map do |element|
          [element[:id], element]
        end
        mapped_elements.to_h
      end

      # Filters elements of a certain type (node, way, relation)
      def elements_of_type(type)
        @elements.select { |e| e[:type] == type }
      end
    end
  end
end
