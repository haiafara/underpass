# frozen_string_literal: true

module Underpass
  # Simple in-memory cache with TTL expiration.
  #
  # @example Enable caching
  #   Underpass.cache = Underpass::Cache.new(ttl: 600)
  class Cache
    # Creates a new cache instance.
    #
    # @param ttl [Integer] time-to-live in seconds for cached entries (default: 300)
    def initialize(ttl: 300)
      @store = {}
      @ttl = ttl
    end

    # Retrieves a cached value by key if it has not expired.
    #
    # @param key [String] the cache key
    # @return [Object, nil] the cached value, or +nil+ if missing or expired
    def fetch(key)
      entry = @store[key]
      return nil unless entry
      return nil if Time.now - entry[:time] > @ttl

      entry[:value]
    end

    # Stores a value in the cache.
    #
    # @param key [String] the cache key
    # @param value [Object] the value to cache
    # @return [Hash] the stored entry
    def store(key, value)
      @store[key] = { value: value, time: Time.now }
    end

    # Removes all entries from the cache.
    #
    # @return [void]
    def clear
      @store.clear
    end
  end
end
