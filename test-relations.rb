# frozen_string_literal: true

# Use me by doing:
# bundle console
# source './test-relatios.rb'

require 'underpass'
wkt = <<-WKT
  POLYGON ((
    23.65   47.65,
    23.6995 47.65,
    23.6995 47.71,
    23.65   47.71,
    23.65   47.65
  ))
WKT
op_query     = 'relation["name"="Árok"];'
op_bbox      = Underpass::QL::BoundingBox.from_wkt(wkt)
request      = Underpass::QL::Request.new(op_query, op_bbox)
api_response = Underpass::Client.perform(request)
response     = Underpass::QL::Response.new(api_response)
matcher      = Underpass::Matcher.new(response)
