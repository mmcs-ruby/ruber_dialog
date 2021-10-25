# frozen_string_literal: true

require "test_helper"

class ErrorsTest < Minitest::Test
  include RuberDialog::Parser

  def test_parsing_error_methods
    parser_error = ParsingError.new(10, "Error")
    assert_respond_to parser_error, :line
    assert_equal 10, parser_error.line
    assert_equal "10: Error", parser_error.to_s
  end

  def test_validation_error_methods
    validation_error = ValidationError.new("Error", 1)
    assert_respond_to validation_error, :error
    assert_respond_to validation_error, :local_line
    assert_respond_to validation_error, :to_s
    assert_equal "#At line 1: 'Error'", validation_error.to_s
    assert_equal ValidationError.new("Error", 1), validation_error
  end
end
