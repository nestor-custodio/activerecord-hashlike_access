require_relative 'lib/active_record/hashlike_access/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.4'

  spec.name          = 'activerecord-hashlike_access'
  spec.version       = ActiveRecord::HashlikeAccess::VERSION
  spec.authors       = ['Nestor Custodio']
  spec.email         = ['nestor@custodio.org']

  spec.summary       = 'Provides Hash-like access to ActiveRecord models.'
  spec.homepage      = 'https://github.com/nestor-custodio/activerecord-hashlike_access'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0") - Dir['.[!.]*/**/*', 'bin/**/*', 'spec/**/*', '.git*']
  spec.executables   = []
  spec.require_paths = ['lib']

  # ---

  spec.metadata = {
    # See: https://guides.rubygems.org/specification-reference/#metadata

    # RubyGems.org Security
    #
    'allowed_push_host'     => 'https://rubygems.org',
    'rubygems_mfa_required' => 'true',

    # Metadata-Provided URIs
    #
    'homepage_uri'          => spec.homepage,
    'changelog_uri'         => "#{spec.homepage}/CHANGELOG.md"
  }

  # ---

  # This of course requires ActiveRecord.
  #
  spec.add_dependency 'activerecord', '>= 6'
end
