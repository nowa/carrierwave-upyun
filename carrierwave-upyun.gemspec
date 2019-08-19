# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "carrierwave-upyun"
  s.version     = "1.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nowa Zhu", "Jason Lee"]
  s.email       = ["nowazhu@gmail.com", "huacnlee@gmail.com"]
  s.homepage    = "https://github.com/nowa/carrierwave-upyun"
  s.summary     = %q{UpYun Storage support for CarrierWave}
  s.description = %q{UpYun Storage support for CarrierWave}
  s.files         = Dir.glob('lib/**/*') + %w(README.md CHANGELOG.md)
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave", [">= 1.0.0", "< 2.1"]
  s.add_dependency "faraday", [">= 0.8.0"]

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'mini_magick'
  s.add_development_dependency 'rspec'
end
