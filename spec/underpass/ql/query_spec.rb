# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

# aka the integration spec
describe Underpass::QL::Query do
  let(:bbox) { double }
  subject { described_class }

  # bounding box is irelevant since it's only used on Overpass
  before do
    allow(Underpass::QL::BoundingBox).to receive(:from_geometry)
  end

  describe '#perform' do
    context 'when a closed way is returned' do
      before do
        stub_request(:post, 'https://overpass-api.de/api/interpreter')
          .to_return(
            body: File.read('spec/support/files/response-way-polygon.json'),
            status: 200
          )
      end

      it 'returns the correct results' do
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

    context 'when an open way is returned' do
      before do
        stub_request(:post, 'https://overpass-api.de/api/interpreter')
          .to_return(
            body: File.read('spec/support/files/response-way-line-string.json'),
            status: 200
          )
      end

      it 'returns the correct results' do
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

    it 'returns the correct results' do
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
