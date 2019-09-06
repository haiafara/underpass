# underpass

## More usage examples

The following lets you see the flow of the library.
You can inspect the objects returned at each step for more information.

```ruby
# require the library if it's not autoloaded
require 'underpass'

# create a bounding box in which the query will be run
f = RGeo::Geographic.spherical_factory
bbox = f.parse_wkt('POLYGON ((23.557 47.602, 23.557 47.722, 23.837 47.722, 23.837 47.602, 23.557 47.602))')

# we won't use the Underpass::QL::Query convenience class
op_bbox      = Underpass::QL::BoundingBox.from_geometry(bounding_box)
request      = Underpass::QL::Request.new(query, op_bbox)
api_response = Underpass::Client.perform(request)
response     = Underpass::QL::Response.new(api_response)
matcher      = Underpass::Matcher.new(response)

matcher.matches
```
