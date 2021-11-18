# frozen_string_literal: true

require_relative "errors"
require_relative "tokens"
require_relative "description_parser"
require_relative "block_parser"

module RuberDialog
  module Parser
    # class for parsing block of Descriptions
    class DescriptionBlockParser < BlockParser
      attr_reader :block_start_regexp, :reserved_name, :forbidden_expressions
      attr_accessor :separator

      # @param starting_line Integer, line number where the blocks starts.
      # @param block_start_regexp RegularExpression, that matches start of a Description block
      # @param reserved_names [String], reserved names such as "Description"
      # @param forbidden_expressions [String/RegExpr], expressions that are not supposed to be inside description name
      # @param separator String/RegExpr, used to separate characters
      def initialize(starting_line: 1, block_start_regexp: /^{[A-Z][a-z]+}$/, reserved_names: ["{Description}"],
                     forbidden_expressions: %w( [ ] ), separator: "\n")
        @block_start_regexp = block_start_regexp
        reserved_names = reserved_names.clone
        description_parser = DescriptionLineParser.new(forbidden_expressions: forbidden_expressions,
                                               reserved_names: reserved_names)
        @separator = separator
        super(forbidden_expressions, reserved_names,
              starting_line: starting_line, token_parser: description_parser)
      end

      # for validation and parsing
      def split_to_token_contents(descriptions_content)
        contents = descriptions_content.split(@separator).reject { |c| c.empty? }
        token_contents = []
        new_desc = ""
        contents.each do |content|
          if content.match?(@block_start_regexp)
            unless new_desc.empty?
              token_contents << TokenContent.new(new_desc, new_desc.count('\n'))
              new_desc = ""
            end
          end
          new_desc += content + "\n"
        end
        token_contents << TokenContent.new(new_desc, new_desc.count('\n'))
      end

      # validates descriptions block, returns hash<line number, ValidationError>
      def validate(descriptions_string)
        errors = Hash.new { |hash, key| hash[key] = [] }
        unless descriptions_string.match?(@block_start_regexp)
          errors[@starting_line] = [ValidationError.new("No description block definition", @starting_line)]
        end

        super_errors = super(descriptions_string)
        errors.merge(super_errors) { |_key, old_val, new_val| old_val.push(*new_val) }
      end

      # parses descriptions block, returns list of Description
      def parse(descriptions_string)
        unless descriptions_string.match?(@block_start_regexp)
          raise ParsingError.new(@starting_line, "No description block definition")
        end

        desc_lines = split_to_token_contents descriptions_string
        desc_lines.map { |desc_content| @token_parser.parse(desc_content.content) }
      end
    end
  end
end