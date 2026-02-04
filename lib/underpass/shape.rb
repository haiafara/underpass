# frozen_string_literal: true

module Underpass
  # Converts OSM element data into RGeo geometry objects.
  #
  # All methods operate on the parsed response hashes produced by
  # {QL::Response} and return RGeo geometries built with a WGS 84
  # spherical factory.
  class Shape
    class << self
      # Checks whether a way forms a closed ring (first node equals last node).
      #
      # @param way [Hash] a parsed way element
      # @return [Boolean] +true+ if the way is closed
      def open_way?(way)
        way[:nodes].first == way[:nodes].last
      end

      # Builds an RGeo polygon from a closed way.
      #
      # @param way [Hash] a parsed way element
      # @param nodes [Hash{Integer => Hash}] node lookup table
      # @return [RGeo::Feature::Polygon] the polygon geometry
      def polygon_from_way(way, nodes)
        factory.polygon(line_string_from_way(way, nodes))
      end

      # Builds an RGeo line string from a way's node references.
      #
      # @param way [Hash] a parsed way element
      # @param nodes [Hash{Integer => Hash}] node lookup table
      # @return [RGeo::Feature::LineString] the line string geometry
      def line_string_from_way(way, nodes)
        factory.line_string(points_from_node_ids(way[:nodes], nodes))
      end

      # Builds an RGeo point from a node element.
      #
      # @param node [Hash] a parsed node element with +:lon+ and +:lat+ keys
      # @return [RGeo::Feature::Point] the point geometry
      def point_from_node(node)
        factory.point(node[:lon], node[:lat])
      end

      # Assembles a multipolygon from a relation with outer and inner members.
      #
      # @param relation [Hash] a parsed relation element
      # @param ways [Hash{Integer => Hash}] way lookup table
      # @param nodes [Hash{Integer => Hash}] node lookup table
      # @return [RGeo::Feature::Polygon, RGeo::Feature::MultiPolygon] a polygon
      #   if only one outer ring, otherwise a multi-polygon
      def multipolygon_from_relation(relation, ways, nodes)
        outer_rings = build_rings(members_by_role(relation, 'outer'), ways, nodes)
        inner_rings = build_rings(members_by_role(relation, 'inner'), ways, nodes)

        polygons = outer_rings.map do |outer_ring|
          factory.polygon(outer_ring, matching_inner_rings(outer_ring, inner_rings))
        end

        return polygons.first if polygons.size == 1

        factory.multi_polygon(polygons)
      end

      # Assembles a multi-line-string from a route relation's way members.
      #
      # @param relation [Hash] a parsed relation element
      # @param ways [Hash{Integer => Hash}] way lookup table
      # @param nodes [Hash{Integer => Hash}] node lookup table
      # @return [RGeo::Feature::MultiLineString] the multi-line-string geometry
      def multi_line_string_from_relation(relation, ways, nodes)
        way_members = relation[:members].select { |m| m[:type] == 'way' }
        line_strings = way_members.filter_map do |member|
          way = ways[member[:ref]]
          next unless way

          line_string_from_way(way, nodes)
        end

        factory.multi_line_string(line_strings)
      end

      # Returns the shared RGeo spherical factory (SRID 4326).
      #
      # @return [RGeo::Geographic::SphericalFactory] the factory instance
      def factory
        @factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
      end

      private

      def points_from_node_ids(node_ids, nodes)
        node_ids.map { |n| factory.point(nodes[n][:lon], nodes[n][:lat]) }
      end

      def members_by_role(relation, role)
        relation[:members]
          .select { |m| m[:type] == 'way' && m[:role] == role }
          .map { |m| m[:ref] }
      end

      def build_rings(way_ids, ways, nodes)
        return [] if way_ids.empty?

        sequences = WayChain.new(way_ids, ways).merged_sequences
        sequences.map { |ids| factory.linear_ring(points_from_node_ids(ids, nodes)) }
      end

      def matching_inner_rings(outer_ring, inner_rings)
        outer_polygon = factory.polygon(outer_ring)
        inner_rings.select do |inner_ring|
          point = inner_ring.points.first
          outer_polygon.contains?(factory.point(point.x, point.y))
        end
      end
    end
  end
end
