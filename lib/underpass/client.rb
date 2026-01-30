# frozen_string_literal: true

require 'digest'

module Underpass
  # Runs the Overpass API query with retry logic for transient errors
  class Client
    MAX_RETRIES = 3

    # Performs the API request with automatic retries for rate limiting and timeouts
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
      error_class = { 429 => RateLimitError, 504 => TimeoutError }[response.code.to_i]
      raise ApiError, "Overpass API returned #{response.code}: #{response.body}" unless error_class

      retries += 1
      raise error_class, "#{error_class} after #{max_retries} retries" if retries > max_retries

      retries
    end
    private_class_method :handle_error
  end
end
