# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Cache do
  subject { described_class.new(ttl: 60) }

  describe '#store and #fetch' do
    it 'returns the stored value' do
      subject.store('key1', 'value1')
      expect(subject.fetch('key1')).to eq('value1')
    end

    it 'returns nil for a missing key' do
      expect(subject.fetch('missing')).to be_nil
    end

    it 'returns nil after TTL expires' do
      cache = described_class.new(ttl: 0)
      cache.store('key1', 'value1')
      sleep(0.01)
      expect(cache.fetch('key1')).to be_nil
    end
  end

  describe '#clear' do
    it 'removes all cached entries' do
      subject.store('key1', 'value1')
      subject.clear
      expect(subject.fetch('key1')).to be_nil
    end
  end

  describe 'integration with Client' do
    let(:request_double) { double }
    let(:expected_query) { 'cached_query_test' }
    let(:default_endpoint) { 'https://overpass-api.de/api/interpreter' }

    before do
      allow(request_double).to receive(:to_query).and_return(expected_query)
    end

    after do
      Underpass.cache = nil
      Underpass.reset_configuration!
    end

    context 'with caching enabled' do
      before { Underpass.cache = described_class.new(ttl: 300) }

      it 'returns cached response on second call without hitting API' do
        stub = stub_request(:post, default_endpoint)
               .with(body: { data: expected_query })
               .to_return(status: 200, body: '{"elements":[]}')

        Underpass::Client.perform(request_double)
        Underpass::Client.perform(request_double)

        expect(stub).to have_been_requested.once
      end
    end

    context 'with caching disabled' do
      it 'hits the API on every call' do
        stub = stub_request(:post, default_endpoint)
               .with(body: { data: expected_query })
               .to_return(status: 200, body: '{"elements":[]}')

        Underpass::Client.perform(request_double)
        Underpass::Client.perform(request_double)

        expect(stub).to have_been_requested.twice
      end
    end
  end
end
