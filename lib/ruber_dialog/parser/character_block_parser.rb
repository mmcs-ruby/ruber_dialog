# frozen_string_literal: true

require_relative "errors"
require_relative "tokens"
require_relative "character_parser"
module RuberDialog
  module Parser
    # class for parsing block of Characters
    class CharacterBlockParser
      attr_reader :block_name, :reserved_name, :forbidden_expressions
      attr_accessor :separator

      def initialize(block_name: "Characters:", reserved_name: "Description", forbidden_expressions: %w({ [ ] }))
        @block_name = block_name
        @reserved_name = reserved_name
        @forbidden_expressions = forbidden_expressions
        @character_parser = CharacterParser.new(forbidden_expressions: forbidden_expressions,
                                                reserved_names: [reserved_name, block_name])
        @lines_offset = 0
        @separator = "\n"
      end

      def lines_offset=(offset)
        raise ArgumentError("offset cannot be negative") if offset.negative?

        @lines_offset = offset
      end

      def character_line_number(index)
        @lines_offset + index + 2
      end
      private :character_line_number

      def validate(characters_string)
        errors = Hash.new { |hash, key| hash[key] = [] }
        unless characters_string.start_with?(@block_name)
          errors[@lines_offset + 1] = [ValidationError.new(0, "No character block definition")]
        end

        char_lines = characters_string[@block_name.length..]&.split @separator
        char_lines.each_with_index do |line, i|
          line_errors = @character_parser.validate(line)
          errors[character_line_number(i)].push(*line_errors)
        end
        errors
      end

      def parse(characters_string)
        unless characters_string.start_with?(@block_name)
          raise ParsingError.new(@lines_offset + 1, "No character block definition")
        end

        char_lines = characters_string[@block_name.length..]&.split @separator
        char_lines&.map { |char_line| @character_parser.parse(char_line) }
      end
    end
  end
end
