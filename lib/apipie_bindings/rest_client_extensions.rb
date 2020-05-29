require 'rest_client'
module ApipieBindings
  module RestClientExtensions

    module RequestAccessor
      attr_accessor :request
    end

    RestClient::AbstractResponse.send(:include, RequestAccessor) unless RestClient::AbstractResponse.method_defined?(:request)
    RestClient::Response.send(:include, RequestAccessor) unless RestClient::Response.method_defined?(:request)

    unless RestClient.const_defined? :AUTHENTICATOR_EXTENSION
      RestClient::AUTHENTICATOR_EXTENSION = lambda do |request, args|
        args[:authenticator].authenticate(request, args) if args[:authenticator]
      end
    end

    unless RestClient.before_execution_procs.include? RestClient::AUTHENTICATOR_EXTENSION
      RestClient.add_before_execution_proc(&RestClient::AUTHENTICATOR_EXTENSION)
    end
  end
end
