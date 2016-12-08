require 'apipie_bindings/authenticators/base'

module ApipieBindings
  module Authenticators
    class Oauth < Base
      def initialize(consumer_key, consumer_secret, options = {})
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        @options = options
      end

      def authenticate(request, args)
        uri = URI.parse args[:url]
        default_options = {
          :site => "#{uri.scheme}://#{uri.host}:#{uri.port.to_s}",
          :request_token_path => "",
          :authorize_path => "",
          :access_token_path  => ""
        }
        options = default_options.merge(@options)
        consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, options)

        consumer.sign!(request)
      end
    end
  end
end
