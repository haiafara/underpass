# frozen_string_literal: true

module Underpass
  # Provides matches given a response object
  # By matches we understand response elements that have a tags key
  class Matcher
    attr_reader :matches

    def initialize(response)
      @nodes   = response.nodes
      @ways    = response.ways
      @matches = []

      @nodes.each_value do |node|
        @matches << point_from_node(node) if node.key?(:tags)
      end

      @ways.each_value do |way|
        @matches << way_matches(way) if way.key?(:tags)
      end
    end

    private

    def way_matches(way)
      if open_way?(way)
        polygon_from_way(way, @nodes)
      else
        line_string_from_way(way, @nodes)
      end
    end

    def open_way?(way)
      Underpass::Shape.open_way?(way)
    end

    def point_from_node(node)
      Underpass::Shape.point_from_node(node)
    end

    def polygon_from_way(way, nodes)
      Underpass::Shape.polygon_from_way(way, nodes)
    end

    def line_string_from_way(way, nodes)
      Underpass::Shape.line_string_from_way(way, nodes)
    end
  end
end
