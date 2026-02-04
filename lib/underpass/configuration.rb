# frozen_string_literal: true

module Underpass
  # Stores configuration options for the Underpass library.
  #
  # @example
  #   Underpass.configure do |config|
  #     config.api_endpoint = 'https://overpass.kumi.systems/api/interpreter'
  #     config.timeout = 30
  #   end
  class Configuration
    # @return [String] the Overpass API endpoint URL
    attr_accessor :api_endpoint

    # @return [Integer] the query timeout in seconds
    attr_accessor :timeout

    def initialize
      @api_endpoint = 'https://overpass-api.de/api/interpreter'
      @timeout = 25
    end
  end
end
