module Taobao
  module Rails
    class Engine < ::Rails::Engine

      initializer "taobao.top" do |app|
        
        ::Taobao::TOP.sandbox = !::Rails.env.production?
        ::OpenSSL::SSL::VERIFY_PEER = ::OpenSSL::SSL::VERIFY_NONE if ::Taobao::TOP.sandbox?

        if defined?(::OmniAuth::Strategies::Taobao)
          ::OmniAuth::Strategies::Taobao.option :client_options, ::Taobao::TOP.gateways
        end
      end

    end
  end
end