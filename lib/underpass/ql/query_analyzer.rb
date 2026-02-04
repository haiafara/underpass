# frozen_string_literal: true

module Underpass
  module QL
    # Analyzes a query string to determine which match types (node, way, relation)
    # are requested by the user
    class QueryAnalyzer
      MATCH_TYPES = %w[node way relation].freeze

      def initialize(query)
        @query = query
      end

      # Returns an array of requested match types based on the query
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
