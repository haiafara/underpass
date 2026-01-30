# frozen_string_literal: true

module Underpass
  module QL
    # DSL for building Overpass QL queries programmatically
    class Builder
      def initialize
        @statements = []
        @around = nil
      end

      def node(tags = {})
        @statements << build_statement('node', tags)
        self
      end

      def way(tags = {})
        @statements << build_statement('way', tags)
        self
      end

      def relation(tags = {})
        @statements << build_statement('relation', tags)
        self
      end

      def nwr(tags = {})
        @statements << build_statement('nwr', tags)
        self
      end

      def around(radius, lat_or_point, lon = nil)
        @around = if lat_or_point.respond_to?(:y)
                    { radius: radius, lat: lat_or_point.y, lon: lat_or_point.x }
                  else
                    { radius: radius, lat: lat_or_point, lon: lon }
                  end
        self
      end

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
