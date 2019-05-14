# underpass

[![Gem Version](https://badge.fury.io/rb/underpass.svg)](https://badge.fury.io/rb/underpass)
[![Build Status](https://www.travis-ci.org/haiafara/underpass.svg?branch=master)](https://www.travis-ci.org/haiafara/underpass)
[![Coverage Status](https://coveralls.io/repos/github/haiafara/underpass/badge.svg?branch=master)](https://coveralls.io/github/haiafara/underpass?branch=master)

A library that makes it easy to query the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) and translate its responses into [RGeo](https://github.com/rgeo/rgeo) objects.

## Installation

Install globally:

    gem install underpass

Or put it in your Gemfile:

    gem 'underpass'

## Usage

```ruby
# require the library if it's not autoloaded
require 'underpass'
# create a bounding box in which the query will be run
f = RGeo::Geographic.spherical_factory
bbox = f.parse_wkt('POLYGON ((23.669 47.65, 23.725 47.65, 23.725 47.674, 23.669 47.674, 23.669 47.65))')
# provide the query
op_query = 'way["heritage:operator"="lmi"]["ref:ro:lmi"="MM-II-m-B-04508"];'
# perform the query and get your results
result = Underpass::QL::Query.perform(bbox, op_query)
```

See [more usage examples](usage-examples.md).

## To Do

Have a look at the [issue tracker](https://github.com/haiafara/underpass/issues).

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet;
* Check out the issue tracker to make sure someone already hasn't requested it and / or contributed it;
* Fork the project;
* Start a feature / bugfix branch;
* Commit and push until you are happy with your contribution;
* Make sure to add specs for it. This is important so your contribution won't be broken in a future version unintentionally.

## License

underpass is released under the MIT License. See the [LICENSE file](LICENSE) for further details.
