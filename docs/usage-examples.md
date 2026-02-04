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
op_query = 'way["heritage:operator"="lmi"]["heritage"="2"];'

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

---

## Comprehensive Examples with Real Data

The following examples demonstrate various features of the library using real data from OpenStreetMap. These examples cover all return types and functionality.

### Example 1: Node Queries - Restaurants in Bucharest

Query for restaurants (nodes) in central Bucharest:

```ruby
require 'underpass'

# Define a bounding box for central Bucharest
wkt = <<-WKT
  POLYGON ((
    26.08 44.42,
    26.12 44.42,
    26.12 44.45,
    26.08 44.45,
    26.08 44.42
  ))
WKT

bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)

# Query for restaurants (nodes)
query = 'node["amenity"="restaurant"];'
features = Underpass::QL::Query.perform(bbox, query)

# Process results
features.each do |f|
  puts "#{f.properties[:name]} - #{f.properties[:cuisine]}"
  puts "  Geometry: #{f.geometry.geometry_type}"  # => Point
  puts "  Type: #{f.type}"                        # => node
  puts "  ID: #{f.id}"
end

# Sample output:
# Pizza Hut - pizza
#   Geometry: Point
#   Type: node
#   ID: 286859702
```

### Example 2: Way Queries - LineString (Roads)

Query for primary roads (ways - LineString geometries):

```ruby
require 'underpass'

# Using the same Bucharest bounding box
query = 'way["highway"="primary"];'
roads = Underpass::QL::Query.perform(bbox, query)

roads.each do |road|
  puts "#{road.properties[:name]}"
  puts "  Geometry: #{road.geometry.geometry_type}"  # => LineString
  puts "  Type: #{road.type}"                        # => way
end

# Sample output:
# Piața Unirii
#   Geometry: LineString
#   Type: way
```

### Example 3: Way Queries - Polygon (Buildings)

Query for buildings (ways - Polygon geometries):

```ruby
require 'underpass'

query = 'way["building"="yes"];'
buildings = Underpass::QL::Query.perform(bbox, query)

buildings.each do |building|
  puts "#{building.properties[:name]}"
  puts "  Geometry: #{building.geometry.geometry_type}"  # => Polygon
  puts "  Type: #{building.type}"                        # => way
end

# Sample output:
# Unirea Shopping Center
#   Geometry: Polygon
#   Type: way
```

### Example 4: Way Queries - Polygon (Parks)

Query for parks (ways - Polygon geometries):

```ruby
require 'underpass'

query = 'way["leisure"="park"];'
parks = Underpass::QL::Query.perform(bbox, query)

parks.each do |park|
  puts "#{park.properties[:name]}"
  puts "  Geometry: #{park.geometry.geometry_type}"  # => Polygon
  puts "  Type: #{park.type}"                        # => way
end

# Sample output:
# Parcul Cișmigiu
#   Geometry: Polygon
#   Type: way
```

### Example 5: Relation Queries - Multipolygon (Lakes)

Query for lakes as multipolygon relations in Romanian mountains:

```ruby
require 'underpass'

# Define a bounding box for Romanian mountain lakes area
wkt_mountains = <<-WKT
  POLYGON ((
    25.0 45.5,
    26.0 45.5,
    26.0 46.0,
    25.0 46.0,
    25.0 45.5
  ))
WKT

bbox_mountains = RGeo::Geographic.spherical_factory.parse_wkt(wkt_mountains)

# Query for lakes as multipolygon relations
query = 'relation["type"="multipolygon"]["water"="lake"];'
lakes = Underpass::QL::Query.perform(bbox_mountains, query)

lakes.each do |lake|
  puts "#{lake.properties[:name]}"
  puts "  Geometry: #{lake.geometry.geometry_type}"  # => Polygon or MultiPolygon
  puts "  Type: #{lake.type}"                        # => relation
end

# Sample output:
# Lacul Gémvári
#   Geometry: MultiPolygon
#   Type: relation
```

### Example 6: Relation Queries - MultiLineString (Routes)

Query for bus routes (relations - MultiLineString geometries):

```ruby
require 'underpass'

# Using the Bucharest bounding box
query = 'relation["type"="route"]["route"="bus"];'
routes = Underpass::QL::Query.perform(bbox, query)

routes.each do |route|
  puts "#{route.properties[:name]}"
  puts "  Geometry: #{route.geometry.geometry_type}"  # => MultiLineString
  puts "  Type: #{route.type}"                        # => relation
end

# Sample output:
# Bus 135: C.E.T. Sud Vitan → C.F.R. Constanța
#   Geometry: MultiLineString
#   Type: relation
```

### Example 7: Area Queries - Using perform_in_area

