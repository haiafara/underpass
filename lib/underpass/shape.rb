# frozen_string_literal: true

module Underpass
  # Helper methods to convert shapes to RGeo
  class Shape
    class << self
      def open_way?(way)
        way[:nodes].first == way[:nodes].last
      end

      def polygon_from_way(way, nodes)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.polygon(line_string_from_way(way, nodes))
      end

      def line_string_from_way(way, nodes)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.line_string(
          way[:nodes].map do |n|
            f.point(nodes[n][:lon], nodes[n][:lat])
          end
        )
      end

      def point_from_node(node)
        f = RGeo::Geographic.spherical_factory(srid: 4326)
        f.point(node[:lon], node[:lat])
      end

      # There should be some sort of 'decorator' to return an object
      # with the shape and a copy of the tags as
      # Bonus: try to make it RGeo::GeoJSON.encode compatible
      # {
      #   tags: way[:tags],
      #   shape: shape
      # }
    end
  end
end
