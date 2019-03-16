# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Request do
  subject { described_class }
  let(:instance) { subject.new('query_test', 'bbox_test')}

  describe '#initialize' do
    it 'sets the correct instance variables' do
      expect(instance.instance_variable_get(:@overpass_query)).to eq('query_test')
      expect(instance.instance_variable_get(:@global_bbox)).to eq('[bbox_test]')
    end
  end

  describe '#run' do
    it 'posts the query to the API endpoint' do
      stub = stub_request(:post, 'https://overpass-api.de/api/interpreter')
             .with(body: /query_test/)
             .with(body: /bbox_test/)
      instance.run
      expect(stub).to have_been_requested
    end
  end
end
