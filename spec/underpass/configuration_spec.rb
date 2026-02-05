# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::Configuration do
  describe '#api_endpoint' do
    it 'defaults to the public Overpass API' do
      config = described_class.new
      expect(config.api_endpoint).to eq('https://overpass-api.de/api/interpreter')
    end
  end

  describe '#timeout' do
    it 'defaults to 25' do
      config = described_class.new
      expect(config.timeout).to eq(25)
    end
  end

  describe '#max_retries' do
    it 'defaults to 3' do
      config = described_class.new
      expect(config.max_retries).to eq(3)
    end
  end

  describe 'Underpass.configure' do
    after { Underpass.reset_configuration! }

    it 'allows setting a custom API endpoint' do
      Underpass.configure do |c|
        c.api_endpoint = 'https://custom-overpass.example.com/api/interpreter'
      end

      expect(Underpass.configuration.api_endpoint)
        .to eq('https://custom-overpass.example.com/api/interpreter')
    end

    it 'allows setting a custom timeout' do
      Underpass.configure do |c|
        c.timeout = 60
      end

      expect(Underpass.configuration.timeout).to eq(60)
    end

    it 'allows setting custom max_retries' do
      Underpass.configure do |c|
        c.max_retries = 5
      end

      expect(Underpass.configuration.max_retries).to eq(5)
    end
  end

  describe 'Underpass.reset_configuration!' do
    it 'resets to defaults' do
      Underpass.configure { |c| c.api_endpoint = 'https://custom.example.com' }
      Underpass.reset_configuration!

      expect(Underpass.configuration.api_endpoint)
        .to eq('https://overpass-api.de/api/interpreter')
    end
  end
end
