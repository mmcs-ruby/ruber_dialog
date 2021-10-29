module RuberDialog
  # Class of the single node - minimal part of the dialog
  class Node
    def initialize (name, lines, responses)
      @name, @lines, @responses = name, lines, responses
    end
  end
end