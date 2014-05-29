# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "carrierwave-upyun"
  s.version     = "0.1.7"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nowa Zhu"]
  s.email       = ["nowazhu@gmail.com"]
  s.homepage    = "https://github.com/nowa/carrierwave-upyun"
  s.summary     = %q{UpYun Storage support for CarrierWave}
  s.description = %q{UpYun Storage support for CarrierWave}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave", [">= 0.5.7"]
  s.add_dependency "rest-client", [">= 1.6.7"]
  s.add_development_dependency "rspec", ["~> 2.6"]
end
