# frozen_string_literal: true

require "test_helper"

class CharacterParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line = 1)
    ValidationError.new(err, line)
  end

  def test_character_parser_validation_reserved_names
    character_parser = CharacterParser.new(reserved_names: %w[Characters: Description])
    assert_equal [val_err("Use of reserved name (Characters:) as a character name is forbidden")],
                 character_parser.validate("Characters:")
    assert_equal [val_err("Use of reserved name (Description) as a character name is forbidden")],
                 character_parser.validate("Description")
  end

  def test_character_parser_validation_starting_with_reserved_names
    character_parser = CharacterParser.new(reserved_names: %w[Characters: Description])
    assert_equal [val_err("Use of reserved name (Characters:) as a character name is forbidden")],
                 character_parser.validate("Characters:Character1")
  end

  def test_character_parser_validates_one_forbidden_expression_in_middle
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'")], character_parser.validate("Gand{alf")
    assert_equal [val_err("Forbidden symbol '['")], character_parser.validate("Gan[dalf")
    assert_equal [val_err("Forbidden symbol ']'")], character_parser.validate("Ganda]lf")
    assert_equal [val_err("Forbidden symbol '}'")], character_parser.validate("Gand}alf")
  end

  def test_character_parser_validates_one_forbidden_expression_in_left
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'")], character_parser.validate("{Gandalf")
    assert_equal [val_err("Forbidden symbol '}'")], character_parser.validate("}Gandalf")
    assert_equal [val_err("Forbidden symbol '['")], character_parser.validate("[Gandalf")
    assert_equal [val_err("Forbidden symbol ']'")], character_parser.validate("]Gandalf")
  end

  def test_character_parser_validates_one_forbidden_expression_in_right
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'")], character_parser.validate("Gandalf{")
    assert_equal [val_err("Forbidden symbol '}'")], character_parser.validate("Gandalf}")
    assert_equal [val_err("Forbidden symbol '['")], character_parser.validate("Gandalf[")
    assert_equal [val_err("Forbidden symbol ']'")], character_parser.validate("Gandalf]")
  end

  def test_character_parser_validates_multiple_forbidden_expressions_middle
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '}'"), val_err("Forbidden symbol '['"),
                  val_err("Forbidden symbol ']'")],
                 character_parser.validate("F}[ro]do")
  end

  def test_character_parser_validates_multiple_forbidden_expression_around
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol ']'"), val_err("Forbidden symbol '{'")],
                 character_parser.validate("]name{")
  end

  def test_character_parser_validates_multiple_forbidden_expressions_left_middle
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'"), val_err("Forbidden symbol '}'"), val_err("Forbidden symbol '['")],
                 character_parser.validate("{Ga}nd[alf")
  end

  def test_character_parser_validates_multiple_forbidden_expressions_right_middle
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '['"), val_err("Forbidden symbol ']'")],
                 character_parser.validate("Ga[ndalf]")
  end

  def test_character_parser_validates_multiple_forbidden_expressions_mixed
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'"), val_err("Forbidden symbol '['"), val_err("Forbidden symbol '}'"),
                  val_err("Forbidden symbol ']'")],
                 character_parser.validate("{Ga[nda}lf]")
  end

  def test_character_parser_validates_repetitive_error_once
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '['")],
                 character_parser.validate("Ga[nd[[al[f")
  end

  def test_character_parser_validates_many_lines
    character_parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }))
    assert_equal [val_err("Forbidden symbol '{'", 1), val_err("Forbidden symbol '}'", 1),
                  val_err("Forbidden symbol '['", 2), val_err("Forbidden symbol ']'", 2)],
                 character_parser.validate("Fr{o}do\nBagg[i]ns")
  end

  def test_character_parser_parses_character
    character_parser = CharacterParser.new
    character = character_parser.parse("Gandalf")
    assert_instance_of Character, character
  end

  def test_character_parser_parser_parses
    character_parser = CharacterParser.new
    character = character_parser.parse("Gandalf")
    assert_equal Character.new("Gandalf"), character
  end
end
