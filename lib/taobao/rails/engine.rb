module Taobao
  module Rails
    class Engine < ::Rails::Engine

      initializer "taobao.top" do |app|
        ::Taobao::TOP.sandbox = !::Rails.env.production?

        if defined?(::OmniAuth::Strategies::Taobao)
          ::OmniAuth::Strategies::Taobao.option :client_options, ::Taobao::TOP.gateways
        end
      end

    end
  end
end