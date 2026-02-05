# frozen_string_literal: true

require 'json'

module Underpass
  # Base error class for all Underpass errors.
  #
  # Provides structured error data parsed from Overpass API responses.
  #
  # @example
  #   begin
  #     features = Underpass::QL::Query.perform(bbox, query)
  #   rescue Underpass::Error => e
  #     e.code           # => "timeout"
  #     e.error_message  # => "Query timed out..."
  #     e.details        # => { line: 3, timeout_seconds: 25 }
  #     e.http_status    # => 504
  #     e.to_h           # => { code: "timeout", message: "...", details: {...} }
  #   end
  class Error < StandardError
    # @return [String, nil] the error code (e.g., "timeout", "memory", "syntax")
    attr_reader :code

    # @return [String, nil] the human-readable error message
    attr_reader :error_message

    # @return [Hash] additional error details (varies by error type)
    attr_reader :details

    # @return [Integer, nil] the HTTP status code from the API response
    attr_reader :http_status

    # Creates a new error with optional structured data.
    #
    # @param message [String, nil] the error message (used by StandardError)
    # @param code [String, nil] the error code
    # @param error_message [String, nil] the detailed error message
    # @param details [Hash] additional error details
    # @param http_status [Integer, nil] the HTTP status code
    def initialize(message = nil, code: nil, error_message: nil, details: {}, http_status: nil)
      @code = code
      @error_message = error_message || message
      @details = details || {}
      @http_status = http_status
      super(@error_message || message)
    end

    # Returns a hash representation of the error.
    #
    # @return [Hash] the error as a hash with :code, :message, and :details keys
    def to_h
      {
        code: code,
        message: error_message,
        details: details
      }
    end

    # Returns a JSON representation of the error.
    #
    # @param args [Array] arguments passed to JSON.generate
    # @return [String] the error as a JSON string
    def to_json(*args)
      to_h.to_json(*args)
    end
  end

  # Raised when the Overpass API returns a 429 rate limit response.
  class RateLimitError < Error; end

  # Raised when the Overpass API returns a 504 timeout response.
  class TimeoutError < Error; end

  # Raised when the Overpass API returns an unexpected error response.
  class ApiError < Error; end
end
