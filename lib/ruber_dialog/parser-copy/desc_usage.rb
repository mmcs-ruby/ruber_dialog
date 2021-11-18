
#frozen_string_literal: true

require_relative "description_block_parser"
require_relative "description_parser"

desc1 = "
{Greeting}
Description: There are
items: ale, beer and line breaks
Gandalf: Frodo, take the ring!
"

desc_block = "
{Hate}
Description: There are items: ale, beer and
    line breaks
Jake: Frodo, take the ring!
{Rage}
Description: There no items!
John: Frodo, take the ring!
{Test}
Description: no description
Me: Get out!"

s="{Greeting1}
Description: There are items: ale, beer and
line breaks
Gandalf: Frodo, take the ring!

{Hello}
Description: no description
Me: Get out!"


# parser = RuberDialog::Parser::DescriptionLineParser.new(forbidden_expressions: %w([ ] ), reserved_names: [])
# line = parser.parse(desc1).to_json.to_s # => Character("Gandalf")
# errors = parser.validate(desc1) # => list of errors, [] in the example
# print(line, '\n')
# # print(errors)

# block_parser = RuberDialog::Parser::DescriptionBlockParser.new
# block_errors = block_parser.validate(s)
# lines = block_parser.parse(s)
# print("\n",lines)
# print("\n",block_errors)
include RuberDialog::Parser
include RuberDialog::Parser::Tokens
require 'test/unit/assertions'

include Test::Unit::Assertions

def val_err(err, line = 1)
  ValidationError.new(err, line)
end


# description_parser = RuberDialog::Parser::DescriptionLineParser.new(reserved_names: %w[{Forbidden} Reserved])
# #r = description_parser.validate("{Forbidden}\nDescription: test\nMe: test")
# #print(r)
# assert_equal [val_err("Use of reserved name ({Forbidden}) as a description name is forbidden")],
#               description_parser.validate("{Forbidden}\nDescription: test\nMe: test")
#  assert_equal [val_err("Use of reserved name (Reserved) as a description name is forbidden", 3)],
#               description_parser.validate("{Reserved}\nDescription: test\nReserved: test")

#description_parser = RuberDialog::Parser::DescriptionLineParser.new(forbidden_expressions: %w( [ ] ))
# assert_equal [val_err("Forbidden symbol '['",2)], description_parser.validate("{Test}\nDescription: t[est\nMe: test")
# assert_equal [val_err("Forbidden symbol ']'", 2)], description_parser.validate("{Test}\nDescription: tes]t\nMe: test")
# assert_equal [val_err("Forbidden symbol '!'", 2)], description_parser.validate("{Test}\nDescription: test!\nMe: test")
# assert_equal [val_err("Forbidden symbol '!'",2), val_err("Forbidden symbol '['",2),
#               val_err("Forbidden symbol ']'",2)],
#              description_parser.validate("{Test}\nDescription: !t[est]\nMe: test")
# assert_equal [val_err("Forbidden symbol '['",2)],
#              description_parser.validate("{Test}\nDescription: [t[e[s[t\nMe: test")

#assert_equal [val_err("Forbidden symbol ']'", 3), val_err("Forbidden symbol '['", 2)],
#description_parser.validate("{Test}\nDescription: [test\nMe: test]")
# description_parser = RuberDialog::Parser::DescriptionLineParser.new
# line = description_parser.parse("{Test}\nDescription: test\nMe: test")
# assert_equal Line.new("Me","{Test}\nDescription: test\nMe: test"), line

description_parser = RuberDialog::Parser::DescriptionBlockParser.new
assert_raise(ParsingError) do |err|
  description_parser.parse("\nGandalf\nDescription")
  assert_equal "Failed to parse start of description for", err.to_s
end