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
          .to raise_error(Underpass::RateLimitError)
      end

      it 'includes structured error data in RateLimitError' do
        stub_request(:post, default_endpoint)
          .to_return(status: 429, body: 'Rate limited')

        allow(subject).to receive(:sleep)

        begin
          subject.perform(request_double, max_retries: 1)
        rescue Underpass::RateLimitError => e
          expect(e.code).to eq('rate_limit')
          expect(e.http_status).to eq(429)
          expect(e.details).to eq({})
          expect(e.to_h).to include(code: 'rate_limit')
        end
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
          .to raise_error(Underpass::TimeoutError)
      end

      it 'includes structured error data in TimeoutError' do
        timeout_html = '<strong>runtime error: Query timed out in "query" at line 3 after 25 seconds.</strong>'
        stub_request(:post, default_endpoint)
          .to_return(status: 504, body: timeout_html)

        allow(subject).to receive(:sleep)

        begin
          subject.perform(request_double, max_retries: 1)
        rescue Underpass::TimeoutError => e
          expect(e.code).to eq('timeout')
          expect(e.http_status).to eq(504)
          expect(e.details).to eq({ line: 3, timeout_seconds: 25 })
          expect(e.error_message).to include('Query timed out')
          expect(e.to_h[:code]).to eq('timeout')
        end
      end
    end

    context 'when the API returns an unexpected error' do
      it 'raises ApiError immediately without retrying' do
        stub_request(:post, default_endpoint)
          .to_return(status: 500, body: 'Internal Server Error')

        expect { subject.perform(request_double) }
          .to raise_error(Underpass::ApiError)
      end

      it 'includes structured error data in ApiError' do
        error_html = '<strong>parse error: Unknown type "nod" on line 2</strong>'
        stub_request(:post, default_endpoint)
          .to_return(status: 400, body: error_html)

        begin
          subject.perform(request_double)
        rescue Underpass::ApiError => e
          expect(e.code).to eq('syntax')
          expect(e.http_status).to eq(400)
          expect(e.details).to eq({ line: 2 })
          expect(e.error_message).to include('Unknown type "nod"')
        end
      end

      it 'supports to_json for error serialization' do
        stub_request(:post, default_endpoint)
          .to_return(status: 500, body: '<strong>runtime error: Query failed</strong>')

        begin
          subject.perform(request_double)
        rescue Underpass::ApiError => e
          json = JSON.parse(e.to_json)
          expect(json['code']).to eq('runtime')
          expect(json['message']).to eq('Query failed')
        end
      end
    end
  end
end
