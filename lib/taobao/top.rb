lib = File.expand_path('../../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "taobao/top/version"
require 'hashie'
require 'active_support/core_ext'

module Taobao
  module TOP
    mattr_accessor :sandbox
    @@sandbox = false

    def self.gateways
      domain = self.sandbox? ? "tbsandbox" : "taobao"
      {
        :site => "http://gw.api.#{domain}.com/router/rest",
        :authorize_url => "https://oauth.#{domain}.com/authorize",
        :token_url => "https://oauth.#{domain}.com/token"
      }
    end

    def self.sandbox?
      !!self.sandbox
    end

    autoload :Options, 'taobao/top/service.rb'
    autoload :Params, 'taobao/top/service.rb'
    autoload :Service, 'taobao/top/service.rb'
    autoload :Response, 'taobao/top/service.rb'
  end
end

require 'taobao/rails/engine' if defined?(::Rails) && ::Rails::VERSION::MAJOR >= 3