# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/gp/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-gp'
  spec.summary       = 'groupprice projects rubocop configuration'
  spec.authors       = ['groupprice dev team']
  spec.email         = ['admin@groupprice.ru']
  spec.description = <<-EOF
    Includes RuboCop configuration files and cops from rubocop, rubocop-airbnb, rubocop-rails, rubocop-rspec and rubocop-performance.
    Shared among Groupprice projects.
  EOF
  spec.version       = RuboCop::Gp::VERSION
  spec.homepage      = 'https://gitlab.groupprice.ru/gp-corp/rubocop-gp'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    spec.required_ruby_version = '>= 2.3' # airbnb gem requirement

    # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
    # to allow pushing to a single host or delete this section to allow pushing to any host.
    spec.metadata['allowed_push_host'] = ''
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'rubocop'
  spec.add_dependency 'rubocop-performance'
  spec.add_dependency 'rubocop-rails'
  spec.add_dependency 'rubocop-rspec'
end
