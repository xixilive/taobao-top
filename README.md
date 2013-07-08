# Taobao::Top

   A simple ruby implementation of Taobao TOP API (http://open.taobao.com)

## Installation

Add this line to your application's Gemfile:

    gem 'taobao-top'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taobao-top

## Usage
### Configuration
    Taobao::TOP.sandbox = false(default) or true

### Invoke a API method:
	require 'taobao/top'
	service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET, :session => "SESSION")

	Or

	service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET) do |options|
	  options.session = "SESSION"
	  options.format = "json"
	  options.sign_method = "md5"
	end

    response = service.get("taobao.users.get", :nick => "test")
    unless response.error?
      user = response.body.user
      p user.nick # => test
    else
      p response.error.code
      p response.error.msg
      p response.error.sub_code
      p response.error.sub_msg
    end

### Multipart content
    service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET, :session => "SESSION")
    response = service.post("taobao.item.img.upload", :num_iid=>'1489161932', :image => File.open('example.jpg'))

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
