# frozen_string_literal: true

# Returns the version of the gem as a <tt>Gem::Version</tt>
module Underpass
  # Prints the gem version as a string
  #
  # @return [String]
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  # Used to generate the version string
  module VERSION
    MAJOR = 0
    MINOR = 0
    PATCH = 5

    STRING = [MAJOR, MINOR, PATCH].join('.')
  end
end
