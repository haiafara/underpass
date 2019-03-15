# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Parser do
  subject { described_class }
  let(:instance) { subject.new('test123') }

  describe '#initialize' do
    it 'sets the correct instance variables' do
      parser = described_class.new('test123')
      expect(instance.instance_variable_get(:@response)).to eq('test123')
      expect(instance.instance_variable_get(:@matches)).to eq([])
    end
  end

  # describe '#parse' do
  #   it 'calls JSON.parse' do
  #     expect(JSON).to receive(:parse).once
  #     allow(double('response')).to receive(:body).and_return('test234')
  #     described_class.new('test123').parse
  #   end
  # end
end
