# coding: utf-8
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
      DEFAULT_API_URL = 'http://v0.api.upyun.com'
 
      class File < CarrierWave::SanitizedFile
        def initialize(uploader, base, path)
          @uploader = uploader
          @path = path
          @base = base
        end

        ##
        # Returns the current path/filename of the file on Cloud Files.
        #
        # === Returns
        #
        # [String] A path
        #
        def path
          @path
        end
        
        def escaped_path
          @escaped_path ||= CGI.escape(@path)
        end

        def content_type
          @content_type || ""
        end

        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        ##
        # Reads the contents of the file from Cloud Files
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          res = conn.get(escaped_path)
          @headers = res.headers
          res.body
        end

        ##
        # Remove the file from Cloud Files
        #
        def delete
          begin
            conn.delete(escaped_path)
            true
          rescue => e
            puts "carrierwave-upyun delete failed: #{e.inspect}"
            nil
          end
        end

        ##
        # Returns the url on the Cloud Files CDN.  Note that the parent container must be marked as
        # public for this to work.
        #
        # === Returns
        #
        # [String] file's url
        #
        def url
          return nil unless @uploader.upyun_bucket_host
          [@uploader.upyun_bucket_host, @path].join("/")
        end

        def content_type
          headers[:content_type]
        end

        def content_type=(new_content_type)
          headers[:content_type] = new_content_type
        end

        ##
        # Writes the supplied data into the object on Cloud Files.
        #
        # === Returns
        #
        # boolean
        #
        def store(data, headers = {})
          conn.put(escaped_path, data) do |req|
            req.headers = {'Expect' => '', 'Mkdir' => 'true'}.merge(headers)
          end
          true
        end

        def headers
          @headers ||= begin
            conn.get(@path).headers
          rescue Faraday::ClientError
            {}
          end
        end
        
        def conn
          return @conn if defined?(@conn)
          
          api_host = @uploader.upyun_api_host || DEFAULT_API_URL
          @conn = Faraday.new(url: "#{api_host}/#{@uploader.upyun_bucket}") do |req|
            req.request :basic_auth, @uploader.upyun_username, @uploader.upyun_password
            req.request :url_encoded
            req.adapter Faraday.default_adapter
          end
        end
      end # File

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
        f.store(file.read, 'Content-Type' => file.content_type)
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

    end # CloudFiles
  end # Storage
end # CarrierWave
