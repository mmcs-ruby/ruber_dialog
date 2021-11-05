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

      # data class for ordering validation errors
      # not supposed to be used somewhere else
      class ValidationErrorServiceData
        attr_reader :position, :line, :error_msg, :validation_error

        def initialize(validation_error, position = 0)
          @position = position
          @line = validation_error.local_line
          @error_msg = validation_error.error
          @validation_error = validation_error
        end

        def <=>(other)
          return -1 if @line < other.line || @position < other.position
          return 0 if @line == other.line && @position == other.position && @error_msg == other.error_msg

          1
        end
      end

      # searches for forbidden expressions in a line, returns ValidationError
      def validate_forbidden_expressions(content, local_line)
        errors = []

        @forbidden_expressions.each do |expression|
          next unless content&.include?(expression)

          local_position = content.index expression
          validation_error = ValidationError.new(forbidden_expression_error(expression), local_line)
          errors << ValidationErrorServiceData.new(validation_error, local_position)
        end
        errors
      end

      # searches for reserved names in a line, returns ValidationError
      def validate_reserved_names(content, local_line)
        errors = []

        @reserved_names.each do |reserved_name|
          # start_with? because reserved name should be found without any splitting
          next unless content&.start_with?(reserved_name)

          validation_error = ValidationError.new(reserved_name_error(reserved_name), local_line)
          errors << ValidationErrorServiceData.new(validation_error, 0)
        end
        errors
      end

      protected :validate_forbidden_expressions, :validate_reserved_names

      # splits content to lines, validate each line and put errors together
      # returns Array of ValidationError
      def validate(content)
        errors = []
        lines = content.split "\n"
        lines.each_with_index do |line, index|
          errors_forbidden = validate_forbidden_expressions(line, index + 1)
          errors_reserved_names = validate_reserved_names(line, index + 1)
          errors.push(*errors_forbidden)
          errors.push(*errors_reserved_names)
        end
        errors.sort.map(&:validation_error)
      end

      def parse(content)
        raise NotImplementedError("parse must be implemented for a TokenParser inheritor")
      end
    end
  end
end
