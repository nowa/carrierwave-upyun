# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name = "carrierwave-upyun"
  s.version = "2.0.0"
  s.platform = Gem::Platform::RUBY
  s.authors = ["Nowa Zhu", "Jason Lee"]
  s.email = ["nowazhu@gmail.com", "huacnlee@gmail.com"]
  s.homepage = "https://github.com/nowa/carrierwave-upyun"
  s.summary = "UpYun Storage support for CarrierWave"
  s.description = "UpYun Storage support for CarrierWave"
  s.files = Dir.glob("lib/**/*") + %w[README.md CHANGELOG.md]
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave", [">= 1.0.0"]
  s.add_dependency "faraday", [">= 2.0"]
end
