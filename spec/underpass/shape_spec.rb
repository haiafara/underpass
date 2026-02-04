# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
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
end
