# frozen_string_literal: true

require "test_helper"

class ErrorsTest < Minitest::Test
  include RuberDialog::Parser

  def test_parsing_error_line
    parser_error = ParsingError.new(10, "Error")
    assert_equal 10, parser_error.line
    assert_equal "10: Error", parser_error.to_s
  end

  def test_parsing_error_to_s
    parser_error = ParsingError.new(10, "Error")
    assert_equal "10: Error", parser_error.to_s
  end

  def test_validation_error_to_s
    validation_error = ValidationError.new("Error", 1)
    assert_equal "#At line 1: 'Error'", validation_error.to_s
  end

  def test_validation_error_eq
    validation_error = ValidationError.new("Error", 1)
    assert_equal ValidationError.new("Error", 1), validation_error
  end

  def test_validation_error_error
    validation_error = ValidationError.new("Error", 1)
    assert_equal "Error", validation_error.error
  end

  def test_validation_error_local_line
    validation_error = ValidationError.new("Error", 1)
    assert_equal 1, validation_error.local_line
  end

  def test_validation_error_set_local_line
    validation_error = ValidationError.new("Error", 1)
    validation_error.local_line = 10
    assert_equal 10, validation_error.local_line
  end
end
