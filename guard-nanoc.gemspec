# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'guard/nanoc/version'

Gem::Specification.new do |s|
  s.name        = 'guard-nanoc'
  s.version     = Guard::NanocVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Yann Lugrin']
  s.email       = ['yann.lugrin@sans-savoir.net']
  s.homepage    = 'http://rubygems.org/gems/guard-nanoc'
  s.summary     = 'Guard gem for Nanoc'
  s.description = 'Guard::Nanoc automatically rebuilds nanoc site files when modified (like nanoc watch)'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'guard-nanoc'

  s.add_dependency 'guard', '>= 0.2.1'
  s.add_dependency 'nanoc', '>= 3.1.5'

  s.add_development_dependency 'bundler', '~> 1.0.2'
  s.add_development_dependency 'rspec',   '~> 2.0.1'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.rdoc]
  s.require_path = 'lib'
end