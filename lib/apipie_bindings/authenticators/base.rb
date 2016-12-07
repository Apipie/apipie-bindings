module ApipieBindings
  module Authenticators
    class Base
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
