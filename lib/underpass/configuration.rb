# frozen_string_literal: true

module Underpass
  # Stores configuration options for the Underpass library
  class Configuration
    attr_accessor :api_endpoint, :timeout

    def initialize
      @api_endpoint = 'https://overpass-api.de/api/interpreter'
      @timeout = 25
    end
  end
end
