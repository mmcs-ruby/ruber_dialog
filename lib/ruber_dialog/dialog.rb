require 'json'

module RuberDialog
  module DialogParts
    # The class of all possible conversation forks
    class Dialog
      attr_accessor :starting_node, :nodes, :characters, :final_nodes_names

      def initialize(starting_node, nodes, characters, final_nodes_names)
        @starting_node, @nodes, @characters, @final_nodes_names = starting_node, nodes, characters, final_nodes_names
      end

      def as_json(options = {})
        {
          starting_node: @starting_node,
          nodes: @nodes,
          characters: @characters,
          final_nodes_names: @final_nodes_names
        }
      end

      private :as_json

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end