require 'apipie_bindings/authenticators/base'

module ApipieBindings
  module Authenticators
    class CredentialsLegacy < Base
      def initialize(credentials)
        @credentials = credentials
      end

      def authenticate(request, args)
        params = @credentials.to_params
        request.basic_auth(params[:user], params[:password])
      end

      def error(ex)
        @credentials.clear if ex.is_a? RestClient::Unauthorized
      end

      def clear
        @credentials.clear
      end
    end
  end
end
