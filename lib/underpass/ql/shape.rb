# frozen_string_literal: true

module Underpass
  module QL
    # Contains factories for various RGeo shapes from ways and nodes parsed
    # with the Parser class
    class Shape
      def self.way_polygon?(way)
        way[:nodes].first == way[:nodes].last
      end

      def self.polygon_from_way(way, nodes)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.polygon(line_string_from_way(way, nodes))
      end

      def self.line_string_from_way(way, nodes)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.line_string(
          way[:nodes].map do |n|
            f.point(nodes[n][:lon], nodes[n][:lat])
          end
        )
      end

      def self.point_from_node(node)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.point(node[:lon], node[:lat])
      end

      # There should be some sort of 'decorator' to return an object
      # with the shape and a copy of the tags as
      # {
      #   tags: way[:tags],
      #   shape: shape
      # }
    end
  end
end
