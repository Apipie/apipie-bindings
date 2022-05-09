require 'apipie_bindings/authenticators/base'
require 'gssapi'

module ApipieBindings
  module Authenticators
    # Negotiate authenticator
    # Implements gssapi negotiation with preexisting kerberos ticket
    # Requires a authentication url, the authentication request will be against.
    # This url needs to support auth negotiation and after successful auth it should return 'set-cookie' header with session.
    # This session will be initiated in the auth request and the original request will be made with this cookie.
    # Next requests should be already skip the negotiation, please implement Session support in your client, for not using the negotiation on every request.
    class Negotiate < Base

      # Creates new authenticator for Negotiate auth
      # @param [String] url to make authentication request to.
      # @param [Hash] auth_request_options passed to RestClient::Request - especially for SSL options
      #   see https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb.
      # @option service service principal used for gssapi tickets - defaults to HTTP.
      # @option method http method used for the auth request - defaults to 'get'.
      def initialize(authorization_url, auth_request_options = {})
        @authorization_url = authorization_url
        @service = auth_request_options.delete(:service) || 'HTTP'
        auth_request_options[:method] ||= 'get'
        @auth_request_options = auth_request_options
      end

      def error(ex)
        if ex.is_a?(GSSAPI::GssApiError)
          raise ApipieBindings::AuthenticatorError.new(:negotiate, :no_context, ex)
        elsif ex.is_a?(ApipieBindings::ConfigurationError)
          raise ApipieBindings::AuthenticatorError.new(:negotiate, :configuration, ex)
        else
          raise ex
        end
      end

      def authenticate(original_request, args)
        uri = URI.parse(@authorization_url)
        @gsscli = GSSAPI::Simple.new(uri.host, @service)

        token = @gsscli.init_context
        headers = { 'Authorization' => "Negotiate #{Base64.strict_encode64(token)}" }

        RestClient::Request.execute(@auth_request_options.merge(headers: headers, url: @authorization_url)) do |response, request, raw_response|
          if response.code == 401
            raise RestClient::Unauthorized.new(response), 'Negotiation authentication did not pass.'
          end
          if response.code == 302 && response.headers[:location].end_with?('/users/login')
            raise ApipieBindings::ConfigurationError, 'Server misconfiguration detected'
          end

          # This part is only for next calls, that could be simplified if all resources are behind negotiate auth
          itok = Array(raw_response['WWW-Authenticate']).pop.split(/\s+/).last
          @gsscli.init_context(Base64.strict_decode64(itok)) # The context should now return true

          cookie = raw_response['set-cookie'].split('; ')[0]
          @auth_cookie = cookie
          original_request['Cookie'] = cookie
        end

        original_request
      end
    end
  end
end
