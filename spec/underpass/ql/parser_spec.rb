# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Parser do
  subject { described_class }
  let(:response_double) { double }
  let(:instance) { subject.new(response_double) }

  describe '#initialize' do
    it 'sets the correct instance variables' do
      expect(instance.instance_variable_get(:@response)).to eq(response_double)
      expect(instance.instance_variable_get(:@matches)).to eq([])
    end
  end

  describe '#parse' do
    before do
      allow(response_double).to receive(:body)
    end
    it 'calls JSON.parse and the extractor methods and returns the instance' do
      expect(JSON).to receive(:parse).once.and_return({ elements: 'test' })
      expect(instance).to receive(:extract_indexed_nodes).once
      expect(instance).to receive(:extract_indexed_ways).once
      expect(instance.parse).to eq(instance)
    end
  end

  describe '#matches' do
    before do
      instance.instance_variable_set(:@ways, {a: 1, b: 2})
    end
    it 'calls polygon from way and returns matches' do
      expect(Underpass::QL::Shape).to receive(:polygon_from_way).twice.and_return('test')
      expect(instance.matches.size).to eq(2)
    end
  end
end
