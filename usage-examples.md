# underpass

## More usage examples

```ruby
# require the library if it's not autoloaded
require 'underpass'
# create a bounding box in which the query will be run
f = RGeo::Geographic.spherical_factory
bbox = f.parse_wkt('POLYGON ((23.557 47.602, 23.557 47.722, 23.837 47.722, 23.837 47.602, 23.557 47.602))')
# we won't use the Underpass::QL::Query shortcut
op_bbox = Underpass::QL::BoundingBox.from_geometry(bbox)
op_query = 'node[name="Borcut Baia Sprie"][natural="spring"];'
response = Underpass::QL::Request.new(op_query, op_bbox).run
matches = Underpass::QL::Parser.new(response).parse.matches
```
