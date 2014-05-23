# CarrierWave for [Upyun](http://upyun.com)

This gem adds support for [Upyun.com](http://www.upyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

    gem install carrierwave-upyun

## Or using Bundler, in `Gemfile`

    gem 'rest-client'
    gem 'carrierwave-upyun'

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "xxxxxx"
  config.upyun_password = 'xxxxxx'
  config.upyun_bucket = "my_bucket"
  config.upyun_bucket_domain = "http://my_bucket.files.example.com"
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
  self.upyun_bucket_domain = "https://avatars.files.example.com"
end
```

