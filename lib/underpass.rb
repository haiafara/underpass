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
# and translate its responses into RGeo objects
module Underpass
  class << self
    attr_accessor :cache
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

# Example usage
#
# require 'underpass'
# wkt = <<-WKT
#   POLYGON ((
#     23.669 47.65,
#     23.725 47.65,
#     23.725 47.674,
#     23.669 47.674,
#     23.669 47.65
#   ))
# WKT
# f = RGeo::Geographic.spherical_factory
# bbox = f.parse_wkt(wkt)
# op_query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'
# Underpass::QL::Query.perform(bbox, op_query)
