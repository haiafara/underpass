# frozen_string_literal: true

require 'spec_helper'
require 'support/nodes_and_ways'
require 'underpass'

describe Underpass::Matcher do
  subject { described_class.new(response_double) }

  let(:response_double) { double }

  before do
    allow(response_double).to receive_messages(nodes: nodes, ways: ways, relations: relations)
  end

  shared_examples 'calls Shape method and returns expected matches' do |method, count|
    it "calls #{method} and returns #{count} matches" do
      expect(Underpass::Shape).to receive(method).exactly(count).times.and_return('test')
      expect(subject.matches.size).to eq(count)
    end
  end

  shared_examples 'calls matcher method and returns expected matches' do |method, count|
    it "calls #{method} and returns #{count} matches" do
      expect(subject).to receive(method).exactly(count).times.and_return('test')
      expect(subject.matches.size).to eq(count)
    end
  end

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
      let(:relations) { {} }

      it_behaves_like 'calls Shape method and returns expected matches', :point_from_node, 2
    end

    context 'there are ways with tags' do
      let(:nodes) { {} }
      let(:relations) { {} }

      context 'ways are polygons' do
        let(:ways) do
          {
            a: { nodes: [1, 2, 1], tags: {} },
            b: { nodes: [3, 4, 3], tags: {} },
            c: {}
          }
        end

        it_behaves_like 'calls Shape method and returns expected matches', :polygon_from_way, 2
      end

      context 'ways are line strings' do
        let(:ways) do
          {
            a: { nodes: [1, 2, 3], tags: {} },
            b: { nodes: [4, 5, 6], tags: {} },
            c: {}
          }
        end

        it_behaves_like 'calls Shape method and returns expected matches', :line_string_from_way, 2
      end
    end

    context 'there are relations with tags' do
      let(:nodes) { {} }
      let(:ways) { {} }

      context 'relation members are nodes' do
        let(:relations) do
          {
            a: {
              members: [
                {
                  type: 'node'
                },
                {
                  type: 'node'
                }
              ],
              tags: {}
            }
          }
        end

        it_behaves_like 'calls Shape method and returns expected matches', :point_from_node, 2
      end

      context 'relation members are ways' do
        let(:relations) do
          {
            a: {
              members: [
                {
                  type: 'way'
                },
                {
                  type: 'way'
                }
              ],
              tags: {}
            }
          }
        end

        it_behaves_like 'calls matcher method and returns expected matches', :way_match, 2
      end
    end
  end

  describe 'filtering by requested_types' do
    let(:nodes) do
      {
        a: { tags: {} },
        b: { tags: {} }
      }
    end
    let(:ways) do
      {
        a: { nodes: [1, 2, 3], tags: {} },
        b: { nodes: [4, 5, 6], tags: {} }
      }
    end
    let(:relations) do
      {
        a: {
          members: [{ type: 'node' }],
          tags: {}
        }
      }
    end

    context 'when only node type is requested' do
      subject { described_class.new(response_double, %w[node]) }

      it 'returns only node matches' do
        expect(Underpass::Shape).to receive(:point_from_node).twice.and_return('test')
        expect(Underpass::Shape).not_to receive(:line_string_from_way)
        expect(subject.matches.size).to eq(2)
      end
    end

    context 'when only way type is requested' do
      subject { described_class.new(response_double, %w[way]) }

      it 'returns only way matches' do
        expect(Underpass::Shape).to receive(:line_string_from_way).twice.and_return('test')
        expect(Underpass::Shape).not_to receive(:point_from_node)
        expect(subject.matches.size).to eq(2)
      end
    end

    context 'when only relation type is requested' do
      subject { described_class.new(response_double, %w[relation]) }

      it 'returns only relation matches' do
        expect(Underpass::Shape).to receive(:point_from_node).once.and_return('test')
        expect(Underpass::Shape).not_to receive(:line_string_from_way)
        expect(subject.matches.size).to eq(1)
      end
    end

    context 'when multiple types are requested' do
      subject { described_class.new(response_double, %w[node way]) }

      it 'returns matches for requested types only' do
        expect(Underpass::Shape).to receive(:point_from_node).twice.and_return('test')
        expect(Underpass::Shape).to receive(:line_string_from_way).twice.and_return('test')
        expect(subject.matches.size).to eq(4)
      end
    end
  end
end
