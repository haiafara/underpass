# frozen_string_literal: true

module Underpass
  # Post-query filtering of Feature objects by tag properties
  class Filter
    def initialize(features)
      @features = features
    end

    def where(conditions = {})
      @features.select do |feature|
        conditions.all? { |key, value| match_condition?(feature.properties[key], value) }
      end
    end

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
