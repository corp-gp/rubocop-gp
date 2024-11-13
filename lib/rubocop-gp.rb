# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'rubocop'

module RuboCop::Cop::FrozenStringLiteral
  def frozen_string_literals_enabled? = true
end

require 'rubocop-performance'
require 'rubocop-rails'

require 'rubocop/gp'
require 'rubocop/gp/inject'
require 'rubocop/gp/version'

RuboCop::Gp::Inject.defaults!