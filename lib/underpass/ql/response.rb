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
        nodes = @elements.select { |e| e[:type] == 'node' }
        nodes.map { |e| [e[:id], e] }.to_h
      end

      # Returns all way type elements from the response
      def ways
        ways = @elements.select { |e| e[:type] == 'way' }
        ways.map { |e| [e[:id], e] }.to_h
      end
    end
  end
end
