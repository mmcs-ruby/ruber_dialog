module RuberDialog
  #
  class Dialog
    attr_accessor :starting_node, :nodes, :characters

    def initialize(starting_node, nodes, characters)
      @starting_node, @nodes, @characters = starting_node, nodes, characters
    end

    def as_json(options = {})
      {
        starting_node: starting_node.to_json,
        nodes: nodes.each do |node|
          node.to_json
        end,
        characters: characters
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end