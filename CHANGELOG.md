# Underpass Feature Implementation Report

This document describes the 13 features implemented as part of the Underpass library
expansion. The work is organized into four groups: Robustness & Infrastructure, Relation
& Geometry Improvements, Metadata Preservation, and Query Capabilities.

All 88 tests pass with zero rubocop offenses and 98% line coverage.

---

## Group A: Robustness & Infrastructure

### 1. Configurable Endpoint

**Files:** `lib/underpass/configuration.rb` (new), `lib/underpass.rb` (modified),
`lib/underpass/client.rb` (modified), `lib/underpass/ql/request.rb` (modified)

The library previously hardcoded the public Overpass API endpoint
(`https://overpass-api.de/api/interpreter`) and a 25-second timeout as constants.
Both are now configurable through a `Configuration` class and a `configure` block
on the `Underpass` module.

```ruby
Underpass.configure do |c|
  c.api_endpoint = 'https://my-private-overpass.example.com/api/interpreter'
  c.timeout = 60
end
```

`Client.perform` reads `Underpass.configuration.api_endpoint` to determine which
URI to POST to. `Request#to_query` substitutes `Underpass.configuration.timeout`
into the Overpass QL template. `Underpass.reset_configuration!` restores defaults.

---

### 2. Error Handling & Retries

**Files:** `lib/underpass/errors.rb` (new), `lib/underpass/client.rb` (modified)

Three error classes were added under the `Underpass` namespace:

- `Underpass::Error` -- base class, inherits `StandardError`
- `Underpass::RateLimitError` -- raised on HTTP 429
- `Underpass::TimeoutError` -- raised on HTTP 504
- `Underpass::ApiError` -- raised on any other non-200 response

`Client.perform` now retries on 429 and 504 responses with exponential backoff
(`sleep(2^retries)`). After exhausting `max_retries` (default 3), the corresponding
error is raised. Any other non-200 response raises `ApiError` immediately without
retrying.

```ruby
# Customize retry limit
Underpass::Client.perform(request, max_retries: 5)
```

The implementation is split across three private class methods (`perform_with_retries`,
`post_request`, `handle_error`) to satisfy rubocop complexity limits.

---

### 3. Response Caching

**Files:** `lib/underpass/cache.rb` (new), `lib/underpass/client.rb` (modified),
`lib/underpass.rb` (modified)

`Underpass::Cache` is a simple in-memory key-value store with TTL expiration.
Each entry records its storage time; `fetch` returns `nil` if the entry has expired.

```ruby
# Enable caching with a 10-minute TTL
Underpass.cache = Underpass::Cache.new(ttl: 600)

# Disable caching
Underpass.cache = nil
```

When a cache is set, `Client.perform` computes a SHA-256 digest of the query string
as the cache key. On a cache hit, the stored HTTP response is returned without making
a network request. On a cache miss, the response is stored after a successful API call.

Caching is disabled by default (`Underpass.cache` is `nil`).

---

### 4. Recurse Support

**Files:** `lib/underpass/ql/request.rb` (modified)

The Overpass QL template previously hardcoded `>;` (the child recurse operator).
The `QUERY_TEMPLATE` now uses a `RECURSE` placeholder, and `Request.new` accepts
a `recurse:` keyword argument.

```ruby
# Default: child recurse (same as before)
Underpass::QL::Request.new(query, bbox)

# Descendant recurse
Underpass::QL::Request.new(query, bbox, recurse: '>>')

# No recurse
Underpass::QL::Request.new(query, bbox, recurse: nil)
```

Supported values are `">"`, `">>"`, `"<"`, `"<<"`, or `nil`. The default (`">"`)
preserves backward compatibility.

---

## Group B: Relation & Geometry Improvements

### 5. Multipolygon Assembly from Relations

**Files:** `lib/underpass/shape.rb` (modified), `lib/underpass/way_chain.rb` (new),
`lib/underpass/matcher.rb` (modified), `spec/support/relations.rb` (new)

Previously, relations were expanded into their individual member geometries --
a multipolygon relation with 3 outer ways and 1 inner way would produce 4 separate
LineStrings or Polygons. Now, multipolygon relations (those with `tags[:type] == "multipolygon"`)
are assembled into proper RGeo geometries.

`Shape.multipolygon_from_relation(relation, ways, nodes)`:

1. Separates members by role (`outer` vs `inner`)
2. Chains way segments that share endpoints using `WayChain`
3. Builds `LinearRing` objects from the merged sequences
4. Assigns inner rings to their containing outer ring
5. Returns a single `Polygon` for one outer ring, or a `MultiPolygon` for multiple

