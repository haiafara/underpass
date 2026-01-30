# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Feature do
  let(:factory) { RGeo::Geographic.spherical_factory(srid: 4326) }
  let(:geometry) { factory.point(1.0, 2.0) }
  let(:properties) { { name: 'Test', amenity: 'restaurant' } }

  describe '#initialize' do
    it 'stores geometry, properties, id, and type', :aggregate_failures do
      feature = described_class.new(
        geometry: geometry,
        properties: properties,
        id: 42,
        type: 'node'
      )

      expect(feature.geometry).to eq(geometry)
      expect(feature.properties).to eq(properties)
      expect(feature.id).to eq(42)
      expect(feature.type).to eq('node')
    end

    it 'defaults properties to empty hash' do
      feature = described_class.new(geometry: geometry)

      expect(feature.properties).to eq({})
      expect(feature.id).to be_nil
      expect(feature.type).to be_nil
    end
  end
end
