# frozen_string_literal: true

module Relations
  # Nodes for multipolygon and route fixtures
  EXTENDED_NODES =
    {
      10 => { type: 'node', lat: 0, lon: 0 },
      11 => { type: 'node', lat: 0, lon: 10 },
      12 => { type: 'node', lat: 10, lon: 10 },
      13 => { type: 'node', lat: 10, lon: 0 },
      20 => { type: 'node', lat: 2, lon: 2 },
      21 => { type: 'node', lat: 2, lon: 4 },
      22 => { type: 'node', lat: 4, lon: 4 },
      23 => { type: 'node', lat: 4, lon: 2 },
      30 => { type: 'node', lat: 0, lon: 20 },
      31 => { type: 'node', lat: 0, lon: 30 },
      32 => { type: 'node', lat: 10, lon: 30 },
      33 => { type: 'node', lat: 10, lon: 20 }
    }.freeze

  EXTENDED_WAYS =
    {
      100 => { type: 'way', id: 100, nodes: [10, 11, 12, 13, 10] },
      101 => { type: 'way', id: 101, nodes: [20, 21, 22, 23, 20] },
      102 => { type: 'way', id: 102, nodes: [30, 31, 32, 33, 30] },
      200 => { type: 'way', id: 200, nodes: [10, 11, 12] },
      201 => { type: 'way', id: 201, nodes: [12, 13, 30] }
    }.freeze

  MULTIPOLYGON_RELATION =
    {
      type: 'relation',
      id: 1000,
      tags: { type: 'multipolygon', name: 'Test Multipolygon' },
      members: [
        { type: 'way', ref: 100, role: 'outer' },
        { type: 'way', ref: 101, role: 'inner' }
      ]
    }.freeze

  MULTI_OUTER_RELATION =
    {
      type: 'relation',
      id: 1001,
      tags: { type: 'multipolygon', name: 'Multi Outer' },
      members: [
        { type: 'way', ref: 100, role: 'outer' },
        { type: 'way', ref: 102, role: 'outer' }
      ]
    }.freeze

  ROUTE_RELATION =
    {
      type: 'relation',
      id: 2000,
      tags: { type: 'route', name: 'Test Route' },
      members: [
        { type: 'way', ref: 200, role: '' },
        { type: 'way', ref: 201, role: '' }
      ]
    }.freeze
end
