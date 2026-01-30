# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'support/relations'
require 'underpass'

describe Underpass::Matcher do
  subject { described_class.new(response_double) }

  let(:response_double) { double }

  before do
    allow(response_double).to receive_messages(nodes: nodes, ways: ways, relations: relations)
  end

  describe '#matches' do
    context 'there are nodes with tags' do
      let(:nodes) do
        {
          a: { id: 1, type: 'node', lat: 1, lon: -1, tags: { name: 'A' } },
          b: { id: 2, type: 'node', lat: 2, lon: -2, tags: { name: 'B' } },
          c: {}
        }
      end
      let(:ways) { {} }
      let(:relations) { {} }

      it 'returns Feature objects wrapping point geometries', :aggregate_failures do
        matches = subject.matches
        expect(matches.size).to eq(2)
        expect(matches).to all(be_a(Underpass::Feature))
        expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalPointImpl)
        expect(matches.first.properties).to eq({ name: 'A' })
        expect(matches.first.id).to eq(1)
      end
    end

    context 'there are ways with tags' do
      let(:nodes) { NodesAndWays::NODES }
      let(:relations) { {} }

      context 'ways are polygons' do
        let(:ways) do
          {
            a: { id: 10, type: 'way', nodes: [1, 2, 3, 1], tags: { building: 'yes' } }
          }
        end

        it 'returns Feature objects wrapping polygon geometries', :aggregate_failures do
          matches = subject.matches
          expect(matches.size).to eq(1)
          expect(matches.first).to be_a(Underpass::Feature)
          expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalPolygonImpl)
          expect(matches.first.properties).to eq({ building: 'yes' })
        end
      end

      context 'ways are line strings' do
        let(:ways) do
          {
            a: { id: 11, type: 'way', nodes: [1, 2, 3], tags: { highway: 'primary' } }
          }
        end

        it 'returns Feature objects wrapping line string geometries' do
          matches = subject.matches
          expect(matches.size).to eq(1)
          expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalLineStringImpl)
          expect(matches.first.properties).to eq({ highway: 'primary' })
        end
      end
    end

    context 'there are relations with tags' do
      let(:nodes) do
        {
          1 => { type: 'node', lat: 1, lon: -1 },
          2 => { type: 'node', lat: 2, lon: -2 }
        }
      end
      let(:ways) { {} }

      context 'relation members are nodes' do
        let(:relations) do
          {
            a: {
              id: 100,
              type: 'relation',
              members: [
                { type: 'node', ref: 1 },
                { type: 'node', ref: 2 }
              ],
              tags: { name: 'NodeRelation' }
            }
          }
        end

        it 'returns Feature objects for each member node', :aggregate_failures do
          matches = subject.matches
          expect(matches.size).to eq(2)
          expect(matches).to all(be_a(Underpass::Feature))
          expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalPointImpl)
          expect(matches.first.properties).to eq({ name: 'NodeRelation' })
        end
      end

      context 'relation is a multipolygon' do
        let(:nodes) { Relations::EXTENDED_NODES }
        let(:ways) { Relations::EXTENDED_WAYS }
        let(:relations) do
          { 1000 => Relations::MULTIPOLYGON_RELATION }
        end

        it 'returns a Feature wrapping a polygon geometry', :aggregate_failures do
          matches = subject.matches
          expect(matches.size).to eq(1)
          expect(matches.first).to be_a(Underpass::Feature)
          expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalPolygonImpl)
          expect(matches.first.properties[:name]).to eq('Test Multipolygon')
        end
      end

      context 'relation is a route' do
        let(:nodes) { Relations::EXTENDED_NODES }
        let(:ways) { Relations::EXTENDED_WAYS }
        let(:relations) do
          { 2000 => Relations::ROUTE_RELATION }
        end

        it 'returns a Feature wrapping a multi line string geometry', :aggregate_failures do
          matches = subject.matches
          expect(matches.size).to eq(1)
          expect(matches.first).to be_a(Underpass::Feature)
          expect(matches.first.geometry).to be_a(RGeo::Geographic::SphericalMultiLineStringImpl)
          expect(matches.first.properties[:name]).to eq('Test Route')
        end
      end
    end
  end

  describe '#lazy_matches' do
    let(:nodes) do
      {
        a: { id: 1, type: 'node', lat: 1, lon: -1, tags: { name: 'A' } },
        b: { id: 2, type: 'node', lat: 2, lon: -2, tags: { name: 'B' } },
        c: { id: 3, type: 'node', lat: 3, lon: -3, tags: { name: 'C' } }
      }
    end
    let(:ways) { {} }
    let(:relations) { {} }

    it 'returns a lazy enumerator' do
      expect(subject.lazy_matches).to be_a(Enumerator::Lazy)
    end

    it 'yields Feature objects' do
      results = subject.lazy_matches.to_a
      expect(results.size).to eq(3)
      expect(results).to all(be_a(Underpass::Feature))
    end

    it 'supports taking a subset' do
      results = subject.lazy_matches.first(2)
      expect(results.size).to eq(2)
    end
  end

  describe 'filtering by requested_types' do
    let(:nodes) do
      {
        a: { id: 1, type: 'node', lat: 1, lon: 1, tags: {} },
        b: { id: 2, type: 'node', lat: 2, lon: 2, tags: {} }
      }
    end
    let(:ways) do
      {
        a: { id: 10, type: 'way', nodes: [1, 2, 3], tags: {} }
      }
    end
    let(:relations) do
      {
        a: {
          id: 100,
          type: 'relation',
          members: [{ type: 'node', ref: 1 }],
          tags: {}
        }
      }
    end

    before do
      allow(Underpass::Shape).to receive_messages(
        point_from_node: double,
        line_string_from_way: double,
        open_way?: false
      )
    end

    context 'when only node type is requested' do
      subject { described_class.new(response_double, %w[node]) }

      it 'returns only node matches' do
        expect(subject.matches.size).to eq(2)
      end
    end

    context 'when only way type is requested' do
      subject { described_class.new(response_double, %w[way]) }

      it 'returns only way matches' do
        expect(subject.matches.size).to eq(1)
      end
    end

    context 'when only relation type is requested' do
      subject { described_class.new(response_double, %w[relation]) }

      it 'returns only relation matches' do
        expect(subject.matches.size).to eq(1)
      end
    end

    context 'when multiple types are requested' do
      subject { described_class.new(response_double, %w[node way]) }

      it 'returns matches for requested types only' do
        expect(subject.matches.size).to eq(3)
      end
    end
  end
end
