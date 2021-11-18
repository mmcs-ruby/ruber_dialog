# frozen_string_literal: true

require_relative "errors"
require_relative "tokens"
require_relative "parser"

module RuberDialog
  module Parser
    # Single Description parser from string
    class DescriptionLineParser < TokenParser
      include Parser::Tokens

      # @param forbidden_expressions [String/RegExpr], expressions that are not supposed to be inside description
      # @param reserved_names [String], reserved names such as "Description"
      def initialize(forbidden_expressions: [], reserved_names: ["{Description}"])
        super(forbidden_expressions, reserved_names)
      end

      def forbidden_expression_error(expression)
        "Forbidden symbol '#{expression}'"
      end

      def reserved_name_error(name)
        "Use of reserved name (#{name}) as a description name is forbidden"
      end


      protected :forbidden_expression_error, :reserved_name_error

      #Input requirements for the description string:
      # 1.Character name starts with an uppercase letter, includes only letters,
      # mixing uppercase and lowercase is not allowed
      # 2.Content inside parentheses'{}' starts with an uppercase letter,
      # includes only letters, mixing uppercase and lowercase is not allowed
      # 3.Only one character name is expected
      # 4.Only one pair of braces '{}' is allowed
      # 5.Only one description line('Description:...') is allowed
      def validate(content)
        name_regexp = /^(?!Description)[A-Z][a-z]+:/
        start_regexp = /^{[A-Z][a-z]+}$/
        desc_line_regexp = /^{[A-Z][a-z]+}\n^Description: /

        unless content.match?(start_regexp)
          raise ParsingError.new("Failed to parse start of description for\n'#{content}'")
        end

        unless content.match?(name_regexp)
          raise ParsingError.new("Failed to parse character name for\n'#{content}'")
        end

        unless content.match?(desc_line_regexp)
          raise ParsingError.new("Failed to parse start of description line for\n'#{content}'")
        end

        desc_line_count = content.scan(/^Description: /).length
        unless desc_line_count == 1
          raise ParsingError.new("Only one description line expected but found #{desc_line_count} for\n'#{content}'")
        end

        names_count = content.scan(name_regexp).length
        unless names_count == 1
          raise ParsingError.new("Only one character name expected but found #{names_count} for\n'#{content}'")
        end

        unless content.count("{") == 1 and content.count("}") == 1
          raise ParsingError.new(msg = "Only one pair of '{}' is allowed for\n'#{content}'")
        end
        super(content)
      end
      # parses string into Line
      def parse(content)
        raise RuberArgumentError unless content.is_a?(String)
        self.validate(content)
        character_name=content.match(/^(?!Description)\w+:/).to_s[0...-1]
        content = content.gsub(/\A\n+/,"") #removes newline characters before the start of the content
        Line.new(character_name, content)
      end
    end
  end
end