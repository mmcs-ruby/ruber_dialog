require 'json'

module RuberDialog
  module DialogParts
    # Class of the single node - minimal part of the dialog
    class Node
      attr_accessor :name, :lines, :responses

      def initialize (name, lines, responses)
        @name, @lines, @responses = name, lines, responses
      end

      def as_json(options = {})
        {
          name: @name,
          lines: @lines.each do |line|
            line.to_json
          end,
          responses: @responses
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end