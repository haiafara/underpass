# underpass

[![Gem Version](https://badge.fury.io/rb/underpass.svg)](https://badge.fury.io/rb/underpass)
[![Build Status](https://github.com/haiafara/underpass/workflows/Ruby%20Gem/badge.svg)](https://github.com/haiafara/underpass/actions?query=workflow%3A%22Ruby+Gem%22)
[![Coverage Status](https://coveralls.io/repos/github/haiafara/underpass/badge.svg?branch=master)](https://coveralls.io/github/haiafara/underpass?branch=master)

A library that makes it easy to query the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) and translate its responses into [RGeo](https://github.com/rgeo/rgeo) objects. It supports queries written in the [Overpass QL](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL).

## Installation

Install globally:

    gem install underpass

Or put it in your Gemfile:

    gem 'underpass'

## Quick Start

```ruby
require 'underpass'

# Define a bounding box polygon
wkt = <<-WKT
  POLYGON ((
    23.669 47.65,
    23.725 47.65,
    23.725 47.674,
    23.669 47.674,
    23.669 47.65
  ))
WKT
bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)

# Query using raw Overpass QL
query = 'way["heritage:operator"="lmi"]["heritage"="2"];'
features = Underpass::QL::Query.perform(bbox, query)

# Each result is a Feature with geometry and OSM tags
features.each do |f|
  puts f.geometry.as_text     # => "POLYGON ((...)"
  puts f.properties[:name]    # => "Biserica Romano-Catolică"
  puts f.id                   # => 186213580
  puts f.type                 # => "way"
end
```

See [more usage examples](docs/usage-examples.md).

For comprehensive examples with real data covering all return types and functionality, see the [usage-examples.md](docs/usage-examples.md) file which includes examples for:
- Node queries (Point geometries) - restaurants, cafes, etc.
- Way queries (LineString/Polygon geometries) - roads, buildings, parks
- Relation queries (MultiPolygon/MultiLineString geometries) - lakes, bus routes
- Area queries using `perform_in_area`
- Around queries for proximity search
- Builder DSL for constructing queries
- Post-query filtering
- GeoJSON export

## Feature Objects

All query results are returned as `Underpass::Feature` objects that pair an RGeo
geometry with OpenStreetMap metadata:

```ruby
feature.geometry   # RGeo geometry (Point, LineString, Polygon, Multi*)
feature.properties # Hash of OSM tags, e.g. { name: "...", amenity: "..." }
feature.id         # OSM element ID (Integer)
feature.type       # "node", "way", or "relation"
```

## Query Builder DSL

Instead of writing raw Overpass QL strings, you can use the chainable Ruby DSL:

```ruby
# Simple query
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .to_ql
# => 'node["amenity"="restaurant"];'

# Multiple types
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .way(highway: 'primary')
          .to_ql
# => "node[\"amenity\"=\"restaurant\"];\nway[\"highway\"=\"primary\"];"

# Multiple tag filters
query = Underpass::QL::Builder.new
          .way('heritage:operator': 'lmi', heritage: '2')
          .to_ql
# => 'way["heritage:operator"="lmi"]["heritage"="2"];'

# nwr (node/way/relation) shorthand
query = Underpass::QL::Builder.new
          .nwr(name: 'Central Park')
          .to_ql
# => 'nwr["name"="Central Park"];'

# Pass a Builder directly to Query.perform
builder = Underpass::QL::Builder.new.way(building: 'yes')
features = Underpass::QL::Query.perform(bbox, builder)
```

### Bounding Box Queries with Builder DSL

The Builder DSL is designed to work with `Query.perform`. Define a bounding box
as an RGeo geometry, build your query with the DSL, and pass both to `perform`:

```ruby
# Define a bounding box
wkt = 'POLYGON ((26.08 44.42, 26.12 44.42, 26.12 44.45, 26.08 44.45, 26.08 44.42))'
bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)

# Build the query
builder = Underpass::QL::Builder.new.node(amenity: 'cafe')

# Execute — the bounding box constrains results spatially
cafes = Underpass::QL::Query.perform(bbox, builder)
```

Note: The Builder DSL generates the Overpass QL query body (e.g. `node["amenity"="cafe"];`),
while the bounding box is applied as a separate spatial constraint by `Query.perform`.
You can inspect the generated query with `builder.to_ql`.

## Proximity Queries (Around)

Find elements within a radius (in meters) of a point:

```ruby
# Using coordinates
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .around(500, 47.65, 23.69)
          .to_ql
# => 'node["amenity"="restaurant"](around:500,47.65,23.69);'

# Using an RGeo point
point = RGeo::Geographic.spherical_factory(srid: 4326).point(23.69, 47.65)
query = Underpass::QL::Builder.new
          .node(amenity: 'cafe')
          .around(1000, point)
          .to_ql
```

The `around` filter is appended to all statements in the builder.

## Area Queries

Query within a named geographic area instead of a bounding box:

```ruby
features = Underpass::QL::Query.perform_in_area(
  'Romania',
  'node["amenity"="restaurant"];'
)
```

This generates an Overpass query using the `area` statement:

```
[out:json][timeout:25];
area["name"="Romania"]->.searchArea;
(
  node["amenity"="restaurant"](area.searchArea);
);
out body;
>;
out skel qt;
```

Builder objects work with `perform_in_area` as well:

```ruby
builder = Underpass::QL::Builder.new.node(amenity: 'restaurant')
features = Underpass::QL::Query.perform_in_area('Romania', builder)
```

## Relation Support

### Multipolygon Relations

Relations tagged `type=multipolygon` are automatically assembled into proper RGeo
polygons with holes. Outer member ways are chained into exterior rings, inner member
ways become interior rings (holes). Multiple outer rings produce a `MultiPolygon`.

```ruby
query = 'relation["type"="multipolygon"]["name"="Some Lake"];'
features = Underpass::QL::Query.perform(bbox, query)

feature = features.first
feature.geometry
# => RGeo::Geographic::SphericalPolygonImpl (with interior rings for islands)
```

### Route Relations

Relations tagged `type=route` (bus lines, hiking trails, etc.) are assembled into
`MultiLineString` geometries:

```ruby
query = 'relation["type"="route"]["name"="Bus 42"];'
features = Underpass::QL::Query.perform(bbox, query)

feature = features.first
feature.geometry
# => RGeo::Geographic::SphericalMultiLineStringImpl
```

### Other Relations

Relations without a recognized type tag are expanded into individual member
geometries (the previous behavior), with each member geometry wrapped in a Feature
carrying the parent relation's tags.

## GeoJSON Export

Convert results to GeoJSON for use with web mapping libraries:

```ruby
features = Underpass::QL::Query.perform(bbox, query)
geojson = Underpass::GeoJSON.encode(features)

# geojson is a Hash:
# {
#   "type" => "FeatureCollection",
#   "features" => [
#     {
#       "type" => "Feature",
#       "geometry" => { "type" => "Point", "coordinates" => [23.69, 47.65] },
#       "properties" => { "name" => "...", "amenity" => "restaurant" },
#       "id" => 123456
#     },
#     ...
#   ]
# }

# Serialize to JSON
require 'json'
File.write('output.geojson', JSON.pretty_generate(geojson))
```

This requires the `rgeo-geojson` gem, which is included as a dependency.

## Result Filtering

Filter results by tag properties after querying, without modifying the Overpass query:

```ruby
features = Underpass::QL::Query.perform(bbox, 'nwr["amenity"];')

# Exact match
restaurants = Underpass::Filter.new(features).where(amenity: 'restaurant')

# Regex match
italian = Underpass::Filter.new(features).where(cuisine: /italian/i)

# Multiple acceptable values (OR)
food = Underpass::Filter.new(features).where(amenity: %w[restaurant cafe bar])

# Multiple conditions (AND)
chinese_restaurants = Underpass::Filter.new(features).where(
  amenity: 'restaurant',
  cuisine: 'chinese'
)

# Rejection
no_banks = Underpass::Filter.new(features).reject(amenity: 'bank')
```

## Lazy Enumeration

For large result sets, use `lazy_matches` to avoid building the entire array in memory:

```ruby
matcher = Underpass::Matcher.new(response, requested_types)

# Process results lazily
matcher.lazy_matches.each do |feature|
  # Each Feature is created on demand
  puts feature.properties[:name]
end

# Take only the first 10
first_ten = matcher.lazy_matches.first(10)

# Chain lazy operations
matcher.lazy_matches
       .select { |f| f.properties[:amenity] == 'restaurant' }
       .map(&:geometry)
       .first(5)
```

`Matcher#matches` is implemented in terms of `lazy_matches.to_a`, so eager
evaluation still works identically.

## Query Analyzer

The library includes a query analyzer that automatically determines which types of
matches (node, way, or relation) you're interested in based on your query. This
ensures that only the requested match types are returned.

### How it works

1. The query is trimmed and split on semicolons (`;`)
2. For each line, the analyzer looks at the first word
3. If the first word is `node`, `way`, or `relation`, that type is added to the requested match types
4. The library returns only matches of the requested types that have the `tags` key

### Examples

Query for ways only:
```ruby
query = 'way["highway"="primary"];'
features = Underpass::QL::Query.perform(bbox, query)
# Returns only way matches
```

Query for nodes and relations:
```ruby
query = 'node["amenity"="restaurant"]; relation["type"="multipolygon"];'
features = Underpass::QL::Query.perform(bbox, query)
# Returns node and relation matches, but no way matches
```

Query with unrecognized type (returns all types):
```ruby
query = 'nwr["name"="Example"];'  # nwr is not a specific type
features = Underpass::QL::Query.perform(bbox, query)
# Returns all match types (node, way, and relation)
```

## Configuration

### Custom API Endpoint

Point to a private Overpass instance instead of the public one:

```ruby
Underpass.configure do |c|
  c.api_endpoint = 'https://my-overpass.example.com/api/interpreter'
end
```

### Custom Timeout

Change the Overpass query timeout (default: 25 seconds):

```ruby
Underpass.configure do |c|
  c.timeout = 60
end
```

### Reset Configuration

```ruby
Underpass.reset_configuration!
```

## Error Handling

The client automatically retries on transient errors with exponential backoff:

- **HTTP 429** (rate limited) -- retries up to 3 times, then raises `Underpass::RateLimitError`
- **HTTP 504** (gateway timeout) -- retries up to 3 times, then raises `Underpass::TimeoutError`
- **Other errors** -- raises `Underpass::ApiError` immediately

All errors inherit from `Underpass::Error`, which inherits from `StandardError`.

```ruby
begin
  features = Underpass::QL::Query.perform(bbox, query)
rescue Underpass::RateLimitError
  puts "Rate limited by the Overpass API, try again later"
rescue Underpass::TimeoutError
  puts "Query timed out, try a smaller bounding box"
rescue Underpass::ApiError => e
  puts "API error: #{e.message}"
end
```

## Response Caching

Enable in-memory caching to avoid redundant API calls during development:

```ruby
# Enable with a 10-minute TTL
Underpass.cache = Underpass::Cache.new(ttl: 600)

# Subsequent identical queries return cached responses
features = Underpass::QL::Query.perform(bbox, query)  # hits API
features = Underpass::QL::Query.perform(bbox, query)  # returns cached

# Clear the cache
Underpass.cache.clear

# Disable caching
Underpass.cache = nil
```

Caching is disabled by default. Cache keys are SHA-256 digests of the full query
string, so different queries always produce different keys.

## Recurse Operators

The Overpass recurse operator can be configured per request. The default (`>`)
fetches child elements, which is needed to resolve way nodes:

```ruby
# Default: child recurse (>)
request = Underpass::QL::Request.new(query, bbox)

# Descendant recurse (>>)
request = Underpass::QL::Request.new(query, bbox, recurse: '>>')

# Parent recurse (<)
request = Underpass::QL::Request.new(query, bbox, recurse: '<')

# No recurse
request = Underpass::QL::Request.new(query, bbox, recurse: nil)
```

## To Do

Have a look at the [issue tracker](https://github.com/haiafara/underpass/issues).

## Comprehensive Examples

For detailed, working examples with real data that cover all return types and functionality of the library, see the [usage-examples.md](docs/usage-examples.md) file. These examples demonstrate:

- **Node queries** (Point geometries) - restaurants, cafes, bus stops
- **Way queries** (LineString geometries) - primary roads, highways
- **Way queries** (Polygon geometries) - buildings, parks
- **Relation queries** (MultiPolygon geometries) - lakes with islands
- **Relation queries** (MultiLineString geometries) - bus routes, hiking trails
- **Area queries** - using `perform_in_area` instead of bounding boxes
- **Around queries** - proximity search within a radius
- **Builder DSL** - constructing queries programmatically
- **Post-query filtering** - filtering results by properties
- **GeoJSON export** - converting results for web mapping libraries

All examples use real data from OpenStreetMap and have been tested to work correctly.

## How To Contribute

* Check out the latest master branch to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the [issue tracker](https://github.com/haiafara/underpass/issues) to make sure someone already hasn't requested it and / or contributed it
* Fork the project, clone the fork, run `bundle install` and then make sure `rspec` runs
* Start a feature / bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add specs for it - this is important so your contribution won't be broken in a future version unintentionally
* Open a pull request

Further tips:

* To test drive the library run `bundle console`

## Related Documentation

Things to read if you want to get familiar with [RGeo](https://github.com/rgeo/rgeo)

* [RGeo RDoc](https://rdoc.info/github/rgeo/rgeo/)
* [Geo-Rails Part 1: A Call to Revolution](https://daniel-azuma.com/articles/georails/part-1)
* [Geo-Rails Part 2: Setting Up a Geospatial Rails App](https://daniel-azuma.com/articles/georails/part-2)
* [Geo-Rails Part 3: Spatial Data Types with RGeo](https://daniel-azuma.com/articles/georails/part-3)
* [Geo-Rails Part 4: Coordinate Systems and Projections](https://daniel-azuma.com/articles/georails/part-4)
* [Geo-Rails Part 5: Spatial Data Formats](https://daniel-azuma.com/articles/georails/part-5)
* [Geo-Rails Part 6: Scaling Spatial Applications](https://daniel-azuma.com/articles/georails/part-6)
* [Geo-Rails Part 7: Geometry vs. Geography, or, How I Learned To Stop Worrying And Love Projections](https://daniel-azuma.com/articles/georails/part-7)
* [Geo-Rails Part 8: ZCTA Lookup, A Worked Example](https://daniel-azuma.com/articles/georails/part-8)
* [Geo-Rails Part 9: The PostGIS spatial_ref_sys Table and You](https://daniel-azuma.com/articles/georails/part-9)

## License

underpass is released under the MIT License. See the [LICENSE file](LICENSE) for further details.
