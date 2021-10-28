# frozen_string_literal: true

require "test_helper"

class CharacterBlockParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line)
    ValidationError.new(err, line)
  end

  def test_character_block_parser_has_methods
    character_parser = CharacterBlockParser.new
    assert_respond_to character_parser, :parse
    assert_respond_to character_parser, :validate
    assert_respond_to character_parser, :starting_line=
    assert_respond_to character_parser, :separator=
    assert_respond_to character_parser, :separator
    assert_respond_to character_parser, :forbidden_expressions
    assert_respond_to character_parser, :block_name
    assert_respond_to character_parser, :reserved_name
  end

  def test_character_block_parser_returns_characters
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    res = character_parser.parse("Chars:\nTest")
    assert_instance_of Array, res
    assert_equal 1, res.length
    assert_instance_of Character, res[0]
  end

  def test_character_block_parser_parses
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    tokens = character_parser.parse("Chars:\nGandalf\nFrodo\n")
    assert_equal [Character.new("Gandalf"), Character.new("Frodo")], tokens
    tokens = character_parser.parse("Chars:\nGandalf\n")
    assert_equal [Character.new("Gandalf")], tokens
  end

  def test_character_block_parser_parses_empty
    character_parser = CharacterBlockParser.new(block_name: "Chars:\n")
    tokens = character_parser.parse("Chars:\n")
    assert_empty tokens
    tokens = character_parser.parse("Chars:\n\n\n")
    assert_empty tokens
  end

  def test_character_block_parser_validates_forbidden_expressions
    character_block_parser = CharacterBlockParser.new(block_name: "Chars:\n", forbidden_expressions: %w({ [ ] }))
    errors = character_block_parser.validate("Chars:\nFrodo}\n")
    assert_empty errors[1]
    assert_equal [val_err("Forbidden symbol '}'", 2)], errors[2]
    errors = character_block_parser.validate("Chars:\n{Frodo\nGan]da[lf}\n[Me\nNormal Name")
    assert_empty errors[1]
    assert_equal [val_err("Forbidden symbol '{'", 2)], errors[2]
    assert_equal [val_err("Forbidden symbol ']'", 3), val_err("Forbidden symbol '['", 3),
                  val_err("Forbidden symbol '}'", 3)], errors[3]
    assert_equal [val_err("Forbidden symbol '['", 4)], errors[4]
    assert_empty errors[5]
  end

  def test_character_block_parser_validates_reserved_words
    character_parser = CharacterBlockParser.new(block_name: "Chars:", reserved_names: ["Desc"])
    errors = character_parser.validate("Chars:Gandalf\nChars:\n")
    assert_empty errors[1]
    assert_equal [val_err("Use of reserved name (Chars:) as a character name is forbidden", 2)], errors[2]

    errors = character_parser.validate("Chars:Gandalf\nDesc")
    assert_empty errors[1]
    assert_equal [val_err("Use of reserved name (Desc) as a character name is forbidden", 2)], errors[2]
  end

  def test_character_block_parser_throws_error
    character_parser = CharacterBlockParser.new(block_name: "Chars:")
    assert_raises(ParsingError) do |err|
      character_parser.parse("\nGandalf\nDescription")
      assert_equal "1: No character block definition", err.to_s
    end
  end

  def test_character_block_parser_works_with_different_separators
    characters_block_parser = CharacterBlockParser.new(forbidden_expressions: %w({ [ ] }),
                                                       starting_line: 20, separator: ";")
    errors = characters_block_parser.validate("Characters:Gan{dalf;\n{Frodo\nBag}gins;Bi{lbo;Desc}ription\n")
    assert_equal [val_err("Forbidden symbol '{'", 20)], errors[20]
    assert_equal [val_err("Forbidden symbol '{'", 21)], errors[21]
    assert_equal [val_err("Forbidden symbol '}'", 22),
                  val_err("Forbidden symbol '{'", 22),
                  val_err("Forbidden symbol '}'", 22)], errors[22]
    characters_block_parser.separator = "\n[sep]\n"
    characters_block_parser.starting_line = 10
    errors = characters_block_parser.validate("Characters:Gan{dalf\n[sep]\nFro}do\nBaggi[ns\n[sep]\nDescription")
    assert_equal [val_err("Forbidden symbol '{'", 10)], errors[10]
    assert_empty errors[11]
    assert_equal [val_err("Forbidden symbol '}'", 12)], errors[12]
    assert_equal [val_err("Forbidden symbol '['", 13)], errors[13]
    assert_empty errors[14]
    assert_equal [val_err("Use of reserved name (Description) as a character name is forbidden", 15)], errors[15]
  end
end
