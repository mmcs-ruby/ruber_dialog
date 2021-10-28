# frozen_string_literal: true

require "test_helper"

class TokensTest < Minitest::Test
  include RuberDialog::Parser::Tokens

  def test_character_token_attributes
    character = Character.new("Gandalf")
    assert_equal "Gandalf", character.name
  end

  def test_character_token_to_s
    character = Character.new("Gandalf")
    assert_equal "Gandalf", character.to_s
  end

  def test_character_has_eq_operator
    character = Character.new("Gandalf")
    assert_equal character, Character.new("Gandalf")
  end
end
