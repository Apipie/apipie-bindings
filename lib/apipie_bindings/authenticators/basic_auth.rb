require 'apipie_bindings/authenticators/base'

module ApipieBindings
  module Authenticators
    class BasicAuth < Base
      def initialize(user, password)
        @user = user
        @password = password
      end

      def authenticate(request, args)
        request.basic_auth(@user, @password)
      end
    end
  end
end
