require File.join(File.dirname(__FILE__), '../test_helper')
require 'apipie_bindings/authenticators/credentials_legacy'

describe ApipieBindings::Authenticators::CredentialsLegacy do
  let(:authenticator) { ApipieBindings::Authenticators::CredentialsLegacy.new(@credentials) }
  let(:user) { 'john_doe' }
  let(:passwd) { 'secret_password' }
  let(:request) { mock() }
  let(:args) { {} }

  before do
    @credentials = mock()
  end

  describe '#authenticate' do
    it 'uses result of to_params for base auth of the request' do
      @credentials.expects(:to_params).returns({ :user => user, :password => passwd })
      request.expects(:basic_auth).with(user, passwd)
      authenticator.authenticate(request, args)
    end
  end

  describe '#error' do
    it 'clears credentials on RestClient::Unauthorized' do
      @credentials.expects(:clear)
      authenticator.error(RestClient::Unauthorized.new)
    end

    it 'lets other errors pass' do
      authenticator.error(RuntimeError.new)
    end
  end

end
