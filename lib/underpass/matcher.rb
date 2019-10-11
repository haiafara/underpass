# frozen_string_literal: true

module Underpass
  # Provides matches given a response object
  # By matches we understand response elements that have a tags key
  class Matcher
    def initialize(response)
      @nodes     = response.nodes
      @ways      = response.ways
      @relations = response.relations
      @matches   = nil
    end

    def matches
      unless @matches
        @matches = []
        add_node_matches
        add_way_matches
        add_relation_matches
      end
      @matches
    end

    private

    def add_node_matches
      @nodes.each_value do |node|
        @matches << Shape.point_from_node(node) if node.key?(:tags)
      end
    end

    def add_way_matches
      @ways.each_value do |way|
        @matches << way_match(way) if way.key?(:tags)
      end
    end

    def add_relation_matches
      @relations.each_value do |relation|
        @matches.push(*relation_match(relation)) if relation.key?(:tags)
      end
    end

    def relation_match(relation)
      matches = []
      relation[:members].each do |member|
        case member[:type]
        when 'node'
          matches << Shape.point_from_node(@nodes[member[:ref]])
        when 'way'
          matches << way_match(@ways[member[:ref]])
        end
      end
      matches
    end

    def way_match(way)
      if Shape.open_way?(way)
        Shape.polygon_from_way(way, @nodes)
      else
        Shape.line_string_from_way(way, @nodes)
      end
    end
  end
end
