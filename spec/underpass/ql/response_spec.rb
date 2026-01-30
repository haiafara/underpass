# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'underpass'

describe Underpass::QL::Response do
  subject { described_class.new(response_double) }

  let(:response_double) { double }
  let(:elements) { 'test elements' }

  before do
    allow(response_double).to receive(:body).and_return('test')
  end

  describe '#nodes' do
    let(:nodes_and_ways) { NodesAndWays::NODES_AND_WAYS }

    it 'returns a hash of nodes indexed by id' do
      allow(JSON).to receive(:parse).and_return(elements: nodes_and_ways)
      result = subject.nodes
      expect(result.size).to eq(4)
      expect(result[5]).to eq(
        type: 'node',
        id: 5,
        lat: -1,
        lon: -1
      )
    end
  end

  describe '#ways' do
    let(:nodes_and_ways) { NodesAndWays::NODES_AND_WAYS }

    it 'returns a hash of ways indexed by id' do
      allow(JSON).to receive(:parse).and_return(elements: nodes_and_ways)
      result = subject.ways
      expect(result.size).to eq(1)
      expect(result[1]).to eq(
        type: 'way',
        id: 1,
        nodes: [2, 3, 4, 5],
        tags: {
          amenity: 'something',
          building: 'yes',
          name: 'Test'
        }
      )
    end
  end
end
