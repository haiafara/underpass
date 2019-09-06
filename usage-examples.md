# underpass

## More usage examples

The following lets you see the flow of the library.
You can inspect the objects returned at each step for more information.

```ruby
# Require the library if it's not autoloaded
require 'underpass'

# Define a polygon to be used as bounding box
wkt = <<-WKT
  POLYGON ((
    23.669 47.65,
    23.725 47.65,
    23.725 47.674,
    23.669 47.674,
    23.669 47.65
  ))
WKT

# Create an RGeo bounding box in which the query will run
bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)

# Define the query (op = Overpass)
op_query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'

# We won't use the Underpass::QL::Query convenience class
op_bbox      = Underpass::QL::BoundingBox.from_geometry(bounding_box)
request      = Underpass::QL::Request.new(op_query, op_bbox)
api_response = Underpass::Client.perform(request)
response     = Underpass::QL::Response.new(api_response)
matcher      = Underpass::Matcher.new(response)

matcher.matches
```
