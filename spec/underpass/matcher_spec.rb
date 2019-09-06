# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'underpass'

describe Underpass::Matcher do
  let(:response_double) { double }

  before do
    allow(response_double).to receive(:nodes).and_return(nodes)
    allow(response_double).to receive(:ways).and_return(ways)
  end

  subject { described_class.new(response_double) }

  describe '#matches' do
    context 'there are nodes with tags' do
      let(:nodes) do
        {
          a: {},
          b: { tags: {} },
          c: { tags: {} }
        }
      end
      let(:ways) { {} }

      it 'calls point_from_node for nodes with tags and returns matches' do
        expect(Underpass::Shape).to receive(:point_from_node)
          .twice.and_return('test')
        expect(subject.matches.size).to eq(2)
      end
    end

    context 'there are ways with tags' do
      let(:nodes) { {} }

      context 'ways are polygons' do
        let(:ways) do
          {
            a: { nodes: [1, 2, 1], tags: {} },
            b: { nodes: [3, 4, 3], tags: {} },
            c: {}
          }
        end

        it 'calls polygon_from_way and returns matches' do
          expect(Underpass::Shape).to receive(:polygon_from_way)
            .twice.and_return('test')
          expect(subject.matches.size).to eq(2)
        end
      end

      context 'ways are line strings' do
        let(:ways) do
          {
            a: { nodes: [1, 2, 3], tags: {} },
            b: { nodes: [4, 5, 6], tags: {} },
            c: {}
          }
        end

        it 'calls line_string_from_way and returns matches' do
          expect(Underpass::Shape).to receive(:line_string_from_way)
            .twice.and_return('test')
          expect(subject.matches.size).to eq(2)
        end
      end
    end
  end
end
