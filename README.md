# Taobao::Top

   A simple ruby implementation of Taobao TOP API [淘宝开放平台](http://open.taobao.com)

## Installation

Add this line to your application's Gemfile:

    gem 'taobao-top'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install taobao-top

## Usage
### Configuration

For Rails, add following lines in 'config/initializers/taobao_top.rb':

```ruby
Taobao::TOP.sandbox = !Rails.env.production?
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Taobao::TOP.sandbox?
```

### Invoke a API method:
```ruby
require 'taobao/top'
```

Init a service instance by following lines:

```ruby
service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET, :session => "SESSION")
```

Or

```ruby
service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET) do |options|
  options.session = "SESSION"
  options.format = "json"
  options.sign_method = "md5"
end
```

then invoke a API method:

```ruby
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
```

### Multipart content
```ruby
service = Taobao::TOP::Service.new(APP_KEY, APP_SECRET, :session => "SESSION")
response = service.post("taobao.item.img.upload", :num_iid=>'1489161932', :image => File.open('example.jpg'))
```

### Integrate with OmniAuth
```ruby
require 'taobao/top-oauth' # includes TOP API and Oauth
```

and Rails initializer at config/initializers/omniauth.rb

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :taobao, TAOBAO_API_KEY, TAOBAO_API_SECRET
end
```

and Append a line in routes.rb

```ruby
get '/auth/:provider/callback', to: 'sessions#create'
```

and Add following lines in your sessions_controller.rb to initialize a user's session

```ruby
def create
  @user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])
  session[:current_user] = @user
  redirect_to '/'
end
```

#### How to fetch a user's information from TOP API after 'token callback'

By default, the 'taobao_user_role' option is nil in OmniAuth::Strategies::Taobao class, in this case, your will get a simple raw-info hash like this:

```ruby
{
  "user_id": TAOBAO_USER_ID,
  "nick": TAOBAO_USER_NICKNAME
}
```

and you can get a user's information through a TOP API method named 'taobao.user.get' like this:

```ruby
OmniAuth::Strategies::Taobao.option :taobao_user_role, 'user'
```

and to use 'taobao.user.buyer.get' like this:

```ruby
OmniAuth::Strategies::Taobao.option :taobao_user_role, 'buyer'
```

and to use 'taobao.user.seller.get' like this:

```ruby
OmniAuth::Strategies::Taobao.option :taobao_user_role, 'seller'
```

NOTE: you should have avaliable TOP API permissions for above settings. visit [Taobao User API](http://open.taobao.com/doc/api_cat_detail.htm?spm=0.0.0.0.mfYwn5&cat_id=1&category_id=102) for more details.

### SSL verify in Taobao sandbox environment:

when you are using Oauth in the 'tbsandbox' env, you should skip verify SSL certification as following:

```ruby
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE 
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request