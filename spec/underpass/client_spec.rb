# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Client do
  subject { described_class }

  let(:request_double) { double }
  let(:expected_query) { 'query_test bbox_test' }
  let(:default_endpoint) { 'https://overpass-api.de/api/interpreter' }

  before do
    allow(request_double).to receive(:to_query).and_return(expected_query)
  end

  after { Underpass.reset_configuration! }

  describe '#perform' do
    it 'posts the query to the default API endpoint' do
      stub = stub_request(:post, default_endpoint)
             .with(body: { data: expected_query })
             .to_return(status: 200, body: '{}')

      subject.perform(request_double)
      expect(stub).to have_been_requested
    end

    it 'posts the query to a custom API endpoint' do
      custom_endpoint = 'https://custom-overpass.example.com/api/interpreter'
      Underpass.configure { |c| c.api_endpoint = custom_endpoint }

      stub = stub_request(:post, custom_endpoint)
             .with(body: { data: expected_query })
             .to_return(status: 200, body: '{}')

      subject.perform(request_double)
      expect(stub).to have_been_requested
    end

    context 'when the API returns a 429 rate limit response' do
      it 'retries and raises RateLimitError after max retries' do
        stub_request(:post, default_endpoint)
          .to_return(status: 429, body: 'Rate limited')

        allow(subject).to receive(:sleep)

        expect { subject.perform(request_double, max_retries: 1) }
          .to raise_error(Underpass::RateLimitError, /after 1 retries/)
      end

      it 'succeeds after a retry' do
        stub_request(:post, default_endpoint)
          .to_return(status: 429, body: 'Rate limited')
          .then.to_return(status: 200, body: '{}')

        allow(subject).to receive(:sleep)

        response = subject.perform(request_double)
        expect(response.code.to_i).to eq(200)
      end
    end

    context 'when the API returns a 504 timeout response' do
      it 'retries and raises TimeoutError after max retries' do
        stub_request(:post, default_endpoint)
          .to_return(status: 504, body: 'Gateway Timeout')

        allow(subject).to receive(:sleep)

        expect { subject.perform(request_double, max_retries: 1) }
          .to raise_error(Underpass::TimeoutError, /after 1 retries/)
      end
    end

    context 'when the API returns an unexpected error' do
      it 'raises ApiError immediately without retrying' do
        stub_request(:post, default_endpoint)
          .to_return(status: 500, body: 'Internal Server Error')

        expect { subject.perform(request_double) }
          .to raise_error(Underpass::ApiError, /Overpass API returned 500/)
      end
    end
  end
end
