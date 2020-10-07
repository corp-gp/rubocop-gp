# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'rubocop'

require 'rubocop-performance'
require 'rubocop-rails'

require 'rubocop/gp'
require 'rubocop/gp/inject'
require 'rubocop/gp/version'

RuboCop::Gp::Inject.defaults!