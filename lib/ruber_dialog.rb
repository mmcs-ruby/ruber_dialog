# frozen_string_literal: true

require_relative "ruber_dialog/version"
require_relative "ruber_dialog/parser/errors"
require_relative "ruber_dialog/parser/tokens"
require_relative "ruber_dialog/parser/character_block_parser"
require_relative "ruber_dialog/parser/block_parser"
require_relative "ruber_dialog/parser/description_block_parser"
require_relative "ruber_dialog/parser/description_parser"

module RuberDialog
  class RuberArgumentError < ArgumentError; end
  # Your code goes here...
end
