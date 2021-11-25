# frozen_string_literal: true

require "test_helper"

class DescriptionBlockParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line)
    ValidationError.new(err, line)
  end

  def test_description_block_parser_returns_characters
    description_parser = DescriptionBlockParser.new
    res = description_parser.parse("{Test}\nDescription: test\nPerson: test\n{Goodbye}\nDescription: test\n
Person: test\n")
    assert_instance_of Line, res[0]
  end

  def test_description_block_parser_returns_one_line
    description_parser = DescriptionBlockParser.new
    res = description_parser.parse("{Test}\nDescription: test\nPerson: test")
    assert_equal 1, res.length
  end

  def test_description_block_parser_returns_multiple_lines
    description_parser = DescriptionBlockParser.new
    res = description_parser.parse("{Test}\nDescription: test\nPerson: test\n{Goodbye}\nDescription: test\n
Person: test\n")
    assert_equal 2, res.length
  end

  def description_block_parser_parses
    description_parser = DescriptionBlockParser.new
    tokens = description_parser.parse("{Test}\nDescription: test\nPerson: test\n{Goodbye}\nDescription: test\n
Peter: test\n")
    assert_equal [Line.new("Person","{Test}\nDescription: test\nPerson: test\n"),
                  Line.new("Peter","{Goodbye}\nDescription: test\nPeter: test\n")], tokens
  end

  def test_description_block_parser_validates_one_forbidden_expressions
    description_parser = DescriptionBlockParser.new(forbidden_expressions: %w( [ ] ))
    errors = description_parser.validate("{Test}\nDescription: ]test]\nPerson: test\n")
    expected_errors = { 2 => [val_err("Forbidden symbol ']'", 2)] }
    assert_equal expected_errors, errors
  end

  def test_description_block_parser_validate_multiple_forbidden_expressions
    description_parser = DescriptionBlockParser.new(forbidden_expressions: %w( [ ]  ? ))
    errors = description_parser.validate("{Test}\nDescription: ]test]\nPerson: test???\n")
    expected_errors = { 2 => [val_err("Forbidden symbol ']'", 2)],
                        3 => [val_err("Forbidden symbol '?'", 3)] }
    assert_equal expected_errors, errors
  end

  def test_description_block_parser_validates_reserved_name
    description_parser = DescriptionBlockParser.new(reserved_names: ["{Character}"])
    errors = description_parser.validate("{Character}\nDescription: test\nPerson: test\n")
    expected_errors = { 1 => [val_err("Use of reserved name ({Character}) as a description name is forbidden", 1)] }
    assert_equal expected_errors, errors
  end


  def test_description_block_parser_throws_parsing_error
    description_parser = DescriptionBlockParser.new
    assert_raises(ParsingError) do |err|
      description_parser.parse("\nGandalf\nDescription")
      assert_equal "Failed to parse start of description for", err.to_s
    end
  end
end
