# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require_relative 'lib/graphql_preload_queries/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql_preload_queries'
  spec.version       = GraphqlPreloadQueries::VERSION
  spec.authors       = ['owen2345']
  spec.email         = ['owenperedo@gmail.com']

  spec.summary       = 'Permit to avoid N+1 queries problem when using graphql queries'
  spec.description   = 'Permit to avoid N+1 queries problem when using graphql queries'
  spec.homepage      = 'https://github.com/owen2345/graphql_preload_queries'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  # spec.metadata["allowed_push_host"] = ""

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'graphql'
  spec.add_dependency 'rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
