# frozen_string_literal: true

module RuberDialog
  module Parser
    # Character Token class for parsing
    class Character
      attr_reader :name

      def initialize(name)
        throw ArgumentError unless name.is_a?(String)
        @name = name
      end

      def to_s
        @name
      end

      def ==(other)
        @name == other.name
      end
    end
  end
end
