# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Request do
  let(:query) { 'query test' }
  let(:bbox) { 'bbox test' }

  subject { described_class.new(query, bbox) }

  describe '#initialize' do
    it 'sets the correct instance variables' do
      expect(
        subject.instance_variable_get(:@overpass_query)
      ).to eq(query)
      expect(
        subject.instance_variable_get(:@global_bbox)
      ).to eq('[' + bbox + ']')
    end
  end

  describe '#to_query' do
    it 'replaces query and bbox in the QUERY_TEMPLATE' do
      expect(subject.to_query).to include(query)
      expect(subject.to_query).to include(bbox)
    end
  end
end
