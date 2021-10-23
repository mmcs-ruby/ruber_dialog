# frozen_string_literal: true

require_relative "parser"
require_relative "tokens"

module RuberDialog
  module Parser
    # single character parser from string
    class CharacterParser
      attr_accessor :forbidden_expressions, :reserved_names

      def initialize(forbidden_expressions: [], reserved_names: [])
        @forbidden_expressions = forbidden_expressions
        @reserved_names = reserved_names
      end

      def validate_forbidden_expressions(content)
        errors = []

        @forbidden_expressions.each do |expression|
          if content&.include?(expression)
            errors << ValidationError.new(content.index(expression), "Forbidden symbol '#{expression}'")
          end
        end
        errors
      end

      def validate_reserved_names(content)
        errors = []

        @reserved_names.each do |reserved_name|
          if content&.start_with?(reserved_name)
            errors << ValidationError.new(0, "Use of reserved name (#{reserved_name}) as a character name is forbidden")
          end
        end
        errors
      end

      private :validate_forbidden_expressions, :validate_reserved_names

      def validate(content)
        errors = validate_forbidden_expressions(content)
        errors_reserved_names = validate_reserved_names(content)
        errors.push(*errors_reserved_names)
        errors.sort_by(&:position)
      end

      def parse(content)
        raise ArgumentError unless content.is_a?(String)

        Character.new(content)
      end
    end
  end
end

