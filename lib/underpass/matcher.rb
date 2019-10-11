# frozen_string_literal: true

module Underpass
  # Provides matches given a response object
  # By matches we understand response elements that have a tags key
  class Matcher
    def initialize(response)
      @nodes     = response.nodes
      @ways      = response.ways
      @relations = response.relations

      @matches   = []
    end

    def matches
      return @matches if @matches.any?

      @nodes.each_value do |node|
        @matches << point_from_node(node) if node.key?(:tags)
      end

      @ways.each_value do |way|
        @matches << way_match(way) if way.key?(:tags)
      end

      @relations.each_value do |relation|
        @matches.push(*relation_match(relation)) if relation.key?(:tags)
      end

      @matches
    end

    private

    def relation_match(relation)
      matches = []
      relation[:members].each do |member|
        ref = member[:ref]
        case member[:type]
        when 'node'
          matches << point_from_node(@nodes[ref])
        when 'way'
          matches << way_match(@ways[ref])
        end
      end
      matches
    end

    def way_match(way)
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
