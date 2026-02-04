# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Filter do
  let(:factory) { RGeo::Geographic.spherical_factory(srid: 4326) }
  let(:geometry) { factory.point(1.0, 2.0) }

  let(:features) do
    [
      Underpass::Feature.new(geometry: geometry, properties: { amenity: 'restaurant', cuisine: 'italian' }),
      Underpass::Feature.new(geometry: geometry, properties: { amenity: 'restaurant', cuisine: 'chinese' }),
      Underpass::Feature.new(geometry: geometry, properties: { amenity: 'cafe', cuisine: 'coffee' }),
      Underpass::Feature.new(geometry: geometry, properties: { amenity: 'bank' })
    ]
  end

  describe '#where' do
    it 'filters by exact tag match' do
      result = described_class.new(features).where(amenity: 'restaurant')
      expect(result.size).to eq(2)
    end

    it 'filters by regex match' do
      result = described_class.new(features).where(cuisine: /ital/i)
      expect(result.size).to eq(1)
    end

    it 'filters by array of values' do
      result = described_class.new(features).where(amenity: %w[restaurant cafe])
      expect(result.size).to eq(3)
    end

    it 'filters by multiple conditions (AND)' do
      result = described_class.new(features).where(amenity: 'restaurant', cuisine: 'chinese')
      expect(result.size).to eq(1)
    end

    it 'returns empty array when no matches' do
      result = described_class.new(features).where(amenity: 'hospital')
      expect(result).to be_empty
    end
  end

  describe '#reject' do
    it 'rejects features matching the condition' do
      result = described_class.new(features).reject(amenity: 'bank')
      expect(result.size).to eq(3)
    end
  end
end
