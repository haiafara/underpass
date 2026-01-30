# frozen_string_literal: true

module Underpass
  # Helper methods to convert shapes to RGeo
  class Shape
    class << self
      def open_way?(way)
        way[:nodes].first == way[:nodes].last
      end

      def polygon_from_way(way, nodes)
        factory.polygon(line_string_from_way(way, nodes))
      end

      def line_string_from_way(way, nodes)
        factory.line_string(points_from_node_ids(way[:nodes], nodes))
      end

      def point_from_node(node)
        factory.point(node[:lon], node[:lat])
      end

      def multipolygon_from_relation(relation, ways, nodes)
        outer_rings = build_rings(members_by_role(relation, 'outer'), ways, nodes)
        inner_rings = build_rings(members_by_role(relation, 'inner'), ways, nodes)

        polygons = outer_rings.map do |outer_ring|
          factory.polygon(outer_ring, matching_inner_rings(outer_ring, inner_rings))
        end

        return polygons.first if polygons.size == 1

        factory.multi_polygon(polygons)
      end

      def multi_line_string_from_relation(relation, ways, nodes)
        way_members = relation[:members].select { |m| m[:type] == 'way' }
        line_strings = way_members.filter_map do |member|
          way = ways[member[:ref]]
          next unless way

          line_string_from_way(way, nodes)
        end

        factory.multi_line_string(line_strings)
      end

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
