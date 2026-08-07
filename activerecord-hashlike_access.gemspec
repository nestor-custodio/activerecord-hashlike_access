# frozen_string_literal: true

require_relative "lib/activerecord/hashlike_access/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-hashlike_access"
  spec.version = Activerecord::HashlikeAccess::VERSION
  spec.authors = ["Nestor Custodio"]
  spec.email = ["nestor@custodio.org"]

  spec.summary = "Provides Hash-like access to ActiveRecord models."
  spec.homepage = "https://github.com/nestor-custodio/activerecord-hashlike_acces"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # This of course requires ActiveRecord.
  #
  spec.add_dependency "activerecord", ">= 6"
end
