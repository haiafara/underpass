# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Client do
  subject { described_class }

  let(:request_double) { double }
  let(:query) { 'query_test' }
  let(:bbox) { 'bbox_test' }

  describe '#perform' do
    it 'posts the query to the API endpoint' do
      expected_query = "#{query} #{bbox}"
      allow(request_double).to receive(:to_query).and_return(expected_query)

      stub = stub_request(:post, 'https://overpass-api.de/api/interpreter')
             .with(body: { data: expected_query })

      subject.perform(request_double)
      expect(stub).to have_been_requested
    end
  end
end