`WayChain` is a dedicated class that merges node sequences sharing endpoints.
It uses four merge strategies (end-to-start, end-to-end, start-to-end, start-to-start)
and iteratively chains sequences until no more connections are found.

The `Matcher` detects multipolygon relations via `relation[:tags][:type]` and routes
them to `Shape.multipolygon_from_relation` instead of the generic member expansion.

---

### 6. Route Relation Support

**Files:** `lib/underpass/shape.rb` (modified), `lib/underpass/matcher.rb` (modified)

Route relations (`tags[:type] == "route"`) represent bus lines, hiking trails, and
similar linear features. Their way members are now assembled into a single
`MultiLineString` geometry.

`Shape.multi_line_string_from_relation(relation, ways, nodes)` collects all way
members, converts each to a `LineString`, and wraps them in a `MultiLineString`.

The `Matcher` detects route relations and routes them accordingly.

---

## Group C: Metadata Preservation

### 7. Tag-Enriched Results (Feature Class)

**Files:** `lib/underpass/feature.rb` (new), `lib/underpass/matcher.rb` (modified)

Previously, `Matcher#matches` returned bare RGeo geometry objects, discarding all
OSM tag data. The new `Underpass::Feature` class wraps a geometry with its metadata:

```ruby
feature.geometry   # => RGeo::Geographic::SphericalPolygonImpl
feature.properties # => { name: "Central Park", leisure: "park" }
feature.id         # => 123456
feature.type       # => "way"
```

`Matcher` now wraps every geometry in a `Feature` before adding it to the results
array. For relation members, the parent relation's tags and ID are used.

**Breaking change:** `Query.perform` now returns an array of `Underpass::Feature`
objects instead of bare RGeo geometries. Access the geometry via `feature.geometry`.

---

### 8. GeoJSON Export

**Files:** `lib/underpass/geo_json.rb` (new), `underpass.gemspec` (modified)

The `Underpass::GeoJSON` module converts an array of `Feature` objects into a
GeoJSON FeatureCollection hash using the `rgeo-geojson` gem (added as a dependency).

```ruby
features = Underpass::QL::Query.perform(bbox, query)
geojson = Underpass::GeoJSON.encode(features)
# => { "type" => "FeatureCollection", "features" => [...] }

# Convert to JSON string
require 'json'
puts JSON.pretty_generate(geojson)
```

Each Feature's geometry, properties, and ID are mapped to their GeoJSON equivalents.
The output can be validated at geojson.io or consumed by any GeoJSON-compatible
mapping library (Leaflet, Mapbox GL, etc.).

---

## Group D: Query Capabilities

### 9. Query Builder DSL

**Files:** `lib/underpass/ql/builder.rb` (new), `lib/underpass/ql/query.rb` (modified)

The `Builder` class provides a chainable Ruby DSL for constructing Overpass QL queries
without writing raw query strings.

```ruby
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .way(highway: 'primary')
          .to_ql
# => "node[\"amenity\"=\"restaurant\"];\nway[\"highway\"=\"primary\"];"
```

Available methods: `node`, `way`, `relation`, `nwr` (node/way/relation shorthand).
Each accepts a hash of tag filters. All methods return `self` for chaining.

`Query.perform` now accepts either a raw string or a Builder instance (detected via
`respond_to?(:to_ql)`):

```ruby
builder = Underpass::QL::Builder.new.way('heritage:operator': 'lmi')
results = Underpass::QL::Query.perform(bbox, builder)
```

---

### 10. Area / Named Region Queries

**Files:** `lib/underpass/ql/request.rb` (modified), `lib/underpass/ql/query.rb` (modified)

Overpass supports searching within named geographic areas instead of bounding boxes.
A new `AREA_QUERY_TEMPLATE` uses the Overpass `area` statement:

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

`Request.new` now accepts an optional `area_name:` keyword. When provided, the area
template is used instead of the bbox template.

A convenience method was added to `Query`:

```ruby
results = Underpass::QL::Query.perform_in_area('Romania', 'node["amenity"="restaurant"];')
```

---

### 11. Around / Proximity Queries

**Files:** `lib/underpass/ql/builder.rb` (modified)

The Builder DSL supports the Overpass `around` filter for proximity searches.

```ruby
# Using lat/lon coordinates
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .around(500, 47.65, 23.69)
          .to_ql
# => 'node["amenity"="restaurant"](around:500,47.65,23.69);'

# Using an RGeo point
point = RGeo::Geographic.spherical_factory(srid: 4326).point(23.69, 47.65)
query = Underpass::QL::Builder.new
          .node(amenity: 'restaurant')
          .around(500, point)
          .to_ql
```

