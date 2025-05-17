# frozen_string_literal: true

require_relative 'lib/mondial_connector/version'

Gem::Specification.new do |spec|
  spec.name = 'mondial_connector'
  spec.version = MondialConnector::VERSION
  spec.authors = ['Jim Welch']
  spec.email = ['jim.welch@mondialsoftware.com']

  spec.summary = 'An example Mondial Cloud Connector gem using Mondials REST API as its data source. '
  spec.description = "This gem is used as a template for development of connector gems for Mondial's Cloud Connector Rails application."
  spec.homepage = 'https://github.com/MondialSoftware/mondial_connector'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://github.com'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'httparty', '~> 0.21'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
