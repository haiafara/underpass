# underpass

## More usage examples

### Step by step flow

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

# Define the Overpass QL query
op_query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'

# We won't use the Underpass::QL::Query convenience class
# Note that we pass the wkt directly to the from_wkt method
op_bbox      = Underpass::QL::BoundingBox.from_wkt(wkt)
request      = Underpass::QL::Request.new(op_query, op_bbox)
api_response = Underpass::Client.perform(request)
response     = Underpass::QL::Response.new(api_response)
matcher      = Underpass::Matcher.new(response)

# We'll have our matches in
matcher.matches
```

### Relations

```ruby
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
```

### Tools

* [Bounding Box](http://tools.geofabrik.de/calc/#type=geofabrik_standard)
