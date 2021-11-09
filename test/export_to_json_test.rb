#
require 'json'
require_relative '../lib/ruber_dialog/node.rb'
require_relative '../lib/ruber_dialog/dialog.rb'

class ExportToJsonTest < Minitest::Test
  include RuberDialog::Parser::Tokens
  include RuberDialog::DialogParts

  def test_character_to_json
    character = Character.new("Vincenzo")
    json = {name: "Vincenzo"}.to_json
    assert_equal json, character.to_json
  end

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

    final_lines = [Line.new("Vincenzo", "Well, it was a long journey."),Line.new("Cha Young", "That's true. I think we have to drink some beer."),Line.new("Vincenzo", "And maybe some Italian vine...")]
    final_node = Node.new("End", final_lines, nil)
    final_json = {name: "End", lines: [{char_name: "Vincenzo", phrase: "Well, it was a long journey."},
                                {char_name: "Cha Young", phrase: "That's true. I think we have to drink some beer."},
                                {char_name: "Vincenzo", phrase: "And maybe some Italian vine..."}], responses: nil}.to_json

    assert_equal final_json, final_node.to_json
  end

  def test_dialog_to_json
    vincenzo = Character.new("Vincenzo")
    inzaghi = Character.new("Inzaghi")

    line_v_1 = Line.new("Vincenzo", "This is my pigeon. His name is Inzaghi.");
    line_v_2 = Line.new("Vincenzo", "Isn't he nice?");
    line_v_3 = Line.new("Vincenzo", "I think so too. Well, I have some fun stories about him...");
    line_v_4 = Line.new("Vincenzo", "Don't argue, but... once he saved my life. Didn't you know about that?");
    line_v_5 = Line.new("Vincenzo", "Yes, it sounds unbelievable but it's true. Inzaghi is my hero.");
    line_v_6 = Line.new("Vincenzo", "So, let me tell you an exciting story...");
    line_v_7 = Line.new("Vincenzo", "Oh, okay, as you want. But I know someone who will dispel your doubts.");
    line_v_8 = Line.new("Vincenzo", "*calling Cha Young*");

    line_i_1 = Line.new("Inzaghi", "*greeting pigeon sounds*");
    line_i_2 = Line.new("Inzaghi", "*cute pigeon sounds*");
    line_i_3 = Line.new("Inzaghi", "*proud pigeon sounds*");
    line_i_4 = Line.new("Inzaghi", "*sad pigeon sounds*");
    line_i_5 = Line.new("Inzaghi", "*cunning pigeon sounds*");

    response_1_1 = Response.new("Yes, he's so sweet!", "Fun story")
    response_1_2 = Response.new("He is suspicious...", "Rescue")
    response_2_1 = Response.new("Wow! It's amazing!", "Exciting story")
    response_2_2 = Response.new("I don't believe you, joker.", "Well...")

    starting_node = Node.new("Greetings", [line_v_1, line_i_1, line_v_2], [response_1_1, response_1_2])
    node_1 = Node.new("Fun story", [line_i_2, line_v_3], nil)
    node_2 = Node.new("Rescue", [line_v_4], [response_2_1, response_2_2])
    node_3 = Node.new("Exciting story", [line_v_5, line_i_3,  line_v_6], nil)
    node_4 = Node.new("Well...", [line_i_4, line_v_7, line_i_5, line_v_8], nil)

    dialog = Dialog.new(starting_node, [node_1, node_2,node_3,node_4], [vincenzo, inzaghi], ["Fun story", "Exciting story", "Well..."])

    json = {starting_node: {name: starting_node.name, lines: starting_node.lines, responses: starting_node.responses},
            nodes: [{name: node_1.name, lines: node_1.lines, responses: node_1.responses},
                    {name: node_2.name, lines: node_2.lines, responses: node_2.responses},
                    {name: node_3.name, lines: node_3.lines, responses: node_3.responses},
                    {name: node_4.name, lines: node_4.lines, responses: node_4.responses}], characters: [{name: vincenzo.name},
                                                                                                                              {name: inzaghi.name}], final_nodes_names: [node_1.name, node_3.name, node_4.name]}.to_json

    assert_equal json, dialog.to_json
  end
end