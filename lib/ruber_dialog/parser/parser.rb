# frozen_string_literal: true

module RuberDialog
  # module for character block parsing
  module Parser
    # basic class for parsing errors in dialog files, contains info about line number
    class ParsingError < StandardError
      attr_reader :line

      def initialize(line = nil, msg = nil)
        @line = line
        @msg = msg
        super msg
      end

      def to_s
        "#{@line}: #{@msg}"
      end
    end

    # low level validation error, contains info about all errors during content validation
    class ValidationError
      attr_reader :position, :error

      def initialize(position, error)
        raise ArgumentError, "Error position cannot be negative" if position.negative?

        @position = position
        @error = error
      end

      def to_s
        "#At (#{@position}): '#{@error}'"
      end

      def ==(other)
        @position == other.position && @error == other.error
      end
    end
  end
end
