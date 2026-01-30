# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::QL::Builder do
  describe '#to_ql' do
    it 'builds a node query with tags' do
      ql = described_class.new.node(amenity: 'restaurant').to_ql
      expect(ql).to eq('node["amenity"="restaurant"];')
    end

    it 'builds a way query with tags' do
      ql = described_class.new.way(highway: 'primary').to_ql
      expect(ql).to eq('way["highway"="primary"];')
    end

    it 'builds a relation query with tags' do
      ql = described_class.new.relation(type: 'multipolygon').to_ql
      expect(ql).to eq('relation["type"="multipolygon"];')
    end

    it 'builds an nwr query with tags' do
      ql = described_class.new.nwr(name: 'Test').to_ql
      expect(ql).to eq('nwr["name"="Test"];')
    end

    it 'builds a query with multiple tag filters' do
      ql = described_class.new
                          .way('heritage:operator': 'lmi', 'ref:ro:lmi': 'MM-II-m-B-04508')
                          .to_ql
      expect(ql).to eq('way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];')
    end

    it 'chains multiple statement types' do
      ql = described_class.new
                          .node(amenity: 'restaurant')
                          .way(highway: 'primary')
                          .to_ql
      expect(ql).to eq("node[\"amenity\"=\"restaurant\"];\nway[\"highway\"=\"primary\"];")
    end

    it 'builds a query with no tags' do
      ql = described_class.new.node.to_ql
      expect(ql).to eq('node;')
    end
  end

  describe '#around' do
    it 'appends around filter to statements with lat/lon' do
      ql = described_class.new
                          .node(amenity: 'restaurant')
                          .around(500, 47.65, 23.69)
                          .to_ql
      expect(ql).to eq('node["amenity"="restaurant"](around:500,47.65,23.69);')
    end

    it 'accepts an RGeo point object' do
      point = RGeo::Geographic.spherical_factory(srid: 4326).point(23.69, 47.65)
      ql = described_class.new
                          .node(amenity: 'restaurant')
                          .around(500, point)
                          .to_ql
      expect(ql).to eq('node["amenity"="restaurant"](around:500,47.65,23.69);')
    end

    it 'applies around filter to all statements' do
      ql = described_class.new
                          .node(amenity: 'restaurant')
                          .way(highway: 'primary')
                          .around(1000, 47.0, 23.0)
                          .to_ql
      lines = ql.split("\n")
      expect(lines[0]).to include('(around:1000,47.0,23.0)')
      expect(lines[1]).to include('(around:1000,47.0,23.0)')
    end
  end

  describe 'chainability' do
    it 'returns self from each method for chaining', :aggregate_failures do
      builder = described_class.new
      expect(builder.node).to eq(builder)
      expect(builder.way).to eq(builder)
      expect(builder.relation).to eq(builder)
      expect(builder.nwr).to eq(builder)
    end
  end
end
