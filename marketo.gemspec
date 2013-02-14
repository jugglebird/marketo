# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marketo/version'

Gem::Specification.new do |gem|
  gem.name          = "marketo"
  gem.version       = Marketo::VERSION
  gem.authors       = ["Chris Hunter"]
  gem.email         = ["chrish@spiceworks.com"]
  gem.description   = %q{A client library for connecting to Marketo's SOAP API for lead generation management.}
  gem.summary       = %q{A Ruby library for consuming Marketo's SOAP API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency('savon', '~> 1.2.0')
  # gem.add_dependency('savon_model')
  # gem.add_development_dependency('vcr')
  gem.add_development_dependency('mocha')
  gem.add_development_dependency('pry')
  gem.add_development_dependency('rake')
  
end
