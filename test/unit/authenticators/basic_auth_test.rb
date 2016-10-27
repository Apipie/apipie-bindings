require File.join(File.dirname(__FILE__), '../test_helper')
require 'apipie_bindings/authenticators/basic_auth'

describe ApipieBindings::Authenticators::BasicAuth do
  let(:authenticator) { ApipieBindings::Authenticators::BasicAuth.new(user, passwd) }
  let(:user) { 'john_doe' }
  let(:passwd) { 'secret_password' }
  let(:request) { mock() }
  let(:args) { {} }

  describe '#authenticate' do
    it 'adds base auth to the request' do
      request.expects(:basic_auth).with(user, passwd)
      authenticator.authenticate(request, args)
    end
  end
end
