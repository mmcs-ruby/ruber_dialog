# frozen_string_literal: true

require_relative "errors"
require_relative "tokens"
require_relative "character_parser"
require_relative "block_parser"

module RuberDialog
  module Parser
    # class for parsing block of Characters
    class CharacterBlockParser < BlockParser
      attr_reader :block_name, :reserved_name, :forbidden_expressions
      attr_accessor :separator

      def initialize(starting_line: 1, block_name: "Characters:", reserved_names: ["Description"],
                     forbidden_expressions: %w({ [ ] }), separator: "\n")
        @block_name = block_name
        reserved_names = reserved_names.clone
        reserved_names << block_name
        character_parser = CharacterParser.new(forbidden_expressions: forbidden_expressions,
                                               reserved_names: reserved_names)
        @separator = separator
        @skipped_lines = block_name.count "\n" # number of lines to be skipped before first character info
        super(forbidden_expressions, reserved_names,
              starting_line: starting_line, token_parser: character_parser)
      end

      # overrides lines_offset in BlockParser
      def lines_offset
        super + @skipped_lines
      end

      # for validation and parsing
      def split_to_token_contents(characters_content)
        contents = characters_content[@block_name.length..]&.split @separator
        separator_line_breaks = @separator.count "\n"
        token_contents = []
        contents.each do |content|
          content_lines = content.count("\n") + separator_line_breaks
          token_contents << TokenContent.new(content, content_lines)
        end
        token_contents
      end

      # validates characters block, returns hash<line number, ValidationError>
      def validate(characters_string)
        errors = Hash.new { |hash, key| hash[key] = [] }
        unless characters_string.start_with?(@block_name)
          errors[@starting_line] = [ValidationError.new("No character block definition", @starting_line)]
        end

        super_errors = super(characters_string)
        errors.merge(super_errors) { |_key, old_val, new_val| old_val.push(*new_val) }
      end

      # parses characters block, returns list of Character
      def parse(characters_string)
        unless characters_string.start_with?(@block_name)
          raise ParsingError.new(@starting_line, "No character block definition")
        end

        char_lines = split_to_token_contents characters_string
        char_lines&.map { |char_content| @token_parser.parse(char_content.content) }
      end
    end
  end
end
