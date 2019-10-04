# frozen_string_literal: true

module Underpass
  module QL
    # Bounding box related utilities
    class BoundingBox
      class << self
        # Returns the Overpass query language bounding box string
        # when provided with WKT (Well Known Text)
        def from_wkt(wkt)
          geometry = RGeo::Geographic.spherical_factory.parse_wkt(wkt)
          from_geometry(geometry)
        end

        # Returns the Overpass query language bounding box string
        # when provided with an RGeo geometry
        def from_geometry(geometry)
          r_bb = RGeo::Cartesian::BoundingBox.create_from_geometry(geometry)
          "bbox:#{r_bb.min_y},#{r_bb.min_x},#{r_bb.max_y},#{r_bb.max_x}"
        end
      end
    end
  end
end
