# frozen_string_literal: true

module Underpass
  # Chains way node sequences that share endpoints into complete rings.
  #
  # Used internally by {Shape.multipolygon_from_relation} to merge multiple
  # way segments into closed linear rings.
  class WayChain
    # @api private
    MERGE_STRATEGIES = [
      ->(cur, seq) { cur.last == seq.first ? cur + seq[1..] : nil },
      ->(cur, seq) { cur.last == seq.last ? cur + seq.reverse[1..] : nil },
      ->(cur, seq) { cur.first == seq.last ? seq + cur[1..] : nil },
      ->(cur, seq) { cur.first == seq.first ? seq.reverse + cur[1..] : nil }
    ].freeze

    # Creates a new WayChain from way IDs and a way lookup table.
    #
    # @param way_ids [Array<Integer>] IDs of the ways to chain
    # @param ways [Hash{Integer => Hash}] way lookup table
    def initialize(way_ids, ways)
      @sequences = way_ids.filter_map do |way_id|
        way = ways[way_id]
        next unless way

        way[:nodes].dup
      end
    end

    # Merges node sequences that share endpoints into continuous rings.
    #
    # @return [Array<Array<Integer>>] the merged node ID sequences
    def merged_sequences
      return @sequences if @sequences.empty?

      remaining = @sequences.dup
      current = remaining.shift
      current, remaining = merge_all(current, remaining)
      [current, *remaining]
    end

    private

    def merge_all(current, remaining)
      until remaining.empty?
        found = find_connection(current, remaining)
        break unless found

        remaining.delete(found[:seq])
        current = found[:merged]
      end
      [current, remaining]
    end

    def find_connection(current, sequences)
      sequences.each do |seq|
        merged = try_merge(current, seq)
        return { seq: seq, merged: merged } if merged
      end
      nil
    end

    def try_merge(current, seq)
      MERGE_STRATEGIES.each do |strategy|
        result = strategy.call(current, seq)
        return result if result
      end
      nil
    end
  end
end
