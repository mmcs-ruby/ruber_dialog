# frozen_string_literal: true

module RuberDialog
  # module for character block parsing
  module Parser
    # basic class for errors during parsing in dialog files, contains info about line number
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

    # low level validation error, contains error message and number of line where the error was found during validation
    class ValidationError
      attr_reader :__position, :error
      attr_accessor :local_line

      def initialize(error, local_line = 1)
        raise ArgumentError, "Error line cannot be negative" if local_line.negative?

        @error = error
        @local_line = local_line
      end

      def to_s
        "#At line #{@local_line}: '#{@error}'"
      end

      # __position is not important
      def ==(other)
        @error == other.error && @local_line == other.local_line
      end
    end
  end
end
