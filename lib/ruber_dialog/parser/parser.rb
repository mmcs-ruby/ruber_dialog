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

      # takes block to create error message, puts forbidden expression inside
      def validate_forbidden_expressions(content, &block)
        errors = []

        @forbidden_expressions.each do |expression|
          if content&.include?(expression)
            errors << ValidationError.new(content.index(expression), block.call(expression))
          end
        end
        errors
      end

      # takes block to create error message, puts reserved name inside
      def validate_reserved_names(content, &block)
        errors = []

        @reserved_names.each do |reserved_name|
          # start_with? because reserved name should be found without any splitting
          errors << ValidationError.new(0, block.call(reserved_name)) if content&.start_with?(reserved_name)
        end
        errors
      end

      protected :validate_forbidden_expressions, :validate_reserved_names

      # for setting up error messages in inheritors

      def setup_reserved_name_error(&block)
        @reserved_name_error = block
      end

      def setup_forbidden_expression_error(&block)
        @forbidden_expression_error = block
      end

      protected :setup_forbidden_expression_error, :setup_reserved_name_error

      def validate(content)
        errors = validate_forbidden_expressions(content) { |expr| @forbidden_expression_error.call(expr) }
        errors_reserved_names = validate_reserved_names(content) { |name| @reserved_name_error.call(name) }
        errors.push(*errors_reserved_names)
        errors.sort_by(&:position)
      end

      def parse(content)
        raise NotImplementedError("You have to implement parse for a TokenParser inheritor")
      end
    end
  end
end
