# frozen_string_literal: true

require "test_helper"

class DescriptionLineParserTest < Minitest::Test
  include RuberDialog::Parser
  include RuberDialog::Parser::Tokens

  def val_err(err, line = 1)
    ValidationError.new(err, line)
  end

  def test_description_parser_validation_reserved_names
    description_parser = DescriptionLineParser.new(reserved_names: %w[{Forbidden} Reserved])
    assert_equal [val_err("Use of reserved name ({Forbidden}) as a description name is forbidden")],
                 description_parser.validate("{Forbidden}\nDescription: test\nMe: test")
    assert_equal [val_err("Use of reserved name (Reserved) as a description name is forbidden", 3)],
                 description_parser.validate("{Reserved}\nDescription: test\nReserved: test")
  end

  def test_description_parser_validates_one_forbidden_expression
    description_parser = DescriptionLineParser.new(forbidden_expressions: %w( [ ] ! ))
    assert_equal [val_err("Forbidden symbol '['",2)], description_parser.validate("{Test}\nDescription: t[est\nMe: test")
    assert_equal [val_err("Forbidden symbol ']'", 2)], description_parser.validate("{Test}\nDescription: tes]t\nMe: test")
    assert_equal [val_err("Forbidden symbol '!'", 3)], description_parser.validate("{Test}\nDescription: test\nMe: test!")
  end

  def test_description_parser_validates_multiple_forbidden_expressions
    description_parser = DescriptionLineParser.new(forbidden_expressions: %w( [ ] !))
    assert_equal [val_err("Forbidden symbol '!'",2), val_err("Forbidden symbol '['",2),
                  val_err("Forbidden symbol ']'",2)],
                 description_parser.validate("{Test}\nDescription: !t[est]\nMe: test")
  end

  def test_description_parser_validates_repetitive_error_once
    description_parser = DescriptionLineParser.new(forbidden_expressions: %w([ ]))
    assert_equal [val_err("Forbidden symbol '['",2)],
                 description_parser.validate("{Test}\nDescription: [t[e[s[t\nMe: test")
  end

  def test_description_parser_validates_many_lines
    description_parser = DescriptionLineParser.new(forbidden_expressions: %w( [ ] ))
    assert_equal [val_err("Forbidden symbol ']'", 3), val_err("Forbidden symbol '['", 2)],
                 description_parser.validate("{Test}\nDescription: [test\nMe: test]")
  end

  def test_description_parser_parses_line
    description_parser = DescriptionLineParser.new
    line = description_parser.parse("{Test}\nDescription: test\nMe: test")
    assert_instance_of Line, line
  end

  def test_description_parser_parser_parses
    description_parser = DescriptionLineParser.new
    line = description_parser.parse("{Test}\nDescription: test\nMe: test")
    assert_equal Line.new("Me","{Test}\nDescription: test\nMe: test"), line
  end

  def test_description_name_must_start_with_an_uppercase
    result = nil
    begin
    description_parser = DescriptionLineParser.new
    description_parser.parse("{test}\nDescription: test\nMe: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse start of description for"), true
  end

  def test_description_name_must_include_letters_only
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Act 1}\nDescription: test\nMe: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse start of description for"), true
  end

  def test_description_name_mixed_case_is_not_allowed
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{GreetinG}\nDescription: test\nMe: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse start of description for"), true
  end

  def test_character_name_must_start_with_an_uppercase
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Test}\nDescription: test\nme: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse character name for"), true
  end


  def test_character_name_must_include_letters_only
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Action}\nDescription: test\nRookie-1: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse character name for"), true
  end

  def test_character_name_mixed_case_is_not_allowed
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Greeting}\nDescription: test\nALeXeY: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse character name for"), true
  end

  def test_description_line_must_exist
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Test}\nMe: no description line!\nMe: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Failed to parse start of description line for"), true
  end

  def test_description_line_must_be_alone
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Test}\nDescription: one!\nDescription: two!\nMe: test")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Only one description line expected but found 2"), true
  end

  def test_character_name_must_be_alone
    result = nil
    begin
      description_parser = DescriptionLineParser.new
      description_parser.parse("{Test}\nDescription: one!\nSergey: hi!\nMe: hello")
    rescue ParsingError => ex
      result = :exception_handled
    end
    assert_equal :exception_handled, result
    assert_equal ex.message.match?("Only one character name expected but found 2"), true
  end

  def test_extra_braces_are_not_allowed
  result = nil
  begin
    description_parser = DescriptionLineParser.new
    description_parser.parse("{Test}\nDescription: one!\nSergey: {hi}!")
  rescue ParsingError => ex
    result = :exception_handled
  end
  assert_equal :exception_handled, result
  assert_equal ex.message.match?("Only one pair of '{}' is allowed for"), true
  end
end
