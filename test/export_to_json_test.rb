#
require 'json'
require_relative '../lib/ruber_dialog/node.rb'

class ExportToJsonTest < Minitest::Test
  include RuberDialog::Parser::Tokens
  include RuberDialog::DialogParts

  def test_line_to_json
    line = Line.new("Vincenzo", "Are you hungry?")
    json = {char_name: "Vincenzo", phrase: "Are you hungry?"}.to_json
    assert_equal json, line.to_json
  end

  def test_response_to_json
    response = Response.new("Yes, let's eat some noodles.", "Lunch")
    json = {response: "Yes, let's eat some noodles.", next_node: "Lunch"}.to_json
    assert_equal json, response.to_json
  end

  def test_node_to_json
    lines = [Line.new("Vincenzo", "Please, listen to me."), Line.new("Cha Young", "Oh no..."), Line.new("Vincenzo", "I'm the mafia.")]
    responses = [Response.new("I believe you.", "Telling the truth"), Response.new("Good joke.", "End"), Response.new("In the morning?", "Talking about the song") ]
    node = Node.new("Confession", lines, responses)
    json = {name: "Confession", lines: [{char_name: "Vincenzo", phrase: "Please, listen to me."},
                                        {char_name: "Cha Young", phrase: "Oh no..."},
                                        {char_name: "Vincenzo", phrase: "I'm the mafia."}],
            responses: [{response: "I believe you.", next_node: "Telling the truth"},
                        {response: "Good joke.", next_node: "End"},
                        {response: "In the morning?", next_node: "Talking about the song"}]}.to_json
    assert_equal json, node.to_json
  end

  def test_dialog_to_json

  end
end