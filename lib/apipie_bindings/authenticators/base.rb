module ApipieBindings
  module Authenticators
    class Base
      # In case an authenticator needs to make an authentication call
      # before the original one you might want to set auth_cookie
      # returned by the server to be available for futher processing
      # (e.g. saving the session id) since it may contain session id
      # to use with all the next calls
      attr_reader :auth_cookie

      def authenticate(request, args)
      end

      def error(ex)
      end

      def response(r)
      end

      def name
        self.class.name
      end
    end
  end
end
