# frozen_string_literal: true

module Underpass
  # Extracts matching elements from an Overpass API response.
  #
  # A "match" is a response element that has a +tags+ key, indicating it is
  # a tagged OSM element rather than a bare geometry node. Each match is
  # converted into a {Feature} with the appropriate RGeo geometry.
  class Matcher
    # Creates a new matcher for the given response.
    #
    # @param response [QL::Response] a parsed API response
    # @param requested_types [Array<String>, nil] element types to include
    #   (e.g. +["node", "way"]+). Defaults to all types when +nil+.
    def initialize(response, requested_types = nil)
      @nodes     = response.nodes
      @ways      = response.ways
      @relations = response.relations
      @requested_types = requested_types || %w[node way relation]
    end

    # Returns all matched features as an array.
    #
    # @return [Array<Feature>] the matched features
    def matches
      @matches ||= lazy_matches.to_a
    end

    # Returns a lazy enumerator of matched features.
    #
    # @return [Enumerator::Lazy<Feature>] lazy enumerator of features
    def lazy_matches
      tagged_elements.lazy.flat_map { |element| features_for(element) }
    end

    private

    def tagged_elements
      elements = []
      elements.concat(@nodes.values.select { |n| n.key?(:tags) }) if @requested_types.include?('node')
      elements.concat(@ways.values.select { |w| w.key?(:tags) }) if @requested_types.include?('way')
      elements.concat(@relations.values.select { |r| r.key?(:tags) }) if @requested_types.include?('relation')
      elements
    end

    def features_for(element)
      case element[:type]
      when 'node'
        [build_feature(Shape.point_from_node(element), element)]
      when 'way'
        [build_feature(way_geometry(element), element)]
      when 'relation'
        relation_features(element)
      else
        []
      end
    end

    def relation_features(relation)
      geometry = relation_geometry(relation)
      if geometry.is_a?(Array)
        geometry.map { |g| build_feature(g, relation) }
      else
        [build_feature(geometry, relation)]
      end
    end

    def relation_geometry(relation)
      case relation[:tags][:type]
      when 'multipolygon'
        Shape.multipolygon_from_relation(relation, @ways, @nodes)
      when 'route'
        Shape.multi_line_string_from_relation(relation, @ways, @nodes)
      else
        expand_relation_members(relation)
      end
    end

    def expand_relation_members(relation)
      relation[:members].filter_map do |member|
        case member[:type]
        when 'node' then Shape.point_from_node(@nodes[member[:ref]])
        when 'way' then way_geometry(@ways[member[:ref]])
        end
      end
    end

    def way_geometry(way)
      if Shape.open_way?(way)
        Shape.polygon_from_way(way, @nodes)
      else
        Shape.line_string_from_way(way, @nodes)
      end
    end

    def build_feature(geometry, element)
      Feature.new(
        geometry: geometry,
        properties: element[:tags] || {},
        id: element[:id],
        type: element[:type]
      )
    end
  end
end
