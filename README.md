# CarrierWave for TFS

This gem adds support for [UpYun Storage](http://www.upyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

    gem install carrierwave-upyun

## Using Bundler

    gem 'rest-client'
    gem 'carrierwave-upyun'

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
require "carrierwave/upyun"
CarrierWave.configure do |config|
  config.upyun_storage_username = "xxxxxx"
  config.upyun_storage_userpass = 'xxxxxx'
  config.upyun_storage_bucket = "my_bucket"
  config.upyun_bucket_domain = "my_bucket.files.example.com"
end
```

And then in your uploader, set the storage to `:upyun`:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :upyun
end
```

