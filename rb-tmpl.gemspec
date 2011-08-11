# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rb-tmpl/version'

Gem::Specification.new do |s|
	s.name        = 'rb-tmpl'
	s.version     = RbTmpl::VERSION
	s.authors     = ['Sijmen J. Mulder']
	s.email       = ['sjmulder@gmail.com']
	s.homepage    = 'https://github.com/sjmulder/rb-tmpl'
	s.summary     = %q{A Ruby implementation of jquery-tmpl}
	s.description = %q{With rb-tmpl you can re-use jquery-tmpl templates on the server, saving you from having to do the same work twice.}

	s.rubyforge_project = 'rb-tmpl'

	s.add_dependency 'rubyzip', '~> 0.9.4'
	s.add_development_dependency 'bundler', '>= 1.0.0'
	s.add_development_dependency 'rspec'
	s.add_development_dependency 'fakefs'

	s.files         = `git ls-files`.split("\n")
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ['lib']
end
