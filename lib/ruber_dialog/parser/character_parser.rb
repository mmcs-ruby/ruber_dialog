# frozen_string_literal: true

require_relative "errors"
require_relative "tokens"
require_relative "parser"

module RuberDialog
  module Parser
    # Single Character parser from string
    class CharacterParser < TokenParser
      def initialize(forbidden_expressions: [], reserved_names: [])
        setup_forbidden_expression_error { |fe| "Forbidden symbol '#{fe}'" }
        setup_reserved_name_error { |rn| "Use of reserved name (#{rn}) as a character name is forbidden" }
        super(forbidden_expressions, reserved_names)
      end

      def parse(content)
        raise ArgumentError unless content.is_a?(String)

        Character.new(content)
      end
    end
  end
end

