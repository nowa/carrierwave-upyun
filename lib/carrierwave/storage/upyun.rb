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

      ##
      # Deletes a cache dir
      #
      def delete_dir!(path)
        base_dir = File.join(uploader.root, path)
        res = conn.get(base_dir) do |req|
          req.headers = {
            "x-list-limit" => '10000', # 不能包含子目录，并且文件数不能大于 10000 文件
            "accept" => 'application/json'
          }
        end

        return if res.status == 404
        check_put_response!(res)

        result = JSON.parse(res.body)
        result["files"].each do |file|
          path = File.join(base_dir, file["name"])
          res = conn.delete(path, nil, "x-upyun-async" => "true")
          check_put_response!(res)
        end

        res = conn.delete(base_dir)
        check_put_response!(res)
      end

      def clean_cache!(seconds); end

      private

      def check_put_response!(res)
        if res.status != 200
          # code: 42900007 -> concurrent put or delete
          json = JSON.parse(res.body)
          # retry upload
          raise ConcurrentUploadError, res.body if json["code"] == 42_900_007

          raise UploadError, res.body
        end
      end

      def conn
        @conn ||= begin
          api_host = @uploader.upyun_api_host || DEFAULT_API_URL
          Faraday.new(url: "#{api_host}/#{@uploader.upyun_bucket}") do |req|
            req.request :basic_auth, @uploader.upyun_username, @uploader.upyun_password
            req.request :url_encoded
            req.adapter Faraday.default_adapter
          end
        end
      end
    end # CloudFiles
  end # Storage
end # CarrierWave
