# frozen_string_literal: true

require "carrierwave/storage/upyun"
require "carrierwave/upyun/configuration"

CarrierWave.configure do |config|
  config.storage_engines.merge!(upyun: "CarrierWave::Storage::UpYun")
end

CarrierWave::Uploader::Base.include CarrierWave::UpYun::Configuration
