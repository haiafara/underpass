# frozen_string_literal: true

module Underpass
  # Base error class for all Underpass errors
  class Error < StandardError; end

  # Raised when the Overpass API returns a 429 rate limit response
  class RateLimitError < Error; end

  # Raised when the Overpass API returns a 504 timeout response
  class TimeoutError < Error; end

  # Raised when the Overpass API returns an unexpected error response
  class ApiError < Error; end
end
