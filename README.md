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

###Blocks
In our language, parsing consists of 3 *blocks*:
#### Character block:
    Characters:
    Gandalf
    Frodo
    Bilbo
#### Description block
    {Greeting}
    Description: There are ale, beer, : and 
        line breaks
    Gandalf: Frodo, take the ring!
#### Responses block
    [Yes, I will take it -> {To Mordor} | No, I won't take it -> {End}

### Parsing
#### Character Block parsing
**Parser::CharacterBlockParser** (`lib/ruber_dialog/parser/chaeacrer_block_parser.rb`) is main class for parsing characters. 

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

    def validate(content) - takes a string and returns Hash with Integer keysand [ValidationError] values


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
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruber_dialog. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ruber_dialog/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuberDialog project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruber_dialog/blob/master/CODE_OF_CONDUCT.md).
