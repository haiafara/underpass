# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Request do
  subject { described_class.new(query, bbox) }

  let(:query) { 'query test' }
  let(:bbox) { 'bbox test' }

  describe '#to_query' do
    it 'replaces query and bbox in the QUERY_TEMPLATE' do
      expect(subject.to_query).to include(query)
      expect(subject.to_query).to include(bbox)
    end

    it 'includes the default timeout from configuration' do
      expect(subject.to_query).to include('timeout:25')
    end

    it 'includes the default recurse operator' do
      expect(subject.to_query).to include('>;')
    end

    context 'with a custom recurse operator' do
      subject { described_class.new(query, bbox, recurse: '>>') }

      it 'uses the specified recurse operator' do
        expect(subject.to_query).to include('>>;')
      end
    end

    context 'with recurse disabled' do
      subject { described_class.new(query, bbox, recurse: nil) }

      it 'omits the recurse statement' do
        expect(subject.to_query).not_to include('>;')
        expect(subject.to_query).not_to include('>>;')
      end
    end

    context 'with area_name' do
      subject { described_class.new(query, nil, area_name: 'Romania') }

      it 'uses the area query template', :aggregate_failures do
        result = subject.to_query
        expect(result).to include('area["name"="Romania"]')
        expect(result).to include('(area.searchArea)')
        expect(result).to include(query)
        expect(result).not_to include('BBOX')
      end
    end
  end
end
