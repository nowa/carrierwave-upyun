# CarrierWave for [Upyun](http://upyun.com)

This gem adds support for [Upyun.com](http://www.upyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

    gem install carrierwave-upyun

## Or using Bundler, in `Gemfile`

    gem 'carrierwave-upyun'

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "xxxxxx"
  config.upyun_password = 'xxxxxx'
  config.upyun_bucket = "my_bucket"
  config.upyun_bucket_domain = "my_bucket.files.example.com"
end
```

And then in your uploader, set the storage to `:upyun`:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :upyun
end
```

