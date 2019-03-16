# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

# aka the integration spec
describe Underpass::QL::Query do
  subject { described_class }

  describe '#perform' do
    before do
      stub_request(:post, 'https://overpass-api.de/api/interpreter').
        to_return(body: File.read('spec/support/files/response.json'), status: 200)
    end
    it 'does what it has to' do
      f = RGeo::Geographic.spherical_factory
      bbox = f.parse_wkt('POLYGON ((-1 1, 1 1, 1 -1, -1 -1, -1 1))')
      op_query = 'way["something"];'
      results = subject.perform(bbox, op_query)
      expect(results.size).to eq(1)
      expect(results.first.class).to eq(RGeo::Geographic::SphericalPolygonImpl)
      expect(results.first.as_text).to eq('POLYGON ((1.0 -1.0, 1.0 1.0, -1.0 1.0, -1.0 -1.0, 1.0 -1.0))')
    end
  end
end
