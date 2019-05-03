# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

# aka the integration spec
describe Underpass::QL::Query do
  subject { described_class }

  describe '#perform' do
    context 'when a polygon way is returned' do
      before do
        stub_request(:post, 'https://overpass-api.de/api/interpreter')
          .to_return(
            body: File.read('spec/support/files/response-way-polygon.json'),
            status: 200
          )
      end

      it 'does what it has to' do
        f = RGeo::Geographic.spherical_factory
        bbox = f.parse_wkt('POLYGON ((-1 1, 1 1, 1 -1, -1 -1, -1 1))')
        op_query = 'way["something"];'
        results = subject.perform(bbox, op_query)
        expect(results.size).to eq(1)
        expect(results.first.class).to eq(
          RGeo::Geographic::SphericalPolygonImpl
        )
        expect(results.first.as_text).to eq(
          'POLYGON ((1.0 -1.0, 1.0 1.0, -1.0 1.0, -1.0 -1.0, 1.0 -1.0))'
        )
      end
    end

    context 'when a line string way is returned' do
      before do
        stub_request(:post, 'https://overpass-api.de/api/interpreter')
          .to_return(
            body: File.read('spec/support/files/response-way-line-string.json'),
            status: 200
          )
      end

      it 'does what it has to' do
        f = RGeo::Geographic.spherical_factory
        bbox = f.parse_wkt('POLYGON ((-1 1, 1 1, 1 -1, -1 -1, -1 1))')
        op_query = 'way["something"];'
        results = subject.perform(bbox, op_query)
        expect(results.size).to eq(1)
        expect(results.first.class).to eq(
          RGeo::Geographic::SphericalLineStringImpl
        )
        expect(results.first.as_text).to eq(
          'LINESTRING (1.0 -1.0, 1.0 1.0, -1.0 1.0, -1.0 -1.0)'
        )
      end
    end
  end

  context 'when a node is returned' do
    before do
      stub_request(:post, 'https://overpass-api.de/api/interpreter')
        .to_return(
          body: File.read('spec/support/files/response-node.json'),
          status: 200
        )
    end

    it 'does what it has to' do
      f = RGeo::Geographic.spherical_factory
      bbox = f.parse_wkt('POLYGON ((-1 1, 1 1, 1 -1, -1 -1, -1 1))')
      op_query = 'node["something"];'
      results = subject.perform(bbox, op_query)
      expect(results.size).to eq(1)
      expect(results.first.class).to eq(
        RGeo::Geographic::SphericalPointImpl
      )
      expect(results.first.as_text).to eq(
        'POINT (1.0 -1.0)'
      )
    end
  end
end
