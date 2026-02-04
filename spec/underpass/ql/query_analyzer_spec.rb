# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::QueryAnalyzer do
  describe '#requested_types' do
    context 'when query is empty or nil' do
      it 'returns all match types for nil query' do
        analyzer = described_class.new(nil)
        expect(analyzer.requested_types).to eq(%w[node way relation])
      end

      it 'returns all match types for empty query' do
        analyzer = described_class.new('')
        expect(analyzer.requested_types).to eq(%w[node way relation])
      end

      it 'returns all match types for whitespace-only query' do
        analyzer = described_class.new('   ')
        expect(analyzer.requested_types).to eq(%w[node way relation])
      end
    end

    context 'when query contains single type' do
      it 'returns node for node query' do
        analyzer = described_class.new('node["amenity"="restaurant"];')
        expect(analyzer.requested_types).to eq(%w[node])
      end

      it 'returns way for way query' do
        analyzer = described_class.new('way["highway"="primary"];')
        expect(analyzer.requested_types).to eq(%w[way])
      end

      it 'returns relation for relation query' do
        analyzer = described_class.new('relation["type"="multipolygon"];')
        expect(analyzer.requested_types).to eq(%w[relation])
      end
    end

    context 'when query contains multiple types' do
      it 'returns multiple types from semicolon-separated lines' do
        query = 'node["amenity"="restaurant"]; way["highway"="primary"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to contain_exactly('node', 'way')
      end

      it 'returns unique types only' do
        query = 'node["amenity"="restaurant"]; node["amenity"="cafe"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to eq(%w[node])
      end

      it 'returns all three types when present' do
        query = 'node["amenity"]; way["highway"]; relation["type"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to contain_exactly('node', 'way', 'relation')
      end
    end

    context 'when query contains unrecognized types' do
      it 'returns all types for unrecognized first word' do
        analyzer = described_class.new('invalid["tag"];')
        expect(analyzer.requested_types).to eq(%w[node way relation])
      end

      it 'returns recognized types and ignores unrecognized ones' do
        query = 'node["amenity"]; invalid["tag"]; way["highway"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to contain_exactly('node', 'way')
      end
    end

    context 'when query has extra whitespace' do
      it 'handles leading and trailing whitespace' do
        analyzer = described_class.new('  node["amenity"]  ;  ')
        expect(analyzer.requested_types).to eq(%w[node])
      end

      it 'handles multiple spaces in query' do
        analyzer = described_class.new('node    ["amenity"="restaurant"];')
        expect(analyzer.requested_types).to eq(%w[node])
      end
    end

    context 'with real-world query examples' do
      it 'parses heritage query' do
        query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to eq(%w[way])
      end

      it 'parses relation name query' do
        query = 'relation["name"="Árok"];'
        analyzer = described_class.new(query)
        expect(analyzer.requested_types).to eq(%w[relation])
      end
    end
  end
end
