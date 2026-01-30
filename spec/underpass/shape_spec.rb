# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'support/relations'
require 'underpass'

describe Underpass::Shape do
  let(:nodes) { NodesAndWays::NODES }

  describe '.open_way?' do
    subject { described_class.open_way?(way) }

    context 'way is a polygon' do
      let(:way) { NodesAndWays::POLYGON_WAY }

      it 'returns true' do
        expect(subject).to be(true)
      end
    end

    context 'way is a line string' do
      let(:way) { NodesAndWays::LINE_STRING_WAY }

      it 'returns true' do
        expect(subject).to be(false)
      end
    end
  end

  describe '#polygon_from_way' do
    let(:way) { NodesAndWays::POLYGON_WAY }

    it 'converts a way and its nodes to a polygon' do
      polygon = described_class.polygon_from_way(way, nodes)
      expect(polygon.class).to eq(
        RGeo::Geographic::SphericalPolygonImpl
      )
      expect(polygon.as_text).to eq(
        'POLYGON ((1.0 -1.0, 1.0 1.0, -1.0 1.0, 1.0 -1.0))'
      )
    end
  end

  describe '#line_string_from_way' do
    let(:way) { NodesAndWays::LINE_STRING_WAY }

    it 'converts a way and its nodes to a linestring' do
      line_string = described_class.line_string_from_way(way, nodes)
      expect(line_string.class).to eq(
        RGeo::Geographic::SphericalLineStringImpl
      )
      expect(line_string.as_text).to eq(
        'LINESTRING (1.0 -1.0, 1.0 1.0, -1.0 1.0)'
      )
    end
  end

  describe '#point_from_node' do
    let(:node) { NodesAndWays::NODE }

    it 'converts a node to a point' do
      point = described_class.point_from_node(node)
      expect(point.class).to eq(
        RGeo::Geographic::SphericalPointImpl
      )
      expect(point.as_text).to eq(
        'POINT (-1.0 1.0)'
      )
    end
  end

  describe '.multipolygon_from_relation' do
    let(:ext_nodes) { Relations::EXTENDED_NODES }
    let(:ext_ways) { Relations::EXTENDED_WAYS }

    context 'with a single outer and one inner ring' do
      let(:relation) { Relations::MULTIPOLYGON_RELATION }

      it 'returns a polygon with a hole' do
        result = described_class.multipolygon_from_relation(relation, ext_ways, ext_nodes)
        expect(result).to be_a(RGeo::Geographic::SphericalPolygonImpl)
        expect(result.exterior_ring.num_points).to eq(5)
        expect(result.interior_rings.size).to eq(1)
      end
    end

    context 'with multiple outer rings' do
      let(:relation) { Relations::MULTI_OUTER_RELATION }

      it 'returns a multi polygon' do
        result = described_class.multipolygon_from_relation(relation, ext_ways, ext_nodes)
        expect(result).to be_a(RGeo::Geographic::SphericalMultiPolygonImpl)
        expect(result.num_geometries).to eq(2)
      end
    end
  end

  describe '.multi_line_string_from_relation' do
    let(:ext_nodes) { Relations::EXTENDED_NODES }
    let(:ext_ways) { Relations::EXTENDED_WAYS }
    let(:relation) { Relations::ROUTE_RELATION }

    it 'returns a multi line string from route members' do
      result = described_class.multi_line_string_from_relation(relation, ext_ways, ext_nodes)
      expect(result).to be_a(RGeo::Geographic::SphericalMultiLineStringImpl)
      expect(result.num_geometries).to eq(2)
    end
  end
end
