require 'apipie_bindings/authenticators/basic_auth'

module ApipieBindings
  module Authenticators
    class BasicAuthExternal < BasicAuth
      def initialize(user, password, authentication_url, auth_request_options = {})
        super(user, password)
        @authentication_url = authentication_url
        @auth_request_options = auth_request_options
      end

      def authenticate(original_request, _args)
        request = RestClient::Resource.new(
          @authentication_url,
          @auth_request_options.merge({ user: @user, password: @password })
        )
        request.get do |response, _, raw_response|
          if response.code == 401
            raise RestClient::Unauthorized.new(response), 'External authentication did not pass.'
          end

          cookie = raw_response['set-cookie'].split('; ')[0]
          @auth_cookie = cookie
          original_request['Cookie'] = cookie
        end

        original_request
      end
    end
  end
end
