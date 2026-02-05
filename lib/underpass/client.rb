# frozen_string_literal: true

require 'digest'
require 'net/http'
require 'uri'

module Underpass
  # Runs the Overpass API query with retry logic for transient errors.
  #
  # Handles caching of responses and automatic retries with exponential
  # backoff for rate limiting (429) and timeout (504) responses.
  class Client
    # @return [Integer] default maximum number of retries
    MAX_RETRIES = 3

    # Performs the API request with automatic retries for rate limiting and timeouts.
    #
    # Results are cached when a {Cache} instance is configured via {Underpass.cache}.
    #
    # @param request [QL::Request] the prepared Overpass query request
    # @param max_retries [Integer] maximum number of retry attempts
    # @return [Net::HTTPResponse] the API response
    # @raise [RateLimitError] when rate limited after exhausting retries
    # @raise [TimeoutError] when the API times out after exhausting retries
    # @raise [ApiError] when the API returns an unexpected error
    def self.perform(request, max_retries: MAX_RETRIES)
      cache_key = Digest::SHA256.hexdigest(request.to_query)
      cached = Underpass.cache&.fetch(cache_key)
      return cached if cached

      response = perform_with_retries(request, max_retries)
      Underpass.cache&.store(cache_key, response)
      response
    end

    def self.perform_with_retries(request, max_retries)
      retries = 0
      loop do
        response = post_request(request)
        return response if response.code.to_i == 200

        retries = handle_error(response, retries, max_retries)
        sleep(2**retries)
      end
    end
    private_class_method :perform_with_retries

    def self.post_request(request)
      Net::HTTP.post_form(
        URI(Underpass.configuration.api_endpoint),
        data: request.to_query
      )
    end
    private_class_method :post_request

    def self.handle_error(response, retries, max_retries)
      status_code = response.code.to_i
      error_class = { 429 => RateLimitError, 504 => TimeoutError }[status_code] || ApiError
      parsed = ErrorParser.parse(response.body, status_code)

      if error_class == ApiError
        raise ApiError.new(
          parsed[:message],
          code: parsed[:code],
          error_message: parsed[:message],
          details: parsed[:details],
          http_status: status_code
        )
      end

      retries += 1
      if retries > max_retries
        raise error_class.new(
          parsed[:message],
          code: parsed[:code],
          error_message: parsed[:message],
          details: parsed[:details],
          http_status: status_code
        )
      end

      retries
    end
    private_class_method :handle_error
  end
end
