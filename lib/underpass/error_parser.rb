# frozen_string_literal: true

module Underpass
  # Parses HTML error responses from the Overpass API into structured data.
  #
  # The Overpass API returns HTML error pages when queries fail. This class
  # extracts error information from those responses and returns structured
  # hashes with code, message, and details.
  #
  # @example
  #   result = ErrorParser.parse("<html>...runtime error: Query timed out...</html>", 504)
  #   result[:code]    # => "timeout"
  #   result[:message] # => "Query timed out in \"query\" at line 3 after 25 seconds."
  #   result[:details] # => { line: 3, timeout_seconds: 25 }
  class ErrorParser
    # Known error patterns from Overpass API responses
    PATTERNS = {
      timeout: /Query timed out.*?at line (\d+) after (\d+) seconds/i,
      memory: /Query run out of memory.*?(\d+)\s*MB/i,
      syntax: /parse error:?\s*(.+)/i,
      runtime: /runtime error:?\s*(.+)/i
    }.freeze

    # Parses an error response body and returns structured error data.
    #
    # @param response_body [String] the raw response body (usually HTML)
    # @param status_code [Integer] the HTTP status code
    # @return [Hash] structured error data with :code, :message, and :details keys
    def self.parse(response_body, status_code)
      return rate_limit_result if status_code == 429

      text = extract_error_text(response_body)
      parse_error_text(text, status_code)
    end

    # Extracts error text from HTML or returns the body as-is.
    #
    # @param body [String] the response body
    # @return [String] the extracted error text
    def self.extract_error_text(body)
      return '' if body.nil? || body.empty?

      # Try to extract text from <strong> tags (common Overpass error format)
      if (match = body.match(%r{<strong[^>]*>(.*?)</strong>}im))
        return match[1].gsub(/<[^>]+>/, '').strip
      end

      # Try to extract from <p> tags
      if (match = body.match(%r{<p[^>]*>(.*?)</p>}im))
        return match[1].gsub(/<[^>]+>/, '').strip
      end

      # Fall back to stripping all HTML tags
      body.gsub(/<[^>]+>/, ' ').gsub(/\s+/, ' ').strip
    end
    private_class_method :extract_error_text

    # Parses the error text against known patterns.
    #
    # @param text [String] the extracted error text
    # @param status_code [Integer] the HTTP status code
    # @return [Hash] structured error data
    def self.parse_error_text(text, status_code)
      parse_timeout(text) ||
        parse_memory(text) ||
        parse_syntax(text) ||
        parse_runtime(text) ||
        unknown_result(text, status_code)
    end
    private_class_method :parse_error_text

    def self.parse_timeout(text)
      return unless (match = text.match(PATTERNS[:timeout]))

      { code: 'timeout', message: text, details: { line: match[1].to_i, timeout_seconds: match[2].to_i } }
    end
    private_class_method :parse_timeout

    def self.parse_memory(text)
      return unless (match = text.match(PATTERNS[:memory]))

      { code: 'memory', message: text, details: { memory_mb: match[1].to_i } }
    end
    private_class_method :parse_memory

    def self.parse_syntax(text)
      return unless (match = text.match(PATTERNS[:syntax]))

      { code: 'syntax', message: match[1].strip, details: extract_syntax_details(match[1]) }
    end
    private_class_method :parse_syntax

    def self.parse_runtime(text)
      return unless (match = text.match(PATTERNS[:runtime]))

      { code: 'runtime', message: match[1].strip, details: {} }
    end
    private_class_method :parse_runtime

    # Extracts line number from syntax error messages if present.
    #
    # @param message [String] the error message
    # @return [Hash] details hash with line number if found
    def self.extract_syntax_details(message)
      if (match = message.match(/line\s+(\d+)/i))
        { line: match[1].to_i }
      else
        {}
      end
    end
    private_class_method :extract_syntax_details

    # Returns a rate limit error result.
    #
    # @return [Hash] structured error data for rate limiting
    def self.rate_limit_result
      {
        code: 'rate_limit',
        message: 'Rate limited by the Overpass API',
        details: {}
      }
    end
    private_class_method :rate_limit_result

    # Returns an unknown error result.
    #
    # @param text [String] the error text
    # @param status_code [Integer] the HTTP status code
    # @return [Hash] structured error data for unknown errors
    def self.unknown_result(text, status_code)
      message = text.empty? ? "HTTP #{status_code} error" : text
      {
        code: 'unknown',
        message: message,
        details: {}
      }
    end
    private_class_method :unknown_result
  end
end
