
require 'digest/md5'
require 'digest/hmac'
require 'rest_client'

module Taobao
	module TOP
    class Options < ::Hashie::Mash;
      def self.default
        self.new v: '2.0', sign_method: 'md5', format: 'json'
      end
    end

    class Params < ::Hashie::Mash

      attr_reader :signature

      def sign! secret
        str = self.select{|k,v| !multipart?(v) }.sort_by{|k,v| k.to_s }.collect{|i| i.join }.join
        @signature = case self.sign_method.to_s.downcase
        when 'md5' then Digest::MD5.hexdigest("#{secret}#{str}#{secret}").upcase
        when 'hmac' then Digest::HMAC.hexdigest(str, secret, Digest::MD5).upcase
        else ""
        end
        self.sign = @signature
      end

      private
      def multipart? obj
        obj.respond_to?(:path) && obj.respond_to?(:read)
      end
    end

    class Response < ::Hashie::Mash
      def self.from_json data
        self.new ActiveSupport::JSON.decode(data)
      end

      def self.from_xml data
        self.new Hash.from_xml(data)
      end

      def body
        unless error?
          self[self.keys.first]
        end
      end

      def error?
        self.error_response
      end

      def error
        self.error_response if error?
      end
    end

		class Service

      attr_reader :options, :params, :response

      def initialize *args, &block
        @options = TOP::Options.default.dup.merge(args.extract_options!)
        @app_key, @app_secret = args.slice!(0,2)
        raise ArgumentError.new "app_key or app_secret missing!" unless @app_key && @app_secret
        yield @options if block_given?
			end

      def get method, *args
        invoke method, :get, *args
      end

      def post method, *args
        invoke method, :post, *args
      end

      private
      def prepare_params params
        @params = TOP::Params.new params
        @params.app_key = @app_key
        @params.timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        @params.sign! @app_secret
      end

      def invoke method, http_method, *args
        prepare_params @options.merge(args.extract_options!).merge(method: method)
        begin
          @raw_response = case http_method
          when :get then RestClient.get [gateway, @params.to_query].join("?")
          when :post then RestClient.post gateway, @params
          end
          @response = case @params.format.to_s.downcase
          when 'json'
            TOP::Response.from_json(@raw_response)
          when 'xml'
            TOP::Response.from_xml(@raw_response)
          else
            @raw_response
          end
        rescue Exception => e
          RestClient.create_log(e)
        end
      end

      def gateway
        domain = TOP.sandbox ? "tbsandbox" : "taobao"
        "http://gw.api.#{domain}.com/router/rest"
      end
		end

	end
end