[![Build](https://github.com/mmcs-ruby/ruber_dialog/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/mmcs-ruby/ruber_dialog/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/c81c33ffc189fd5698ac/maintainability)](https://codeclimate.com/github/mmcs-ruby/ruber_dialog/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c81c33ffc189fd5698ac/test_coverage)](https://codeclimate.com/github/mmcs-ruby/ruber_dialog/test_coverage)

# RuberDialog

RuberDialog is a **dialog system** that helps game developers write dialogs in an intuitive way.

We provide new *domain specific language* for writing dialogs and tools for:
- configuration
- error checking
- running in terminal
- exporting in json
- Unity game engine integration

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruber_dialog'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruber_dialog

## Usage

### Blocks
In our language, parsing consists of 3 *blocks*:
#### Character block:
    Characters:
    Gandalf
    Frodo
    Bilbo
#### Description block
    {Greeting}
    Description: There are items: ale, beer and 
        line breaks
    Gandalf: Frodo, take the ring!
#### Responses block
    [Yes, I will take it -> {To Mordor} | No, I won't take it -> {End}

### Parsing
#### Character parsing

**Parser::CharacterParser** (`lib/ruber_dialog/parser/character_parser.rb`) is a class for parsing single character string.

Usage:

    s = "Gandalf"
    parser = CharacterParser.new(forbidden_expressions: %w({ [ ] }), reserved_names: ["Description"]
    character = parser.parse(s) # => Character("Gandalf")
    errors = parser.validate(s) # => list of errors, [] in the example

Methods:

    def initiate(forbidden_expressions: [], reserved_names: []) 
        
        forbidden_expressions - [String/RegExpr], expressions that are not supposed to be inside character name
        reserved_names - [String], reserved names such as "Description"
 
    def parse(content) - takes a string and returns Parser::Character

    def validate(content) - takes a string and returns [ValidationError]

#### Character block parsing

**Parser::CharacterBlockParser** (`lib/ruber_dialog/parser/character_block_parser.rb`) is main class for parsing characters. 

Usage:

    s = "Chars:\n
         Gandalf\n
         Frodo"
    parser = CharacterBlockParser.new(block_name: "Chars:\n", reserved_names: ["Desc"])
    parser.parse(s) # => [Character("Gandalf"), Character("Frodo")]
    
Methods:
    
    def initiate(starting_line: 1, block_name: "Characters:", reserved_names: ["Description"],
                     forbidden_expressions: %w({ [ ] }), separator: "\n") 
        
        starting_line - Integer, line number where the blocks starts.
        block_name - String, key word that helps to determine where the block starts
        reserved_names - [String], reserved names such as "Description"
        forbidden_expressions - [String/RegExpr], expressions that are not supposed to be inside character name
        separator - String/RegExpr, used to separate characters 
    
    def parse(content) - takes a string and returns array of Parser::Character

    def validate(content) - takes a string and returns Hash with Integer keys and [ValidationError] values

    def split_to_token_contents(character_content) - takes string, splits it to TokenContents

    def starting_line=(starting_line) - for setting up the line where block starts, used for error messages
	
#### Description parsing

**Parser::DescriptionLineParser** (`lib/ruber_dialog/parser/description_parser.rb`) is a class for parsing single description.

Usage:

    s= "{Greeting}
        Description: There are items: ale, beer and 
        line breaks
        Gandalf: Frodo, take the ring!"
    parser = RuberDialog::Parser::DescriptionLineParser.new(forbidden_expressions: %w([ ] ), reserved_names: [])
    line = parser.parse(s) # => Line("Gandalf", "{Greeting}...")
    errors = parser.validate(s) # => list of errors, [] in the example
   
Methods:

    def initiate(forbidden_expressions: [], reserved_names: []) 
		forbidden_expressions - [String/RegExpr], expressions that are not supposed to be inside description
        reserved_names - [String], reserved names such as "Description"
 
    def parse(content) - takes a string and returns Parser::Line

    def validate(content) - takes a string and returns [ValidationError]

#### Description block parsing

**Parser::DescriptionBlockParser** (`lib/ruber_dialog/parser/description_block_parser.rb`) is main class for parsing descriptions. 

Usage:

    s= "{Greeting}
        Description: There are items: ale, beer and 
        line breaks
        Gandalf: Frodo, take the ring!
        
        {Test}
        Description: no description
        Me: Get out!"
        "
    parser = DescriptionBlockParser.new()
    parser.parse(s) # => [Line("Gandalf","{Greeting}..."),Line("Me" , "{Test}...")]

Methods:
    
    def initiate(starting_line: 1, block_start_regexp: /^{[a-zA-Z]+}$/, reserved_names: ["Description"],
                     forbidden_expressions: %w({ [ ] }), separator: "\n") 
        
        block_start_regexp - [RegExpr], that matches start of a description block
		starting_line - Integer, line number where the blocks starts.
        reserved_names - [String], reserved names such as "Description"
        forbidden_expressions - [String/RegExpr], expressions that are not supposed to be inside description block
        separator - String/RegExpr, used to separate lines
    
    def parse(content) - takes a string and returns array of Parser::Line

    def validate(content) - takes a string and returns Hash with Integer keys and [ValidationError] values

    def split_to_token_contents(character_content) - takes string, splits it to TokenContents

    def starting_line=(starting_line) - for setting up the line where block starts, used for error messages


#### Abstractions
It is recommended to use **Parser::TokenParser** (`lib/ruber_dialog/parser/parser.rb`) for parsing simple objects in strings, such as a character in **Character Block** or a response in **Response Block**.
If you write your own token parser, consider inheriting it from TokenParser

Here is an example of inheritance:

    class CharacterParser < TokenParser
      def initialize(forbidden_expressions: [], reserved_names: [])
        super(forbidden_expressions, reserved_names)
      end
   
      def forbidden_expression_error(expression)
        "Forbidden symbol '#{expression}'"
      end

      def reserved_name_error(name)
        "Use of reserved name (#{name}) as a character name is forbidden"
      end

      protected :forbidden_expression_error, :reserved_name_error

      def parse(content)
        raise ArgumentError unless content.is_a?(String)

        Character.new(content)
      end
    end
This class now is capable of:
- finding errors such as forbidden expressions and reserved names
- locating the line where the error occurred


For parsing **blocks**, there is an abstract class **Parser::BlockParser** (`lib/ruber_dialog_parser/block_parser.rb`), which is capable of validating content using encapsulated **Parser::TokenParser** inheritor repetitive   
To use **BlockParser**, you have to implement **def** *split_to_token_contents(content)*, which is used to extract simple object strings that *TokenParser* could parse them

### Nodes and dialogs
There are two classes of RuberDialog::DialogParts module.

**Node** is a class containing NPC conversation and possibly the main character's responses (forks).
You can go to the next node if you have at least one response. Otherwise, it is considered that the node is final.
Every node has its name, list of NPC's lines, also they can have a list of the main characters' responses.


**Dialog** is not a dialogue. It is a class of all possible conversation forks in the game.
Every dialog consists of a starting node, a list of other nodes, a list of characters, and final nodes' names.


### Export to JSON

There is a list of classes having **.to_json** method that converts the object to JSON:
- Character
- Line
- Response
- Node
- Dialog

#### Examples of JSONs

```ruby
# Character
{"name":"Character's name"}

# Line
{"char_name":"Character's name", "phrase":"Character's phrase"}

# Response
{"response":"Main character's phrase", "next_node":"Name of the next node"}

# Node
{"name":"Node's name", "lines":[list_of_lines], "responses":[list_of_responses]}

# Dialog
{"starting_node":starting_node, "nodes":[list_of_nodes], "characters":[list_of_characters], "final_nodes_names":[list_of_final_nodes_names]}
```
##Export to unity
GameObject Manager contains fields for the character name, frase, choice buttons, start JSON file, and the rest of JSON files. 

Classes Dnode, Line and Response contain fields from JSON files and functions. 

Script DialogueManager contains function LoadNode for showing text on the screen, function FindNextNode, and functions FirstChoice and Second choce for choise buttons.

At the Start method all the nodes' names are put in the dictionary, to be accessed by FindNextNode method. 
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruber_dialog. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ruber_dialog/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuberDialog project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruber_dialog/blob/master/CODE_OF_CONDUCT.md).