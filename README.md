# CarrierWave for [UpYun (又拍云存储)](http://upyun.com)

This gem adds support for [Upyun.com](http://www.upyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)


## Installation

```ruby
gem 'carrierwave'
gem 'carrierwave-upyun'
```

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "xxxxxx"
  config.upyun_password = 'xxxxxx'
  config.upyun_bucket = "my_bucket"
  # upyun_bucket_domain 以后将会弃用，请改用 upyun_bucket_host
  # config.upyun_bucket_domain = "my_bucket.files.example.com"
  config.upyun_bucket_host = "http://my_bucket.files.example.com"
end
```

And then in your uploader, set the storage to `:upyun`:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :upyun
end
```

You can override configuration item in individual uploader like this:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :upyun

  self.upyun_bucket = "avatars"
  self.upyun_bucket_host = "https://avatars.files.example.com"
end
```

## Configuration for use UpYun "Image Space"

```ruby
# The defined image name versions to limit use
IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES = %(320 640 800)
class ImageUploader < CarrierWave::Uploader::Base
  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def default_url
    # You can use FTP to upload a default image
    "#{Setting.upload_url}/blank.png#{version_name}"
  end

  # Override url method to implement with "Image Space"
  def url(version_name = "")
    @url ||= super({})
    version_name = version_name.to_s
    return @url if version_name.blank?
    if not version_name.in?(IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES)
      # To protected version name using, when it not defined, this will be give an error message in development environment
      raise "ImageUploader version_name:#{version_name} not allow."
    end
    [@url,version_name].join("!") # thumb split with "!"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if super.present?
      model.uploader_secure_token ||= SecureRandom.uuid.gsub("-","")
      Rails.logger.debug("(BaseUploader.filename) #{model.uploader_secure_token}")
      "#{model.uploader_secure_token}.#{file.extension.downcase}"
    end
  end
end
```

To see more details about use UpYun: [http://huacnlee.com/blog/rails-app-image-store-with-carrierwave-upyun/](http://huacnlee.com/blog/rails-app-image-store-with-carrierwave-upyun/)
