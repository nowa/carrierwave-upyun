## 0.2.2

- 减少 Gem 文件尺寸，避免带入不必要的问题；

## 0.2.1

- 修 CarrierWave::Storage::UpYun::File 继承 CarrierWave::SanitizedFile 以便能实现一些 CarrierWave 通用的方法。

## 0.2.0

- 改用 Faraday 代替 rest-client，来发送 HTTP 请求；
- 精简代码；
- 移除 `upyun_bucket_domain` 配置信息，请用 `upyun_bucket_host` 代替；

## 0.1.8

- 修复 upyun_bucket_domain 选项处理错误；
- 修复不含 'http://' 前缀的值处理出错的问题；

## 0.1.7

- SSL Host 配置支持；
- Fix issue 16 并减少连接； #18

## 0.1.6

- 改进 Upyun 初始化，将少连接的过程;