When `around` is set, the filter is appended to every statement in the builder.
The first argument is the radius in meters; the remaining arguments are either
`(lat, lon)` or a single RGeo point object.

---

### 12. Result Filtering by Tags

**Files:** `lib/underpass/filter.rb` (new)

`Underpass::Filter` enables post-query filtering of `Feature` objects by their
tag properties, without modifying the Overpass query.

```ruby
features = Underpass::QL::Query.perform(bbox, query)

# Exact match
restaurants = Underpass::Filter.new(features).where(amenity: 'restaurant')

# Regex match
italian = Underpass::Filter.new(features).where(cuisine: /italian/i)

# Array of acceptable values (OR)
food = Underpass::Filter.new(features).where(amenity: %w[restaurant cafe])

# Multiple conditions (AND)
specific = Underpass::Filter.new(features).where(amenity: 'restaurant', cuisine: 'chinese')

# Rejection
no_banks = Underpass::Filter.new(features).reject(amenity: 'bank')
```

Condition matching supports three modes: exact string comparison, Regexp matching,
and Array inclusion.

---

### 13. Lazy Enumeration

**Files:** `lib/underpass/matcher.rb` (modified)

`Matcher#lazy_matches` returns an `Enumerator::Lazy` that yields `Feature` objects
on demand. Elements are only converted to geometries and wrapped in Features when
consumed by the caller.

```ruby
matcher = Underpass::Matcher.new(response)

# Get first 5 results without processing the entire response
first_five = matcher.lazy_matches.first(5)

# Chain lazy operations
matcher.lazy_matches
       .select { |f| f.properties[:amenity] == 'restaurant' }
       .map { |f| f.geometry }
       .first(10)

# Get all results (equivalent to matcher.matches)
all_results = matcher.lazy_matches.to_a
```

`Matcher#matches` was refactored to delegate to `lazy_matches.to_a`, eliminating
code duplication. The `tagged_elements` method collects all elements with tags
from nodes, ways, and relations (filtered by requested types), and `features_for`
converts each element to one or more Feature objects based on its type.

---

## Architecture Changes

### New Files

| File | Purpose |
|------|---------|
| `lib/underpass/configuration.rb` | Configurable endpoint and timeout |
| `lib/underpass/errors.rb` | Error class hierarchy |
| `lib/underpass/cache.rb` | In-memory TTL cache |
| `lib/underpass/feature.rb` | Geometry + metadata wrapper |
| `lib/underpass/filter.rb` | Post-query tag filtering |
| `lib/underpass/geo_json.rb` | GeoJSON encoding |
| `lib/underpass/way_chain.rb` | Way segment chaining |
| `lib/underpass/ql/builder.rb` | Query builder DSL |
| `spec/support/relations.rb` | Test fixtures for relations |
| `spec/underpass/configuration_spec.rb` | Configuration tests |
| `spec/underpass/cache_spec.rb` | Cache and cache integration tests |
| `spec/underpass/feature_spec.rb` | Feature class tests |
| `spec/underpass/filter_spec.rb` | Filter tests |
| `spec/underpass/geo_json_spec.rb` | GeoJSON encoding tests |
| `spec/underpass/ql/builder_spec.rb` | Builder DSL tests |

### Modified Files

| File | Changes |
|------|---------|
| `lib/underpass.rb` | Added requires, `configure`/`cache`/`reset_configuration!` module methods |
| `lib/underpass/client.rb` | Configurable endpoint, retry logic, cache integration |
| `lib/underpass/shape.rb` | Multipolygon assembly, route assembly, shared factory |
| `lib/underpass/matcher.rb` | Feature wrapping, relation type dispatch, lazy enumeration |
| `lib/underpass/ql/request.rb` | Configurable timeout, recurse placeholder, area template |
| `lib/underpass/ql/query.rb` | Builder support, `perform_in_area`, extracted shared logic |
| `underpass.gemspec` | Added `rgeo-geojson ~> 2.2` dependency |

### Breaking Changes

`Matcher#matches` (and therefore `Query.perform`) now returns `Underpass::Feature`
objects instead of bare RGeo geometries. Code that previously accessed geometry
methods directly on results must now go through `.geometry`:

```ruby
# Before
results = Underpass::QL::Query.perform(bbox, query)
results.first.as_text  # => "POLYGON ((...)"

# After
results = Underpass::QL::Query.perform(bbox, query)
results.first.geometry.as_text  # => "POLYGON ((...)"
results.first.properties        # => { name: "...", amenity: "..." }
```

### Dependencies

- `rgeo-geojson ~> 2.2` was added for GeoJSON encoding support.

### Test Suite

- **88 examples**, 0 failures
- **0 rubocop offenses**
- **98% line coverage** (362 of 369 lines)
