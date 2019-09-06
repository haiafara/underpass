# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Client do
  let(:request_double) { double }
  let(:query) { 'query_test' }
  let(:bbox) { 'bbox_test' }
  subject { described_class }
  describe '#perform' do
    it 'posts the query to the API endpoint' do
      allow(request_double).to receive(:to_query).and_return(
        query + ' ' + bbox
      )
      stub = stub_request(:post, 'https://overpass-api.de/api/interpreter')
             .with(body: /#{bbox}/)
      subject.perform(request_double)
      expect(stub).to have_been_requested
    end
  end
end
