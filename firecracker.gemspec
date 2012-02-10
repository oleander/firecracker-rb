# -*- encoding: utf-8 -*-
require File.expand_path('../lib/firecracker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Linus Oleander"]
  gem.email         = ["linus@oleander.nu"]
  gem.description   = %q{Implements the UDP/TCP torrent scrape protocol}
  gem.summary       = %q{Implements the UDP/TCP torrent scrape protocol}
  gem.homepage      = "https://github.com/oleander.nu/firecracker-rb"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "firecracker"
  gem.require_paths = ["lib"]
  gem.version       = Firecracker::VERSION
  
  gem.add_dependency("bencode")
  gem.add_dependency("rest-client")
  gem.add_dependency("rchardet19")
end