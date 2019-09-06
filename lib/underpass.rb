# frozen_string_literal: true

require 'rgeo'
require 'json'

require 'underpass/client'
require 'underpass/matcher'
require 'underpass/shape'
require 'underpass/ql/bounding_box'
require 'underpass/ql/query'
require 'underpass/ql/request'
require 'underpass/ql/response'

# Underpass is a library that makes it easy to query the Overpass API
# and translate its responses into RGeo objects
module Underpass
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
