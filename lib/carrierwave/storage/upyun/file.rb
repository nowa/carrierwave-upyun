# frozen_string_literal: true

require "faraday"

module CarrierWave::Storage
  class UpYun
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
      attr_reader :path

      def escaped_path
        @escaped_path ||= CGI.escape(@path)
      end

      def content_type
        @content_type || ""
      end

      attr_writer :content_type

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
        conn.delete(escaped_path)
        true
      rescue StandardError => e
        puts "carrierwave-upyun delete failed: #{e.inspect}"
        nil
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

      ##
      # Return file name, if available
      #
      # === Returns
      #
      # [String] file name
      #   or
      # [NilClass] no file name available
      #
      def filename
        return unless file_url = url
        ::File.basename(file_url.split('?').first)
      end

      def extension
        path_elements = path.split('.')
        path_elements.last if path_elements.size > 1
      end

      def content_type
        headers[:content_type]
      end

      def content_type=(new_content_type)
        headers[:content_type] = new_content_type
      end

      def headers
        @headers ||= begin
          conn.head(escaped_path).headers
        rescue Faraday::ClientError
          {}
        end
      end

      ##
      # Return size of file body
      #
      # === Returns
      #
      # [Integer] size of file body
      #
      def size
        headers['content-length'].to_i
      end

      ##
      # Writes the supplied data into the object on Cloud Files.
      #
      # === Returns
      #
      # boolean
      #
      def store(new_file, headers = {})
        # Copy from cache_path
        if new_file.is_a?(self.class)
          new_file.copy_to(self.escaped_path)
          return true
        end

        res = conn.put(self.escaped_path, new_file.read) do |req|
          req.headers = { "Expect" => "", "Mkdir" => "true" }.merge(headers)
        end

        check_put_response!(res)

        true
      rescue ConcurrentUploadError => e
        retry
      end

      ##
      # Creates a copy of this file and returns it.
      #
      # === Parameters
      #
      # [new_path (String)] The path where the file should be copied to.
      #
      # === Returns
      #
      # @return [CarrierWave::Storage::UpYun::File] the location where the file will be stored.
      #
      def copy_to(new_path)
        escaped_new_path = CGI.escape(new_path)
        res = conn.put(new_path) do |req|
          req.headers = {
            "X-Upyun-Copy-Source" => "/#{@uploader.upyun_bucket}/#{self.path}",
            "Content-Length" => 0,
            "Mkdir" => "true",
          }
        end

        check_put_response!(res)

        File.new(@uploader, @base, new_path)
      rescue ConcurrentUploadError => e
        retry
      end

      private

      def check_put_response!(res)
        @base.check_put_response!(res)
        # if res.status != 200
        #   # code: 42900007 -> concurrent put or delete
        #   json = JSON.parse(res.body)
        #   # retry upload
        #   raise ConcurrentUploadError, res.body if json["code"] == 42_900_007
        #
        #   raise UploadError, res.body
        # end
      end

      def conn
        @base.conn
        # @conn ||= begin
        #   api_host = @uploader.upyun_api_host || DEFAULT_API_URL
        #   Faraday.new(url: "#{api_host}/#{@uploader.upyun_bucket}") do |req|
        #     req.request :basic_auth, @uploader.upyun_username, @uploader.upyun_password
        #     req.request :url_encoded
        #     req.adapter Faraday.default_adapter
        #   end
        # end
      end


    end
  end
end