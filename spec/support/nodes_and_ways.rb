# frozen_string_literal: true

module NodesAndWays
  NODE =
    {
      type: 'node',
      lat: 1,
      lon: -1
    }.freeze

  NODES =
    {
      1 => {
        type: 'node',
        lat: -1,
        lon: 1
      },
      2 => {
        type: 'node',
        lat: 1,
        lon: 1
      },
      3 => {
        type: 'node',
        lat: 1,
        lon: -1
      }
    }.freeze

  POLYGON_WAY =
    {
      type: 'way',
      nodes: [
        1,
        2,
        3,
        1
      ]
    }.freeze

  LINE_STRING_WAY =
    {
      type: 'way',
      nodes: [
        1,
        2,
        3
      ]
    }.freeze

  NODES_AND_WAYS =
    [
      {
        type: 'way',
        id: 1,
        nodes: [2, 3, 4, 5],
        tags: {
          amenity: 'something',
          building: 'yes',
          name: 'Test'
        }
      },
      {
        type: 'node',
        id: 2,
        lat: -1,
        lon: 1
      },
      {
        type: 'node',
        id: 3,
        lat: 1,
        lon: 1
      },
      {
        type: 'node',
        id: 4,
        lat: 1,
        lon: -1
      },
      {
        type: 'node',
        id: 5,
        lat: -1,
        lon: -1
      }
    ].freeze
end
