# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Request do
  subject { described_class.new(query, bbox) }

  let(:query) { 'query test' }
  let(:bbox) { 'bbox test' }

  describe '#to_query' do
    it 'replaces query and bbox in the QUERY_TEMPLATE' do
      expect(subject.to_query).to include(query)
      expect(subject.to_query).to include(bbox)
    end
  end
end
