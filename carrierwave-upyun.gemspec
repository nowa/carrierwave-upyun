# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "carrierwave-upyun"
  s.version     = "0.2.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nowa Zhu", "Jason Lee"]
  s.email       = ["nowazhu@gmail.com", "huacnlee@gmail.com"]
  s.homepage    = "https://github.com/nowa/carrierwave-upyun"
  s.summary     = %q{UpYun Storage support for CarrierWave}
  s.description = %q{UpYun Storage support for CarrierWave}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave", [">= 0.5.7"]
  s.add_dependency "faraday", [">= 0.8.0"]
end