Query within a named area instead of a bounding box:

```ruby
require 'underpass'

# Query within a named area (note: no semicolon at end)
query = 'node["amenity"="cafe"]'
cafes = Underpass::QL::Query.perform_in_area('Bucharest', query)

cafes.each do |cafe|
  puts "#{cafe.properties[:name]}"
  puts "  Geometry: #{cafe.geometry.geometry_type}"  # => Point
  puts "  Type: #{cafe.type}"                        # => node
end
```

### Example 8: Around Queries - Proximity Search

Find elements within a radius of a point:

```ruby
require 'underpass'

# Define bounding box (using Bucharest area from Example 1)
bbox = RGeo::Geographic.spherical_factory.parse_wkt(<<-WKT
  POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))
WKT
)

# Find restaurants within 500m of University Square, Bucharest
lat = 44.4325
lon = 26.1025

query = Underpass::QL::Builder.new
           .node(amenity: 'restaurant')
           .around(500, lat, lon)
           .to_ql

restaurants_nearby = Underpass::QL::Query.perform(bbox, query)

restaurants_nearby.each do |restaurant|
  puts "#{restaurant.properties[:name]} - #{restaurant.properties[:cuisine]}"
  puts "  Geometry: #{restaurant.geometry.geometry_type}"  # => Point
  puts "  Type: #{restaurant.type}"                        # => node
end

# Sample output:
# Caru' cu Bere - balkan;grill;regional;steak_house
#   Geometry: Point
#   Type: node
```

### Example 9: Builder DSL - Multiple Types

Using the Builder DSL to query multiple element types:

```ruby
require 'underpass'

# Define bounding box (using Bucharest area from Example 1)
bbox = RGeo::Geographic.spherical_factory.parse_wkt(<<-WKT
  POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))
WKT
)

# Using Builder DSL to query multiple types
builder = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .way(amenity: 'restaurant')
          .relation(amenity: 'restaurant')

all_restaurants = Underpass::QL::Query.perform(bbox, builder)

all_restaurants.each do |restaurant|
  puts "#{restaurant.properties[:name]}"
  puts "  Geometry: #{restaurant.geometry.geometry_type}"  # Point, Polygon, or MultiPolygon
  puts "  Type: #{restaurant.type}"                        # node, way, or relation
end
```

### Example 10: Builder DSL - Multiple Tag Filters

Query with multiple tag filters:

```ruby
require 'underpass'

# Define bounding box (using Bucharest area from Example 1)
bbox = RGeo::Geographic.spherical_factory.parse_wkt(<<-WKT
  POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))
WKT
)

# Query with multiple tag filters
builder = Underpass::QL::Builder.new
          .way('heritage:operator': 'lmi', heritage: '2')

heritage = Underpass::QL::Query.perform(bbox, builder)

heritage.each do |building|
  puts "#{building.properties[:name]}"
  puts "  Geometry: #{building.geometry.geometry_type}"  # => Polygon
  puts "  Type: #{building.type}"                        # => way
end

# Sample output:
# Ateneul Român
#   Geometry: Polygon
#   Type: way
```

### Example 11: Filtering - Post-Query Filtering

Filter results by tag properties after querying:

```ruby
require 'underpass'

# Query all amenities
query = 'node["amenity"];'
amenities = Underpass::QL::Query.perform(bbox, query)

# Filter for restaurants only
restaurants = Underpass::Filter.new(amenities).where(amenity: 'restaurant')
puts "Restaurants: #{restaurants.size}"

# Filter for multiple amenity types (OR)
food_places = Underpass::Filter.new(amenities).where(amenity: %w[restaurant cafe bar])
puts "Food places: #{food_places.size}"

# Filter with regex
italian_places = Underpass::Filter.new(amenities).where(cuisine: /italian/i)
puts "Italian places: #{italian_places.size}"

# Reject banks
no_banks = Underpass::Filter.new(amenities).reject(amenity: 'bank')
puts "Non-bank amenities: #{no_banks.size}"
```

### Example 12: GeoJSON Export

Convert results to GeoJSON for use with web mapping libraries:

```ruby
require 'underpass'
require 'json'

# Query for restaurants
query = 'node["amenity"="restaurant"];'
restaurants = Underpass::QL::Query.perform(bbox, query)

# Convert to GeoJSON
geojson = Underpass::GeoJSON.encode(restaurants)

# Serialize to JSON file
File.write('restaurants.geojson', JSON.pretty_generate(geojson))

# GeoJSON structure:
# {
#   "type" => "FeatureCollection",
#   "features" => [
#     {
#       "type" => "Feature",
#       "geometry" => { "type" => "Point", "coordinates" => [26.1025, 44.4325] },
#       "properties" => { "name" => "Pizza Hut", "amenity" => "restaurant", "cuisine" => "pizza" },
#       "id" => 286859702
#     },
#     ...
#   ]
# }
```

