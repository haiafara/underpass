# frozen_string_literal: true

module Underpass
  # Runs the Overpass API query
  class Client
    API_URI = 'https://overpass-api.de/api/interpreter'

    # Performs the API request
    def self.perform(request)
      Net::HTTP.post_form(URI(API_URI), data: request.to_query)
    end
  end
end
