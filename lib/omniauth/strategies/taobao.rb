require 'omniauth'
require 'omniauth-oauth2'
require 'taobao/top'

module OmniAuth::Strategies
  class Taobao < OmniAuth::Strategies::OAuth2
    option :client_options, ::Taobao::TOP.gateways
    option :taobao_user_role, nil

    def request_phase
      options[:state] ||= '1'
      super
    end

    def callback_phase
      ignore_sandbox_ssl_verify!
      super
    end

    uid { raw_info['user_id'] }

    info do
      {
        'name' => raw_info['nick'],
        'image' => raw_info['avatar']
      }
    end

    extra do
      { :raw_info => raw_info }
    end

    def raw_info
      @rawinfo ||= (!!options.taobao_user_role ? fetch_raw_info : fetch_raw_info_from_params)
    end

    private
    def raw_info_method
      ["taobao", "user", "#{options.taobao_user_role}", "get"].uniq.join(".")
    end

    def raw_info_fields
      {
        "buyer" => "user_id,nick,sex,avatar,buyer_credit,has_shop,vip_info",
        "seller" => "user_id,nick,sex,avatar,seller_credit,type,has_shop,is_golden_seller,vip_info",
        "user" => "user_id,nick,sex,avatar,email,buyer_credit,seller_credit,location,type,has_shop,vip_info"
      }[options.taobao_user_role.to_s]
    end

    def fetch_raw_info
      service = ::Taobao::TOP::Service.new(options.client_id, options.client_secret, :session => @access_token.token)
      res = service.get(raw_info_method, :fields => raw_info_fields)
      res.error? ? {} : res.body.user
    end

    def fetch_raw_info_from_params
      attrs = [["user_id", "taobao_user_id"],["nick", "taobao_user_nick"]]
      Hash[attrs.collect{|arr| [arr[0], @access_token[arr[1]]]}].select{|k,v| v != nil}
    end

    private
    def ignore_sandbox_ssl_verify!
      if ::Taobao::TOP.sandbox? && defined?(::OpenSSL::SSL::VERIFY_PEER)
        ::OpenSSL::SSL.send :remove_const, :VERIFY_PEER
        ::OpenSSL::SSL.const_set :VERIFY_PEER, 0
      end
    end

  end
end

::OmniAuth.config.add_camelization 'taobao', 'Taobao'