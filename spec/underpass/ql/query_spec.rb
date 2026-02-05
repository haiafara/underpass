# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

# aka the integration spec
describe Underpass::QL::Query do
  subject { described_class }

  let(:bbox) { double }

  # bounding box is irelevant since it's only used on Overpass
  before do
    allow(Underpass::QL::BoundingBox).to receive(:from_geometry)
  end

  describe '#perform_raw' do
    before do
      stub_request(:post, 'https://overpass-api.de/api/interpreter')
        .to_return(
          body: File.read('spec/support/files/response-node.json'),
          status: 200
        )
    end

    it 'executes a pre-built query body with inline bbox', :aggregate_failures do
      query_body = 'node["name"="Peak"]["natural"="peak"](47.0,25.0,47.1,25.1);'
      results = subject.perform_raw(query_body)
      expect(results.size).to eq(1)
      expect(results.first).to be_a(Underpass::Feature)
      expect(results.first.geometry).to be_a(RGeo::Geographic::SphericalPointImpl)
    end

    it 'sends the query wrapped in the standard Request template' do
      query_body = 'node["name"="Peak"](47.0,25.0,47.1,25.1);'
      subject.perform_raw(query_body)

      expect(WebMock).to(have_requested(:post, 'https://overpass-api.de/api/interpreter')
        .with { |req| req.body.include?('out+body') && req.body.include?('out+skel+qt') })
    end

    it 'creates a Request with nil bbox (no global bounding box)' do
      query_body = 'node["name"="Peak"](47.0,25.0,47.1,25.1);'
      expect(Underpass::QL::Request).to receive(:new).with(query_body, nil).and_call_original
      subject.perform_raw(query_body)
    end

    it 'passes the query body directly without resolve_query' do
      query_body = 'node["name"="Peak"](47.0,25.0,47.1,25.1);'
      expect(subject).not_to receive(:resolve_query)
      subject.perform_raw(query_body)
    end
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

      it 'returns Feature objects with correct geometry', :aggregate_failures do
        op_query = 'way["something"];'
        results = subject.perform(bbox, op_query)
        expect(results.size).to eq(1)
        expect(results.first).to be_a(Underpass::Feature)
        expect(results.first.geometry.class).to eq(
          RGeo::Geographic::SphericalPolygonImpl
        )
        expect(results.first.geometry.as_text).to eq(
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

      it 'returns Feature objects with correct geometry', :aggregate_failures do
        op_query = 'way["something"];'
        results = subject.perform(bbox, op_query)
        expect(results.size).to eq(1)
        expect(results.first).to be_a(Underpass::Feature)
        expect(results.first.geometry.class).to eq(
          RGeo::Geographic::SphericalLineStringImpl
        )
        expect(results.first.geometry.as_text).to eq(
          'LINESTRING (1.0 -1.0, 1.0 1.0, -1.0 1.0, -1.0 -1.0)'
        )
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

      it 'returns Feature objects with correct geometry', :aggregate_failures do
        op_query = 'node["something"];'
        results = subject.perform(bbox, op_query)
        expect(results.size).to eq(1)
        expect(results.first).to be_a(Underpass::Feature)
        expect(results.first.geometry.class).to eq(
          RGeo::Geographic::SphericalPointImpl
        )
        expect(results.first.geometry.as_text).to eq(
          'POINT (1.0 -1.0)'
        )
      end
    end
  end
end
