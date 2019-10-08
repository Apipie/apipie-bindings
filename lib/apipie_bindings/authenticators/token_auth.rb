require 'apipie_bindings/authenticators/base'

module ApipieBindings
  module Authenticators
    class TokenAuth < Base
      def initialize(token)
        @token = token
      end

      def authenticate(req, token)
        req['Authorization'] = "Bearer #{@token}"
      end
    end
  end
end
