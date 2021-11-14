module RuberDialog
  module DialogParts
    include Parser
    # This class matches character names and responses to nodes
    class Resolver
      attr_accessor :nodes_map, :chars_map

      def initialize
        @nodes_map = {}
        @chars_map = {}
      end

      # ensure that each character's name from chars list is in the names list
      def validate_characters(names, chars)
        chars.each do |char|
          raise ValidationError unless names.include? char.name

          @chars_map[char.name] = char
        end
      end

      # map nodes to their names
      def resolve_nodes(nodes)
        nodes.each do |node|
          @nodes_map[node.name] = node
        end
      end

      # ensure that every responce leads to a valid node
      def validate_nodes
        @nodes_map.each do |_, v|
          v.each do |r|
            raise ValidationError unless @nodes_map.include? r.next_node
          end
        end
      end
    end
  end
end