### Example 13: Multiple Types in One Query

Query for nodes, ways, and relations in a single query:

```ruby
require 'underpass'

# Query for nodes, ways, and relations in one query
query = <<-QL
  node["amenity"="restaurant"];
  way["amenity"="restaurant"];
  relation["type"="route"];
QL

multi_results = Underpass::QL::Query.perform(bbox, query)

multi_results.each do |feature|
  puts "#{feature.properties[:name] || 'Unnamed'}"
  puts "  Geometry: #{feature.geometry.geometry_type}"
  puts "  Type: #{feature.type}"
end
```

### Example 14: NWR Shorthand

Using the `nwr` (node/way/relation) shorthand:

```ruby
require 'underpass'

# Define bounding box (using Bucharest area from Example 1)
bbox = RGeo::Geographic.spherical_factory.parse_wkt(<<-WKT
  POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))
WKT
)

# Using nwr (node/way/relation) shorthand
builder = Underpass::QL::Builder.new.nwr(name: 'Universitate')
results = Underpass::QL::Query.perform(bbox, builder)

results.each do |feature|
  puts "#{feature.properties[:name]}"
  puts "  Geometry: #{feature.geometry.geometry_type}"  # Point, LineString, or Polygon
  puts "  Type: #{feature.type}"                        # node, way, or relation
end

# Sample output:
# Universitate
#   Geometry: Point
#   Type: node
```

### Example 15: Around with RGeo Point

Using an RGeo point object for around queries:

```ruby
require 'underpass'

# Define bounding box (using Bucharest area from Example 1)
bbox = RGeo::Geographic.spherical_factory.parse_wkt(<<-WKT
  POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))
WKT
)

# Using RGeo point for around query
point = RGeo::Geographic.spherical_factory(srid: 4326).point(26.1025, 44.4325)

query = Underpass::QL::Builder.new
           .node(amenity: 'cafe')
           .around(300, point)
           .to_ql

cafes_nearby = Underpass::QL::Query.perform(bbox, query)

cafes_nearby.each do |cafe|
  puts "#{cafe.properties[:name]}"
  puts "  Geometry: #{cafe.geometry.geometry_type}"  # => Point
  puts "  Type: #{cafe.type}"                        # => node
end

# Sample output:
# Sfinx Espresso Bar
#   Geometry: Point
#   Type: node
```

### Example 16: Builder DSL with Bounding Box - Cafes

A complete, self-contained example showing how to use the Builder DSL to find all nodes tagged as a cafe within a specific bounding box:

```ruby
# Example 16: Builder DSL with Bounding Box - Cafes
require 'underpass'

# Step 1: Define a bounding box as a WKT polygon
wkt = <<-WKT
  POLYGON ((
    26.08 44.42,
    26.12 44.42,
    26.12 44.45,
    26.08 44.45,
    26.08 44.42
  ))
WKT
bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)

# Step 2: Use the Builder DSL to construct the query
builder = Underpass::QL::Builder.new
            .node(amenity: 'cafe')

# Step 3: Pass both bounding box and builder to Query.perform
cafes = Underpass::QL::Query.perform(bbox, builder)

# Step 4: Process results
cafes.each do |cafe|
  puts "#{cafe.properties[:name]}"
  puts "  Location: #{cafe.geometry.as_text}"
  puts "  Type: #{cafe.type}"  # => "node"
end
```

### Summary of Return Types

| Example | Geometry Type | Element Type | Description |
|---------|---------------|--------------|-------------|
| 1 | Point | node | Restaurants |
| 2 | LineString | way | Primary roads |
| 3 | Polygon | way | Buildings |
| 4 | Polygon | way | Parks |
| 5 | Polygon/MultiPolygon | relation | Lakes (multipolygon) |
| 6 | MultiLineString | relation | Bus routes |
| 7 | Point | node | Cafes (area query) |
| 8 | Point | node | Restaurants (around query) |
| 9 | Point/Polygon/MultiPolygon | node/way/relation | All restaurants |
| 10 | Polygon | way | Heritage buildings |
| 11 | Point | node | Filtered amenities |
| 12 | Point/Polygon/etc. | node/way/relation | GeoJSON export |
| 13 | Point/Polygon/MultiLineString | node/way/relation | Multiple types |
| 14 | Point/LineString/Polygon | node/way/relation | NWR shorthand |
| 15 | Point | node | Cafes (around with RGeo) |
| 16 | Point | node | Cafes (Builder DSL + bounding box) |
