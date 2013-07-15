require 'omniauth-oauth2'
require 'taobao/top'

module OmniAuth::Strategies
  class Taobao < OmniAuth::Strategies::OAuth2
  	option :client_options, client_options_hash
  	option :taobao_user, "user"

		def request_phase
      options[:state] ||= '1'
      super
    end

    uid { raw_info['uid'] }

    info do
      {
        'name' => raw_info['nick'],
        'image' => raw_info['avatar']
      }
    end

    extra { :raw_info => raw_info }

    def raw_info
	    @rawinfo ||= fetch_raw_info
    end

  	private
  	def client_options_hash
  		domain = Taobao::TOP.sandbox ? "tbsandbox" : "taobao"
  		{
  			:site => "http://gw.api.#{domain}.com/router/rest",
        :authorize_url => "https://oauth.#{domain}.com/authorize",
        :token_url => "https://oauth.#{domain}.com/token"
  		}
  	end

  	def raw_info_method
  		%w[taobao user #{options.taobao_user} get].uniq.join(".")
  	end

  	def raw_info_fields
  		"user_id,uid,nick,sex,buyer_credit,seller_credit,location,created,last_visit,type,avatar,has_shop,is_golden_seller,vip_info"
  	end

    def fetch_raw_info
      service = Taobao::TOP::Service.new(options.client_id, options.client_secret, :session => @access_token.token)
      p service, raw_info_method, raw_info_fields
      res = service.get raw_info_method, :fields => raw_info_fields
      unless res.error?
        res.body.user
      end
    end
  end
end

OmniAuth.config.add_camelization 'taobao', 'Taobao'