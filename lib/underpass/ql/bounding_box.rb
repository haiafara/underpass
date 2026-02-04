# frozen_string_literal: true

module Underpass
  module QL
    # Converts RGeo geometries and WKT strings into Overpass QL bounding box syntax.
    class BoundingBox
      class << self
        # Returns the Overpass QL bounding box string from a WKT string.
        #
        # @param wkt [String] a Well Known Text geometry string
        # @return [String] an Overpass QL bounding box (e.g. +"bbox:47.65,23.669,47.674,23.725"+)
        def from_wkt(wkt)
          geometry = RGeo::Geographic.spherical_factory.parse_wkt(wkt)
          from_geometry(geometry)
        end

        # Returns the Overpass QL bounding box string from an RGeo geometry.
        #
        # @param geometry [RGeo::Feature::Geometry] an RGeo geometry
        # @return [String] an Overpass QL bounding box (e.g. +"bbox:47.65,23.669,47.674,23.725"+)
        def from_geometry(geometry)
          r_bb = RGeo::Cartesian::BoundingBox.create_from_geometry(geometry)
          "bbox:#{r_bb.min_y},#{r_bb.min_x},#{r_bb.max_y},#{r_bb.max_x}"
        end
      end
    end
  end
end
