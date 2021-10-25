# frozen_string_literal: true

require_relative "parser"
require_relative "errors"

module RuberDialog
  module Parser
    # dataclass for parsing, contains information about parsable string and count of lines
    class TokenContent
      attr_reader :content, :lines

      def initialize(content, lines)
        @content = content
        @lines = lines
      end
    end

    # General class for parsing a block
    class BlockParser
      attr_reader :forbidden_expressions, :reserved_names

      def initialize(forbidden_expressions, reserved_names, starting_line: 1, token_parser: nil)
        @forbidden_expressions = forbidden_expressions
        @reserved_names = reserved_names
        @token_parser = token_parser
        @starting_line = starting_line
      end

      def starting_line=(starting_line)
        raise ArgumentError("starting line cannot be negative") if starting_line.negative?

        @starting_line = starting_line
      end

      # returns list of TokenContent
      def split_to_token_contents(content)
        raise NotImplementedError("split_to_token_contents must be implemented for validation and parsing")
      end

      # returns token_errors with proper line numbers
      def token_errors(token_content, lines_offset)
        token_errors = @token_parser.validate(token_content)
        token_errors.each { |err| err.local_line += lines_offset }
        token_errors
      end

      def lines_offset
        @starting_line - 1
      end

      private :token_errors

      def validate(content)
        errors = Hash.new { |hash, key| hash[key] = [] }

        contents = split_to_token_contents(content)
        offset = lines_offset
        contents.each do |token_content|
          token_errors = token_errors(token_content.content, offset)
          token_errors.each { |err| errors[err.local_line] << err }
          line_breaks_count = token_content.lines
          offset += line_breaks_count
        end
        errors
      end
    end
  end
end
