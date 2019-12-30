# frozen_string_literal: true

require "rubygems"
require "rspec"
require "active_record"
require "carrierwave"
require "open-uri"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "carrierwave-upyun"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split("/")[0..-3].join("/"), "spec"].join("/")
    end
  end
end

ActiveRecord::Migration.verbose = false

ActiveSupport.on_load :active_record do
  require "carrierwave/orm/activerecord"
end

# 每次启动测试用不同的地址，确保验证上传成功能正确验证到（因为历史的没删除）
PHOTO_RANDOM_PATH = SecureRandom.hex
class PhotoUploader < CarrierWave::Uploader::Base
  def store_dir
    "test/#{PHOTO_RANDOM_PATH}/photos"
  end
end

class Photo < ActiveRecord::Base
  mount_uploader :image, PhotoUploader
end

# 测试的时候需要修改这个地方
CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = ENV["UPYUN_USERNAME"] || "test"
  config.upyun_password = ENV["UPYUN_PASSWORD"] || "123123"
  config.upyun_bucket = ENV["UPYUN_BUCKET"] || "carrierwave-upyun"
  config.upyun_bucket_host = ENV["UPYUN_BUCKET_HOST"] || "http://carrierwave-upyun.ruby-china.com"
end

def load_file(fname)
  File.open([Rails.root, fname].join("/"))
end
