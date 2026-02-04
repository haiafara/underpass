# frozen_string_literal: true

module Underpass
  module QL
    # DSL for building Overpass QL queries programmatically.
    #
    # @example Query for restaurants
    #   builder = Underpass::QL::Builder.new
    #   builder.node('amenity' => 'restaurant')
    #   Underpass::QL::Query.perform(bbox, builder)
    #
    # @example Proximity search with around
    #   builder = Underpass::QL::Builder.new
    #   builder.node('amenity' => 'cafe').around(500, 44.4268, 26.1025)
    class Builder
      # Creates a new empty builder.
      def initialize
        @statements = []
        @around = nil
      end

      # Adds a node query statement.
      #
      # @param tags [Hash{String => String}] tag filters
      # @return [self] for method chaining
      def node(tags = {})
        @statements << build_statement('node', tags)
        self
      end

      # Adds a way query statement.
      #
      # @param tags [Hash{String => String}] tag filters
      # @return [self] for method chaining
      def way(tags = {})
        @statements << build_statement('way', tags)
        self
      end

      # Adds a relation query statement.
      #
      # @param tags [Hash{String => String}] tag filters
      # @return [self] for method chaining
      def relation(tags = {})
        @statements << build_statement('relation', tags)
        self
      end

      # Adds a node/way/relation (nwr) query statement.
      #
      # @param tags [Hash{String => String}] tag filters
      # @return [self] for method chaining
      def nwr(tags = {})
        @statements << build_statement('nwr', tags)
        self
      end

      # Sets a proximity filter for all statements.
      #
      # @param radius [Numeric] search radius in meters
      # @param lat_or_point [Numeric, RGeo::Feature::Point] latitude or an RGeo point
      # @param lon [Numeric, nil] longitude (required when +lat_or_point+ is numeric)
      # @return [self] for method chaining
      def around(radius, lat_or_point, lon = nil)
        @around = if lat_or_point.respond_to?(:y)
                    { radius: radius, lat: lat_or_point.y, lon: lat_or_point.x }
                  else
                    { radius: radius, lat: lat_or_point, lon: lon }
                  end
        self
      end

      # Converts the builder into an Overpass QL query string.
      #
      # @return [String] the Overpass QL query
      def to_ql
        if @around
          @statements.map { |s| append_around(s) }.join("\n")
        else
          @statements.join("\n")
        end
      end

      private

      def build_statement(type, tags)
        tag_filters = tags.map { |k, v| "[\"#{k}\"=\"#{v}\"]" }.join
        "#{type}#{tag_filters};"
      end

      def append_around(statement)
        around_filter = "(around:#{@around[:radius]},#{@around[:lat]},#{@around[:lon]})"
        statement.sub(';', "#{around_filter};")
      end
    end
  end
end
