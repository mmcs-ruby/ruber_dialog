# frozen_string_literal: true

require "test_helper"

class CharacterBlockParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line)
    ValidationError.new(err, line)
  end

  def test_character_block_parser_returns_characters
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\nTest")
    assert_instance_of Character, res[0]
  end

  def test_character_block_parser_returns_one_character
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\nTest")
    assert_equal 1, res.length
  end

  def test_character_block_parser_returns_multiple_characters
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\nTest1\nTest2")
    assert_equal 2, res.length
  end

  def test_character_block_parser_parses_empty
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\n")
    assert_empty res
  end

  def test_character_block_parser_parses_multiple_empty_lines
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\n\n\n")
    assert_empty res
  end

  def test_character_block_parser_parses
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    tokens = character_parser.parse("Chars:\nGandalf\nFrodo\n")
    assert_equal [Character.new("Gandalf"), Character.new("Frodo")], tokens
    tokens = character_parser.parse("Chars:\nGandalf\n")
    assert_equal [Character.new("Gandalf")], tokens
  end

  def test_character_block_parser_validates_one_forbidden_expressions
    character_block_parser = CharacterBlockParser.new(block_name: "Chars:\n", forbidden_expressions: %w({ [ ] }))
    errors = character_block_parser.validate("Chars:\nFrodo}\n")
    expected_errors = { 2 => [val_err("Forbidden symbol '}'", 2)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validate_multiple_forbidden_expressions
    character_block_parser = CharacterBlockParser.new(block_name: "Chars:\n", forbidden_expressions: %w({ [ ] }))
    errors = character_block_parser.validate("Chars:\n{Frodo\nGan]da[lf}\n[Me\nNormal Name")
    expected_errors = { 2 => [val_err("Forbidden symbol '{'", 2)],
                        3 => [val_err("Forbidden symbol ']'", 3), val_err("Forbidden symbol '['", 3),
                              val_err("Forbidden symbol '}'", 3)],
                        4 => [val_err("Forbidden symbol '['", 4)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_block_name
    character_parser = CharacterBlockParser.new(block_name: "Chars:", reserved_names: ["Desc"])
    errors = character_parser.validate("Chars:Gandalf\nChars:\n")
    expected_errors = { 2 => [val_err("Use of reserved name (Chars:) as a character name is forbidden", 2)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_reserved_names
    character_parser = CharacterBlockParser.new(block_name: "Chars:", reserved_names: ["Desc"])
    errors = character_parser.validate("Chars:Desc\nFrodo")
    expected_errors = { 1 => [val_err("Use of reserved name (Desc) as a character name is forbidden", 1)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_no_block_definition
    character_block_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    errors = character_block_parser.validate("Gandalf\nFrodo")
    expected_errors = { 1 => [val_err("No character block definition", 1)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_throws_parsing_error
    character_parser = CharacterBlockParser.new(block_name: "Chars:")
    assert_raises(ParsingError) do |err|
      character_parser.parse("\nGandalf\nDescription")
      assert_equal "1: No character block definition", err.to_s
    end
  end

  def test_character_block_parser_validates_one_character_many_lines
    characters_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }), separator: ";")
    errors = characters_block_parser.validate("Characters:Gan{dalf;\n{Frodo\nBag}gins;\nTe]st")
    expected_errors = { 1 => [val_err("Forbidden symbol '{'", 1)],
                        2 => [val_err("Forbidden symbol '{'", 2)],
                        3 => [val_err("Forbidden symbol '}'", 3)],
                        4 => [val_err("Forbidden symbol ']'", 4)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_many_characters_one_line
    character_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }), separator: ";")
    errors = character_block_parser.validate("Characters:\n{Frodo;\nBi{lbo;Sau}ron\nTest[")
    expected_errors = { 2 => [val_err("Forbidden symbol '{'", 2)],
                        3 => [val_err("Forbidden symbol '{'", 3), val_err("Forbidden symbol '}'", 3)],
                        4 => [val_err("Forbidden symbol '['", 4)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_with_multiple_lines_separator
    character_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }), separator: "\n[sep]\n")
    errors = character_block_parser.validate("Characters:Gan{dalf\n[sep]\nFro}do\nBaggi[ns\n[sep]\nDescription")
    expected_errors = { 1 => [val_err("Forbidden symbol '{'", 1)],
                        3 => [val_err("Forbidden symbol '}'", 3)],
                        4 => [val_err("Forbidden symbol '['", 4)],
                        6 => [val_err("Use of reserved name (Description) as a character name is forbidden", 6)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_with_multiple_lines_separator_set
    character_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }))
    character_block_parser.separator = "\n[sep]\n"
    errors = character_block_parser.validate("Characters:Gan{dalf\n[sep]\nFro}do\nBaggi[ns\n[sep]\nDescription")
    expected_errors = { 1 => [val_err("Forbidden symbol '{'", 1)],
                        3 => [val_err("Forbidden symbol '}'", 3)],
                        4 => [val_err("Forbidden symbol '['", 4)],
                        6 => [val_err("Use of reserved name (Description) as a character name is forbidden", 6)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_with_starting_line
    character_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }), reserved_names: ["Desc"],
                                                      starting_line: 20, separator: "\n")
    errors = character_block_parser.validate("Characters:\n{Frodo\nGan]da[lf}\nDesc\nNormal Name")
    expected_errors = { 21 => [val_err("Forbidden symbol '{'", 21)],
                        22 => [val_err("Forbidden symbol ']'", 22), val_err("Forbidden symbol '['", 22),
                               val_err("Forbidden symbol '}'", 22)],
                        23 => [val_err("Use of reserved name (Desc) as a character name is forbidden", 23)] }
    assert_equal expected_errors, errors
  end

  def test_character_block_parser_validates_with_starting_line_set
    character_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }), reserved_names: ["Desc"],
                                                      separator: "\n")
    character_block_parser.starting_line = 20
    errors = character_block_parser.validate("Characters:\n{Frodo\nGan]da[lf}\nDesc\nNormal Name")
    expected_errors = { 21 => [val_err("Forbidden symbol '{'", 21)],
                        22 => [val_err("Forbidden symbol ']'", 22), val_err("Forbidden symbol '['", 22),
                               val_err("Forbidden symbol '}'", 22)],
                        23 => [val_err("Use of reserved name (Desc) as a character name is forbidden", 23)] }
    assert_equal expected_errors, errors
  end
end
