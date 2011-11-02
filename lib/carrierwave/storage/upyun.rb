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
    #       config.upyun_storage_username = "xxxxxx"
    #       config.upyun_storage_userpass = "xxxxxx"
    #       config.upyun_storage_bucket = "my_bucket"
    #       config.upyun_bucket_domain = "https://my_bucket.files.example.com"
    #       config.upyun_storage_api_host = "http://v0.api.upyun.com"
    #     end
    #
    #
    class UpYun < Abstract
      
      class Connection
        def initialize(options={})
          @upyun_storage_username = options[:upyun_storage_username]
          @upyun_storage_userpass = options[:upyun_storage_userpass]
          @upyun_storage_bucket = options[:upyun_storage_bucket]
          @connection_options     = options[:connection_options] || {}
          @host = options[:api_host] || 'http://v0.api.upyun.com'
          @http = RestClient::Resource.new("#{@host}/#{@upyun_storage_bucket}", @upyun_storage_username, @upyun_storage_userpass)
        end
        
        def put(path, payload, headers = {})
          @http["#{escaped(path)}"].put(payload, headers)
        end
        
        def get(path, headers = {})
          @http["#{escaped(path)}"].get(headers)
        end
        
        def delete(path, headers = {})
          @http["#{escaped(path)}"].delete(headers)
        end
        
        def post(path, payload, headers = {})
          @http["#{escaped(path)}"].post(payload, headers)
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
          object = uy_connection.get(@path)
          object.data
        end

        ##
        # Remove the file from Cloud Files
        #
        def delete
          begin
            uy_connection.delete(@path)
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

        ##
        # Writes the supplied data into the object on Cloud Files.
        #
        # === Returns
        #
        # boolean
        #
        def store(data,headers={})
          uy_connection.put(@path, data, {'Expect' => '', 'Mkdir' => 'true'}.merge(headers))
          true
        end

        private

          def headers
            @headers ||= {  }
          end

          def connection
            @base.connection
          end

          def uy_connection
            if @uy_connection
              @uy_connection
            else
              config = {:upyun_storage_username => @uploader.upyun_storage_username, 
                :upyun_storage_userpass => @uploader.upyun_storage_userpass, 
                :upyun_storage_bucket => @uploader.upyun_storage_bucket
              }
              config[:api_host] = @uploader.upyun_storage_api_host if @uploader.respond_to?(:upyun_storage_api_host)
              @uy_connection ||= CarrierWave::Storage::UpYun::Connection.new(config)
            end
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
