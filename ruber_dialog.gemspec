# frozen_string_literal: true

require_relative "lib/ruber_dialog/version"

Gem::Specification.new do |spec|
  spec.name          = "ruber_dialog"
  spec.version       = RuberDialog::VERSION
  spec.authors       = ["mmcs-ruby"]
  spec.email         = ["poganesyan@sfedu.ru"]

  spec.summary       = "Gem for building a dialogs."
  spec.description   = "Really long explanation"
  spec.homepage      = "https://github.com/Sakorni/ruber_dialog"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mmcs-ruby/ruber_dialog"
  spec.metadata["changelog_uri"] = "https://github.com/mmcs-ruby/ruber_dialog/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'simplecov', "~> 0.3"
end
