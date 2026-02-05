# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Configurable `max_retries` for retry attempts on rate limiting and timeout errors
- Structured error data: errors now include `code`, `error_message`, `details`, and `http_status` attributes
- New `ErrorParser` class to parse HTML error responses from Overpass API
- `to_h` and `to_json` methods on error classes for easy serialization

## [0.9.0] - 2026-02-04

### Added
- Configurable API endpoint and timeout via `Underpass.configure`
- Error handling with `RateLimitError`, `TimeoutError`, and `ApiError` classes
- Automatic retries with exponential backoff for 429/504 responses
- In-memory response caching with TTL expiration
- Configurable Overpass QL recurse operators
- Multipolygon assembly from OSM relations
- Route relation support (assembles way members into MultiLineString)
- `Feature` class wrapping geometries with OSM metadata (tags, id, type)
- GeoJSON export via `Underpass::GeoJSON.encode`
- Query Builder DSL with chainable `node`, `way`, `relation`, `nwr` methods
- Area/named region queries via `Query.perform_in_area`
- Proximity queries with `around` filter in Builder DSL
- Post-query tag filtering via `Underpass::Filter`
- Lazy enumeration via `Matcher#lazy_matches`
- YARD documentation

### Changed
- **BREAKING**: `Query.perform` now returns `Underpass::Feature` objects instead of bare RGeo geometries
- Upgraded to Ruby 3.4
- Modernized CI and build tooling

### Dependencies
- Added `rgeo-geojson` ~> 2.2

## [0.0.7] - 2019-07-31

- Previous release
