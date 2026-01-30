# frozen_string_literal: true

module Underpass
  # Simple in-memory cache with TTL expiration
  class Cache
    def initialize(ttl: 300)
      @store = {}
      @ttl = ttl
    end

    def fetch(key)
      entry = @store[key]
      return nil unless entry
      return nil if Time.now - entry[:time] > @ttl

      entry[:value]
    end

    def store(key, value)
      @store[key] = { value: value, time: Time.now }
    end

    def clear
      @store.clear
    end
  end
end
