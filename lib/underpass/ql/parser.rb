# frozen_string_literal: true

module Underpass
  module QL
    # Deals with parsing the API request response into easily digestable objects
    # which are then returned as matches
    class Parser
      def initialize(response)
        @response = response
        @matches = []
      end

      def parse
        parsed_json = JSON.parse(@response.body, symbolize_names: true)
        elements = parsed_json[:elements]

        @nodes = extract_indexed_nodes(elements)
        @ways = extract_indexed_ways(elements)

        self
      end

      def matches
        @nodes.each_value do |node|
          @matches << point_from_node(node) if node.key?(:tags)
        end

        @ways.each_value do |way|
          @matches << polygon_from_way(way, @nodes) if way.key?(:tags)
        end

        @matches
      end

      private

      def point_from_node(node)
        Underpass::QL::Shape.point_from_node(node)
      end

      def polygon_from_way(way, nodes)
        Underpass::QL::Shape.polygon_from_way(way, nodes)
      end

      def extract_indexed_nodes(elements)
        nodes = elements.select { |e| e[:type] == 'node' }
        nodes.map { |e| [e[:id], e] }.to_h
      end

      def extract_indexed_ways(elements)
        ways = elements.select { |e| e[:type] == 'way' }
        ways.map { |e| [e[:id], e] }.to_h
      end
    end
  end
end
