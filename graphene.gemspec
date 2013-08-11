# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "graphene/version"

Gem::Specification.new do |s|
  s.name          = "graphene"
  s.version       = Graphene::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Powershop NZ Ltd']
  s.email         = ['dev@powershop.co.nz']
  s.homepage      = 'https://github.com/powershop/graphene'
  s.summary       = "SVG graph generator."
  s.description   = "SVG graph generator."
  s.add_dependency 'builder'
  s.files         = %w(README) + Dir["lib/**/*"]
  s.require_paths = ['lib']
end
