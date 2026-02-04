# frozen_string_literal: true

module Underpass
  module QL
    # Analyzes an Overpass QL query string to determine which element types
    # (node, way, relation) are requested.
    #
    # Used internally by {Query} to pass type hints to {Matcher}.
    class QueryAnalyzer
      # @return [Array<String>] the recognized OSM element types
      MATCH_TYPES = %w[node way relation].freeze

      # Creates a new analyzer for the given query string.
      #
      # @param query [String, nil] an Overpass QL query string
      def initialize(query)
        @query = query
      end

      # Returns the element types requested in the query.
      #
      # Falls back to all types when the query is empty or contains
      # no recognized type keywords.
      #
      # @return [Array<String>] requested types (e.g. +["node", "way"]+)
      def requested_types
        return MATCH_TYPES if empty_query?

        types = parse_types_from_query
        types.empty? ? MATCH_TYPES : types
      end

      private

      def empty_query?
        @query.nil? || @query.strip.empty?
      end

      def parse_types_from_query
        lines = @query.strip.split(';').map(&:strip).reject(&:empty?)
        lines.map { |line| first_word(line) }
             .select { |word| MATCH_TYPES.include?(word) }
             .uniq
      end

      def first_word(line)
        line.split(/[\[\s]+/).first
      end
    end
  end
end
