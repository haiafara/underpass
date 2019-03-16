# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'underpass'

describe Underpass::QL::Shape do
  subject { described_class }

  let(:nodes) { NodesAndWays::NODES }

  describe '#polygon_from_way' do
    let(:way) { NodesAndWays::POLYGON_WAY }
    it 'converts a way and its nodes to a polygon' do
      polygon = Underpass::QL::Shape.polygon_from_way(way, nodes)
      expect(polygon.class).to eq(RGeo::Geographic::SphericalPolygonImpl)
      expect(polygon.as_text).to eq('POLYGON ((1.0 -1.0, 1.0 1.0, -1.0 1.0, 1.0 -1.0))')
    end
  end

  describe '#line_string_from_way' do
    let(:way) { NodesAndWays::LINE_STRING_WAY }
    it 'converts a way and its nodes to a linestring' do
      line_string = Underpass::QL::Shape.line_string_from_way(way, nodes)
      expect(line_string.class).to eq(RGeo::Geographic::SphericalLineStringImpl)
      expect(line_string.as_text).to eq('LINESTRING (1.0 -1.0, 1.0 1.0, -1.0 1.0)')
    end
  end
end
