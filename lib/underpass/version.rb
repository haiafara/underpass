# frozen_string_literal: true

module Underpass
  # The version module. Set the gem version from the constants.
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 5

    def self.version_string
      [Version::MAJOR, Version::MINOR, Version::PATCH].join('.')
    end
  end
end
