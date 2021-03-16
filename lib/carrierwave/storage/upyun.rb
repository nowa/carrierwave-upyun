# frozen_string_literal: true

require "faraday"

module CarrierWave
  module Storage
    ##
    #
    #     CarrierWave.configure do |config|
    #       config.upyun_username = "xxxxxx"
    #       config.upyun_password = "xxxxxx"
    #       config.upyun_bucket = "my_bucket"
    #       config.upyun_bucket_host = "https://my_bucket.files.example.com"
    #       config.upyun_api_host = "http://v0.api.upyun.com"
    #     end
    #
    #
    class UpYun < Abstract
      DEFAULT_API_URL = "http://v0.api.upyun.com"

      class UploadError < RuntimeError; end

      class ConcurrentUploadError < RuntimeError; end

      ##
      # Store the file on UpYun
      #
      # === Parameters
      #
      # [file (CarrierWave::SanitizedFile)] the file to store
      #
      # === Returns
      #
      # [CarrierWave::Storage::UpYun::File] the stored file
      #
      def store!(file)
        f = File.new(uploader, self, uploader.store_path)
        f.store(file, "Content-Type" => file.content_type)
        f
      end

      # Do something to retrieve the file
      #
      # @param [String] identifier uniquely identifies the file
      #
      # [identifier (String)] uniquely identifies the file
      #
      # === Returns
      #
      # [CarrierWave::Storage::UpYun::File] the stored file
      #
      def retrieve!(identifier)
        File.new(uploader, self, uploader.store_path(identifier))
      end

      def cache!(file)
        f = File.new(uploader, self, uploader.cache_path)
        f.store(file, "Content-Type" => file.content_type)
        f
      end

      def retrieve_from_cache!(identifier)
        File.new(uploader, self, uploader.cache_path(identifier))
      end

      def delete_dir!(path)
      end

      def clean_cache!(seconds)
      end
    end
  end
end
