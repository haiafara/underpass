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

## Usage

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
# Create the bounding box in which the query will run
bbox = RGeo::Geographic.spherical_factory.parse_wkt(wkt)
# Define the Overpass QL query
query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'
# Perform the query and get your matches
matches = Underpass::QL::Query.perform(bbox, query)
```

See [more usage examples](usage-examples.md).

## Query Analyzer

The library includes a query analyzer that automatically determines which types of matches (node, way, or relation) you're interested in based on your query. This ensures that only the requested match types are returned.

### How it works

1. The query is trimmed and split on semicolons (`;`)
2. For each line, the analyzer looks at the first word
3. If the first word is `node`, `way`, or `relation`, that type is added to the requested match types
4. The library returns only matches of the requested types that have the `tags` key

### Examples

Query for ways only:
```ruby
query = 'way["highway"="primary"];'
matches = Underpass::QL::Query.perform(bbox, query)
# Returns only way matches
```

Query for nodes and relations:
```ruby
query = 'node["amenity"="restaurant"]; relation["type"="multipolygon"];'
matches = Underpass::QL::Query.perform(bbox, query)
# Returns node and relation matches, but no way matches
```

Query with unrecognized type (returns all types):
```ruby
query = 'nwr["name"="Example"];'  # nwr is not a specific type
matches = Underpass::QL::Query.perform(bbox, query)
# Returns all match types (node, way, and relation)
```

## To Do

Have a look at the [issue tracker](https://github.com/haiafara/underpass/issues).

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
* Run `guard` in the project directory, it'll watch for file changes and run Rubocop and RSpec for real time feedback

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
