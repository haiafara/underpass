# frozen_string_literal: true

require 'spec_helper'
require 'underpass'

describe Underpass::ErrorParser do
  describe '.parse' do
    context 'with timeout errors' do
      let(:html_body) do
        <<~HTML
          <html>
          <head><title>504 Gateway Timeout</title></head>
          <body>
          <strong style="color:#FF0000">runtime error: Query timed out in "query" at line 3 after 25 seconds.</strong>
          </body>
          </html>
        HTML
      end

      it 'parses timeout error from HTML response' do
        result = described_class.parse(html_body, 504)

        expect(result[:code]).to eq('timeout')
        expect(result[:message]).to include('Query timed out')
        expect(result[:details]).to eq({ line: 3, timeout_seconds: 25 })
      end

      it 'extracts line number and timeout duration' do
        result = described_class.parse(html_body, 504)

        expect(result[:details][:line]).to eq(3)
        expect(result[:details][:timeout_seconds]).to eq(25)
      end
    end

    context 'with memory errors' do
      let(:html_body) do
        <<~HTML
          <html>
          <body>
          <strong>runtime error: Query run out of memory using about 512 MB of RAM.</strong>
          </body>
          </html>
        HTML
      end

      it 'parses memory error from HTML response' do
        result = described_class.parse(html_body, 504)

        expect(result[:code]).to eq('memory')
        expect(result[:message]).to include('Query run out of memory')
        expect(result[:details]).to eq({ memory_mb: 512 })
      end
    end

    context 'with syntax errors' do
      let(:html_body) do
        <<~HTML
          <html>
          <body>
          <strong>parse error: Unknown type "nod" on line 2</strong>
          </body>
          </html>
        HTML
      end

      it 'parses syntax error from HTML response' do
        result = described_class.parse(html_body, 400)

        expect(result[:code]).to eq('syntax')
        expect(result[:message]).to include('Unknown type "nod"')
        expect(result[:details]).to eq({ line: 2 })
      end

      context 'without line number' do
        let(:html_body) { '<strong>parse error: Unexpected token</strong>' }

        it 'returns empty details when no line number present' do
          result = described_class.parse(html_body, 400)

          expect(result[:code]).to eq('syntax')
          expect(result[:details]).to eq({})
        end
      end
    end

    context 'with runtime errors' do
      let(:html_body) do
        '<strong>runtime error: Area query failed</strong>'
      end

      it 'parses generic runtime error from HTML response' do
        result = described_class.parse(html_body, 500)

        expect(result[:code]).to eq('runtime')
        expect(result[:message]).to eq('Area query failed')
        expect(result[:details]).to eq({})
      end
    end

    context 'with rate limit errors' do
      it 'returns rate_limit code for 429 status' do
        result = described_class.parse('Rate limited', 429)

        expect(result[:code]).to eq('rate_limit')
        expect(result[:message]).to eq('Rate limited by the Overpass API')
        expect(result[:details]).to eq({})
      end

      it 'ignores response body for 429 status' do
        result = described_class.parse('<html>Some other content</html>', 429)

        expect(result[:code]).to eq('rate_limit')
      end
    end

    context 'with unknown errors' do
      it 'returns unknown code for unrecognized HTML' do
        result = described_class.parse('<html><body>Something went wrong</body></html>', 500)

        expect(result[:code]).to eq('unknown')
        expect(result[:message]).to include('Something went wrong')
        expect(result[:details]).to eq({})
      end

      it 'handles empty response body' do
        result = described_class.parse('', 500)

        expect(result[:code]).to eq('unknown')
        expect(result[:message]).to eq('HTTP 500 error')
        expect(result[:details]).to eq({})
      end

      it 'handles nil response body' do
        result = described_class.parse(nil, 500)

        expect(result[:code]).to eq('unknown')
        expect(result[:message]).to eq('HTTP 500 error')
      end
    end

    context 'with non-HTML responses' do
      it 'parses plain text error messages' do
        result = described_class.parse('runtime error: Query failed', 500)

        expect(result[:code]).to eq('runtime')
        expect(result[:message]).to eq('Query failed')
      end

      it 'handles plain text timeout messages' do
        result = described_class.parse('Query timed out in "query" at line 5 after 30 seconds.', 504)

        expect(result[:code]).to eq('timeout')
        expect(result[:details]).to eq({ line: 5, timeout_seconds: 30 })
      end
    end

    context 'with error text in <p> tags' do
      let(:html_body) do
        '<html><body><p>runtime error: Connection refused</p></body></html>'
      end

      it 'extracts error from <p> tags when <strong> not present' do
        result = described_class.parse(html_body, 500)

        expect(result[:code]).to eq('runtime')
        expect(result[:message]).to eq('Connection refused')
      end
    end
  end
end
