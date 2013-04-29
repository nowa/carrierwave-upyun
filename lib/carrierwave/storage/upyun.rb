# encoding: utf-8
require 'carrierwave'

begin
  require 'rest_client'
  RestClient.log = nil
rescue LoadError
  raise "You don't have the 'rest_client' gem installed"
end

module CarrierWave
  module Storage

    ##
    #
    #     CarrierWave.configure do |config|
    #       config.upyun_username = "xxxxxx"
    #       config.upyun_password = "xxxxxx"
    #       config.upyun_bucket = "my_bucket"
    #       config.upyun_bucket_domain = "https://my_bucket.files.example.com"
    #       config.upyun_api_host = "http://v0.api.upyun.com"
    #     end
    #
    #
    class UpYun < Abstract
      class Connection
        cattr_reader :shared_connections

        def self.find_or_initialize(bucket, options)
          @@shared_connections ||= {}
          @@shared_connections[bucket.to_sym] ||= new(bucket, options)
        end

        def initialize(bucket, options = {})
          @upyun_bucket   = bucket
          @upyun_username = options[:upyun_username]
          @upyun_password = options[:upyun_password]

          @host = options[:api_host] || 'http://v0.api.upyun.com'
        end
        private_class_method :new

        def rest_client
          @rest_client ||= RestClient::Resource.new("#{@host}/#{@upyun_bucket}", :user => @upyun_username, :password => @upyun_password)
        end

        def put(path, payload, headers = {})
          rest_client[escaped(path)].put(payload, headers)
        end

        def get(path, headers = {})
          rest_client[escaped(path)].get(headers)
        end

        def delete(path, headers = {})
          rest_client[escaped(path)].delete(headers)
        end

        def post(path, payload, headers = {})
          rest_client[escaped(path)].post(payload, headers)
        end

        def escaped(path)
          CGI.escape(path)
        end
      end

      class File

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

        ##
        # Reads the contents of the file from Cloud Files
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          object = upyun_connection.get(@path)
          @headers = object.headers
          object.net_http_res.body
        end

        ##
        # Remove the file from Cloud Files
        #
        def delete
          begin
            upyun_connection.delete(@path)
            true
          rescue Exception => e
            # If the file's not there, don't panic
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
          if @uploader.upyun_bucket_domain
            "http://" + @uploader.upyun_bucket_domain + '/' + @path
          else
            nil
          end
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
        def store(data,headers={})
          upyun_connection.put(@path, data, {'Expect' => '', 'Mkdir' => 'true'}.merge(headers))
          true
        end

        private

          def headers
            @headers ||= begin
              upyun_connection.get(@path).headers
            rescue Excon::Errors::NotFound # Don't die, just return no headers
              {}
            end
          end

          def connection
            @base.connection
          end

          def upyun_connection
            conn_options = {
              :upyun_username => @uploader.upyun_username,
              :upyun_password => @uploader.upyun_password
            }
            if @uploader.respond_to?(:upyun_api_host)
              conn_options[:api_host] = @uploader.upyun_api_host
            end
            CarrierWave::Storage::UpYun::Connection.find_or_initialize @uploader.upyun_bucket, conn_options
          end
      end

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
        cloud_files_options = {'Content-Type' => file.content_type}
        f = CarrierWave::Storage::UpYun::File.new(uploader, self, uploader.store_path)
        f.store(file.read,cloud_files_options)
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
        CarrierWave::Storage::UpYun::File.new(uploader, self, uploader.store_path(identifier))
      end

    end # CloudFiles
  end # Storage
end # CarrierWave
