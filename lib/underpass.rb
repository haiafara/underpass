# frozen_string_literal: true

require 'rgeo'
require 'json'

require 'underpass/cache'
require 'underpass/configuration'
require 'underpass/errors'
require 'underpass/client'
require 'underpass/feature'
require 'underpass/filter'
require 'underpass/geo_json'
require 'underpass/matcher'
require 'underpass/shape'
require 'underpass/way_chain'
require 'underpass/ql/bounding_box'
require 'underpass/ql/builder'
require 'underpass/ql/query'
require 'underpass/ql/query_analyzer'
require 'underpass/ql/request'
require 'underpass/ql/response'

# Underpass is a library that makes it easy to query the Overpass API
# and translate its responses into RGeo objects.
#
# @example Quick start
#   wkt = 'POLYGON ((23.669 47.65, 23.725 47.65, 23.725 47.674, 23.669 47.674, 23.669 47.65))'
#   bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)
#   query = 'way["heritage:operator"="lmi"];'
#   features = Underpass::QL::Query.perform(bbox, query)
#
# @example Configure the API endpoint
#   Underpass.configure do |config|
#     config.api_endpoint = 'https://overpass.kumi.systems/api/interpreter'
#     config.timeout = 30
#   end
module Underpass
  class << self
    # @return [Cache, nil] the cache instance used for storing API responses
    attr_accessor :cache

    # @return [Configuration] the current configuration
    attr_writer :configuration

    # Returns the current configuration, initializing a default one if needed.
    #
    # @return [Configuration] the current configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the current configuration for modification.
    #
    # @yield [config] the current configuration
    # @yieldparam config [Configuration] the configuration instance
    # @return [void]
    #
    # @example
    #   Underpass.configure do |config|
    #     config.api_endpoint = 'https://overpass.kumi.systems/api/interpreter'
    #     config.timeout = 30
    #   end
    def configure
      yield(configuration)
    end

    # Resets the configuration to default values.
    #
    # @return [Configuration] a new default configuration
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
