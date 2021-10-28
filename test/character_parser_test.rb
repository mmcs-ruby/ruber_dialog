# frozen_string_literal: true

require "test_helper"

class CharacterParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line = 1)
    ValidationError.new(err, line)
  end

  def test_character_parser_has_methods
    character_parser = CharacterParser.new
    assert_respond_to character_parser, :parse
    assert_respond_to character_parser, :validate
  end

  def test_character_parser_validation_reserved_names
    character_parser = CharacterParser.new(reserved_names: %w[Characters: Description])
    assert_equal [val_err("Use of reserved name (Characters:) as a character name is forbidden")],
                 character_parser.validate("Characters:")
    assert_equal [val_err("Use of reserved name (Description) as a character name is forbidden")],
                 character_parser.validate("Description")
  end

  def test_character_parser_validation_forbidden_expressions
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'")], character_parser.validate("Gand{alf")
    assert_equal [val_err("Forbidden symbol '}'"), val_err("Forbidden symbol '['")],
                 character_parser.validate("F}[rodo")
    assert_equal [val_err("Forbidden symbol ']'"), val_err("Forbidden symbol '{'")],
                 character_parser.validate("]name{")
    assert_equal [val_err("Forbidden symbol '}'")], character_parser.validate("Gandalf}")
    assert_equal [val_err("Forbidden symbol '{'")], character_parser.validate("{Gandalf")
    assert_equal [val_err("Forbidden symbol '['"), val_err("Forbidden symbol ']'")],
                 character_parser.validate("[Gandalf]")
  end

  def test_character_parser_validates_many_lines
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'", 1), val_err("Forbidden symbol '}'", 1),
                  val_err("Forbidden symbol '['", 2), val_err("Forbidden symbol ']'", 2)],
                 character_parser.validate("Fr{o}do\nBagg[i]ns")
  end

  def test_character_parser_parses
    character_parser = CharacterParser.new
    character = character_parser.parse("Gandalf")
    refute_nil character
    assert_instance_of Character, character
    assert_equal "Gandalf", character.name
  end
end
