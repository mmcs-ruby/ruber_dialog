require 'json'

module RuberDialog
  module DialogParts
    # The class of the minimal dialogue part, final or including one or more forks
    class Node
      attr_accessor :name, :lines, :responses

      def initialize(name, lines, responses)
        @name, @lines, @responses = name, lines, responses
      end

      def as_json(options = {})
        {
          name: @name,
          lines: @lines,
          responses: @responses
        }
      end

      private :as_json

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end