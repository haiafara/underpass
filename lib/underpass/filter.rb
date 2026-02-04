# frozen_string_literal: true

module Underpass
  # Post-query filtering of {Feature} objects by tag properties.
  #
  # @example Filter restaurants by cuisine
  #   filter = Underpass::Filter.new(features)
  #   italian = filter.where(cuisine: 'italian')
  class Filter
    # Creates a new filter for the given features.
    #
    # @param features [Array<Feature>] the features to filter
    def initialize(features)
      @features = features
    end

    # Returns features whose properties match all given conditions.
    #
    # Conditions can be exact values, regular expressions, or arrays of values.
    #
    # @param conditions [Hash{Symbol => String, Regexp, Array}] tag conditions to match
    # @return [Array<Feature>] features matching all conditions
    #
    # @example Exact match
    #   filter.where(cuisine: 'italian')
    # @example Regex match
    #   filter.where(name: /pizza/i)
    # @example Array inclusion
    #   filter.where(cuisine: ['italian', 'mexican'])
    def where(conditions = {})
      @features.select do |feature|
        conditions.all? { |key, value| match_condition?(feature.properties[key], value) }
      end
    end

    # Returns features that do not match any of the given conditions.
    #
    # @param conditions [Hash{Symbol => String}] tag conditions to reject
    # @return [Array<Feature>] features not matching any condition
    def reject(conditions = {})
      @features.reject do |feature|
        conditions.any? { |key, value| feature.properties[key] == value.to_s }
      end
    end

    private

    def match_condition?(prop_value, condition)
      case condition
      when Regexp then prop_value&.match?(condition)
      when Array then condition.include?(prop_value)
      else prop_value == condition.to_s
      end
    end
  end
end
