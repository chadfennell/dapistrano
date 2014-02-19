# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dapistrano/version'

Gem::Specification.new do |s|
  s.name = "dapistrano"
  s.version = Dapistrano::VERSION
  s.authors = ["Chad Fennell", "David Naughton"]
  s.email = ["libsys@gmail.com", "naughton@umn.edu"]
  s.summary = "Deploy Drupal with Capistrano and Drush Make"
  s.description = "Deploy a Drupal site by building from a Drush Make file for each release."
  s.homepage = "https://github.com/chadfennell/dapistrano"
  #spec.license = ""

  s.files = `git ls-files -z`.split("\x0")
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano", ["<= 2.15.5"]
  s.add_runtime_dependency "railsless-deploy"  

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"

  # TODO: Do we really need these anymore?
  s.date = "2014-02-15"
  s.extra_rdoc_files = [
    "README.md"
  ]
end

