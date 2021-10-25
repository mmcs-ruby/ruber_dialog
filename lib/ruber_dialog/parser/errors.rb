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
