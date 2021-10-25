# frozen_string_literal: true

require_relative "errors"

module RuberDialog
  module Parser
    # This is Abstract class. Contains general logic for validation and parsing tokens.
    # Do not use this class without inheritance
    class TokenParser
      attr_reader :forbidden_expressions, :reserved_names

      def initialize(forbidden_expressions, reserved_names)
        @forbidden_expressions = forbidden_expressions
        @reserved_names = reserved_names
      end

      # for setting up error messages

      def reserved_name_error(name)
        raise NotImplementedError("reserved_name_error must be implemented for validation")
      end

      def forbidden_expression_error(expression)
        raise NotImplementedError("forbidden_expression_error must be implemented for validation")
      end

      protected :reserved_name_error, :forbidden_expression_error

      # searches for forbidden expressions in a line, returns ValidationError
      def validate_forbidden_expressions(content, local_line)
        errors = []

        @forbidden_expressions.each do |expression|
          if content&.include?(expression)
            errors << ValidationError.new(content.index(expression), forbidden_expression_error(expression), local_line)
          end
        end
        errors
      end

      # searches for reserved names in a line, returns ValidationError
      def validate_reserved_names(content, local_line)
        errors = []

        @reserved_names.each do |reserved_name|
          # start_with? because reserved name should be found without any splitting
          if content&.start_with?(reserved_name)
            errors << ValidationError.new(0, reserved_name_error(reserved_name), local_line)
          end
        end
        errors
      end

      protected :validate_forbidden_expressions, :validate_reserved_names

      # splits content to lines, validate each line and put errors together
      def validate(content)
        errors = []
        lines = content.split "\n"
        lines.each_with_index do |line, index|
          errors_forbidden = validate_forbidden_expressions(line, index + 1)
          errors_reserved_names = validate_reserved_names(line, index + 1)
          errors.push(*errors_forbidden)
          errors.push(*errors_reserved_names)
        end
        errors.sort_by { |err| [err.local_line, err.position] }
      end

      def parse(content)
        raise NotImplementedError("parse must be implemented for a TokenParser inheritor")
      end
    end
  end
end
