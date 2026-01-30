# frozen_string_literal: true

require 'spec_helper'
require 'underpass'
require 'json'

describe Underpass::GeoJSON do
  let(:factory) { RGeo::Geographic.spherical_factory(srid: 4326) }

  let(:features) do
    [
      Underpass::Feature.new(
        geometry: factory.point(1.0, 2.0),
        properties: { name: 'Test Point' },
        id: 42,
        type: 'node'
      ),
      Underpass::Feature.new(
        geometry: factory.line_string([factory.point(0.0, 0.0), factory.point(1.0, 1.0)]),
        properties: { highway: 'primary' },
        id: 99,
        type: 'way'
      )
    ]
  end

  describe '.encode' do
    it 'returns a FeatureCollection hash' do
      result = described_class.encode(features)

      expect(result['type']).to eq('FeatureCollection')
      expect(result['features'].size).to eq(2)
    end

    it 'encodes geometry and properties for each feature', :aggregate_failures do
      result = described_class.encode(features)
      first = result['features'][0]

      expect(first['type']).to eq('Feature')
      expect(first['geometry']['type']).to eq('Point')
      expect(first['properties']['name']).to eq('Test Point')
      expect(first['id']).to eq(42)
    end

    it 'handles empty feature arrays' do
      result = described_class.encode([])

      expect(result['type']).to eq('FeatureCollection')
      expect(result['features']).to eq([])
    end
  end
end
