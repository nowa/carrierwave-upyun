require "carrierwave/storage/upyun"
require "carrierwave/upyun/configuration"
CarrierWave.configure do |config|
  config.storage_engines.merge!({:upyun => "CarrierWave::Storage::UpYun"})
end

CarrierWave::Uploader::Base.send(:include, CarrierWave::UpYun::Configuration)