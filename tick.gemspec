# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tick/version"

Gem::Specification.new do |s|
  s.name        = "tick"
  s.version     = Tick::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["allenwei"]
  s.email       = ["digruby@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/tick"
  s.summary     = %q{Tick benchmark your method and print it in color}

  s.rubyforge_project = "tick"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rainbow')

  s.add_development_dependency('rspec') 
  s.add_development_dependency('rr') 
  s.add_development_dependency('autotest') 
  s.add_development_dependency('ruby-debug') 
end
