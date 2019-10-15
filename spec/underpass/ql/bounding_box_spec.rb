# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::BoundingBox do
  let(:wkt) { 'POLYGON ((1.0 10.0, 2.0 10.0, 2.0 11.0, 1.0 11.00, 1.0 10.0))' }
  let(:bbox) { 'bbox:10.0,1.0,11.0,2.0' }

  subject { described_class }

  describe '#from_wkt' do
    it 'returns the correct bounding box string' do
      expect(subject.from_wkt(wkt)).to eq(bbox)
    end
  end

  describe '#from_geometry' do
    it 'returns the correct bounding box string' do
      geometry = RGeo::Geographic.spherical_factory.parse_wkt(wkt)
      expect(subject.from_geometry(geometry)).to eq(bbox)
    end
  end
end
