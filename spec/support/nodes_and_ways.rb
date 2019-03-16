# frozen_string_literal: true

module NodesAndWays
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
end
