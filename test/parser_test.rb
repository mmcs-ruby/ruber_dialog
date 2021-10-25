# frozen_string_literal: true

require "test_helper"

class ParserTest < Minitest::Test
  include RuberDialog::Parser

  def test_parsing_error_methods
    parser_error = ParsingError.new(10, "Error")
    assert_respond_to parser_error, :line
    assert_equal 10, parser_error.line
    assert_equal "10: Error", parser_error.to_s
  end

  def test_validation_error_methods
    validation_error = ValidationError.new(0, "Error")
    assert_respond_to validation_error, :error
    assert_respond_to validation_error, :position
    assert_respond_to validation_error, :to_s
    assert_equal "#Line 1: at (0) 'Error'", validation_error.to_s
    assert_equal ValidationError.new(0, "Error"), validation_error
  end
end
