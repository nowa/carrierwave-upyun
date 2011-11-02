require "carrierwave/storage/upyun"
require "carrierwave/upyun/configuration"
CarrierWave.configure do |config|
  config.storage_engines.merge!({:tfs => "CarrierWave::Storage::UpYun"})
end

CarrierWave::Uploader::Base.send(:include, CarrierWave::UpYun::Configuration)