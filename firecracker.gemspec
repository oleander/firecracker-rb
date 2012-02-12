# -*- encoding: utf-8 -*-
require File.expand_path("../lib/firecracker/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Linus Oleander"]
  gem.email         = ["linus@oleander.nu"]
  gem.description   = %q{An implementation of the UDP/TCP torrent scrape protocol}
  gem.summary       = %q{An implementation of the UDP/TCP torrent scrape protocol}
  gem.homepage      = "https://github.com/oleander/firecracker-rb"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "firecracker"
  gem.require_paths = ["lib"]
  gem.version       = Firecracker::VERSION
  
  gem.add_dependency("rest-client")
  gem.add_dependency("bencode_ext")
  
  gem.add_development_dependency("vcr")
  gem.add_development_dependency("rspec")  
  gem.add_development_dependency("webmock")
  
  gem.required_ruby_version = "~> 1.9.0"
end