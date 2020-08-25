require 'json'
require 'oauth'
require 'logger'
require 'tmpdir'
module ApipieBindings

  class API

    attr_reader :apidoc_cache_name, :fake_responses, :language, :uri, :follow_redirects
    attr_writer :dry_run

    # Creates new API bindings instance
    # @param [Hash] config API bindings configuration
    # @option config [String] :uri base URL of the server
    # @option config [String] :username username to access the API
    # @option config [String] :password username to access the API
    # @option config [Hash]   :oauth options to access API using OAuth
    #   * *:consumer_key* (String) OAuth key
    #   * *:consumer_secret* (String) OAuth secret
    #   * *:options* (Hash) options passed to OAuth
    # @option config [AbstractCredentials] :credentials object implementing {AbstractCredentials}
    #   interface e.g. {https://github.com/theforeman/hammer-cli-foreman/blob/master/lib/hammer_cli_foreman/credentials.rb HammerCLIForeman::BasicCredentials}
    #   This is prefered way to pass credentials. Credentials acquired form :credentials object take
    #   precedence over explicite params
    # @option config [Hash] :headers additional headers to send with the requests
    # @option config [String] :api_version ('1') version of the API
    # @option config [String] :language prefered locale for the API description
    # @option config [String] :apidoc_cache_base_dir ('~/.cache/apipie_bindings') base
    #   directory for building apidoc_cache_dir
    # @option config [String] :apidoc_cache_dir (apidoc_cache_base_dir+'/<URI>') where
    #   to cache the JSON description of the API
    # @option config [String] :apidoc_cache_name ('default') name of the cache file.
    #   If there is cache in the :apidoc_cache_dir, it is used.
    # @option config [String] :apidoc_authenticated (true) whether or not does the call to
    #   obtain API description use authentication. It is useful to avoid unnecessary prompts
    #   for credentials
    # @option config [Hash] :fake_responses ({}) responses to return if used in dry run mode
    # @option config [Bool] :dry_run (false) dry run mode allows to test your scripts
    #   and not touch the API. The results are taken form exemples in the API description
    #   or from the :fake_responses
    # @option config [Bool] :aggressive_cache_checking (false) check before every request
    #   if the local cache of API description (JSON) is up to date. By default it is checked
    #   *after* each API request
    # @option config [Object] :logger (Logger.new(STDERR)) custom logger class
    # @option config [Number] :timeout API request, open and read timeout in seconds, use -1 to disable timeout
    # @option config [Symbol] :follow_redirects (:default) Possible values are :always, :never and :default.
    #   The :default is to only redirect in GET and HEAD requests (RestClient default)
    # @option config [AbstractAuthenticator] :authenticator API request authenticator
    # @param [Hash] options params that are passed to ResClient as-is
    # @raise [ApipieBindings::ConfigurationError] when no +:uri+ or +:apidoc_cache_dir+ is provided
    # @example connect to a server
    #   ApipieBindings::API.new({:uri => 'http://localhost:3000/',
    #     :username => 'admin', :password => 'changeme',
    #     :api_version => '2', :aggressive_cache_checking => true})
    # @example connect with a local API description
    #   ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
    #     :apidoc_cache_name => 'architecture'})
    def initialize(config, options={})
      if config[:uri].nil? && config[:apidoc_cache_dir].nil?
        raise ApipieBindings::ConfigurationError.new('Either :uri or :apidoc_cache_dir needs to be set')
      end
      @uri = config[:uri]
      @api_version = config[:api_version] || 1
      @language = config[:language]
      apidoc_cache_base_dir = config[:apidoc_cache_base_dir] || File.join(File.expand_path('~/.cache'), 'apipie_bindings')
      @apidoc_cache_dir = config[:apidoc_cache_dir] || File.join(apidoc_cache_base_dir, @uri.tr(':/', '_'), "v#{@api_version}")
      @apidoc_cache_name = config[:apidoc_cache_name] || set_default_name
      @apidoc_authenticated = (config[:apidoc_authenticated].nil? ? true : config[:apidoc_authenticated])
      @follow_redirects = config.fetch(:follow_redirects, :default)
      @dry_run = config[:dry_run] || false
      @aggressive_cache_checking = config[:aggressive_cache_checking] || false
      @fake_responses = config[:fake_responses] || {}
      @logger = config[:logger]
      unless @logger
        @logger = Logger.new(STDERR)
        @logger.level = Logger::ERROR
      end

      config = config.dup

      headers = {
        :content_type => 'application/json',
        :accept       => "application/json;version=#{@api_version}"
      }
      headers.merge!({ "Accept-Language" => language }) if language
      headers.merge!(config[:headers]) unless config[:headers].nil?
      headers.merge!(options.delete(:headers)) unless options[:headers].nil?

      log.debug "Global headers: #{inspect_data(headers)}"
      log.debug "Follow redirects: #{@follow_redirects.to_s}"

      if config[:authenticator]
        @authenticator = config[:authenticator]
      else
        @authenticator = legacy_authenticator(config)
      end

      if (config[:timeout] && config[:timeout].to_i < 0)
        config[:timeout] = (RestClient.version < '1.7.0') ? -1 : nil
      end

      # RestClient < 1.7.0 does not support ssl_ca_path use ssl_ca_file instead
      if options[:ssl_ca_path] && !RestClient::Request.method_defined?(:ssl_opts)
        parsed_uri = URI.parse(@uri)
        cert_file =  File.join(options[:ssl_ca_path], "#{parsed_uri.host}.pem")
        if File.exist?(cert_file)
          options[:ssl_ca_file] = cert_file
          log.warn "ssl_ca_path is not supported by RestClient. ssl_ca_file = #{cert_file} was used instead."
        end
      end

      @resource_config = {
        :timeout  => config[:timeout],
        :read_timeout  => config[:timeout],
        :open_timeout  => config[:timeout],
        :headers  => headers,
        :verify_ssl => true
      }.merge(options)

      @config = config
    end


    def apidoc_cache_file
       File.join(@apidoc_cache_dir, "#{@apidoc_cache_name}#{cache_extension}")
    end

    def load_apidoc
      check_cache if @aggressive_cache_checking
      if File.exist?(apidoc_cache_file)
        JSON.parse(File.read(apidoc_cache_file), :symbolize_names => true)
      end
    end

    def clear_credentials
      @authenticator.clear if @authenticator && @authenticator.respond_to?(:clear)
    end

    def apidoc
      @apidoc ||= load_apidoc || retrieve_apidoc
      @apidoc
    end

    def dry_run?
      @dry_run ? true : false
    end

    def has_resource?(name)
      apidoc[:docs][:resources].has_key? name
    end

    def resource(name)
      ApipieBindings::Resource.new(name, self)
    end

    # List available resources
    # @return [Array<ApipieBindings::Resource>]
    def resources
      apidoc[:docs][:resources].keys.map { |res| resource(res) }
    end


    # Call an action in the API.
    # It finds most fitting route based on given parameters
    # with other attributes necessary to do an API call.
    # If in dry_run mode {#initialize} it finds fake response data in examples
    # or user provided data. At the end when the response format is JSON it
    # is parsed and returned as ruby objects. If server supports checksum sending
    # the internal cache with API description is checked and updated if needed
    # @param [Symbol] resource_name name of the resource
    # @param [Symbol] action_name name of the action
    # @param [Hash] params parameters to be send in the request
    # @param [Hash] headers extra headers to be sent with the request
    # @param [Hash] options options to influence the how the call is processed
    #   * *:response* (Symbol) *:raw* - skip parsing JSON in response
    #   * *:with_authentication* (Bool) *true* - use rest client with/without auth configuration
    #   * *:skip_validation* (Bool) *false* - skip validation of parameters
    # @example show user data
    #   call(:users, :show, :id => 1)
    def call(resource_name, action_name, params={}, headers={}, options={})
      check_cache if @aggressive_cache_checking
      resource = resource(resource_name)
      action = resource.action(action_name)
      action.validate!(params) unless options[:skip_validation]
      options[:fake_response] = find_match(fake_responses, resource_name, action_name, params) || action.examples.first if dry_run?

      call_action(action, params, headers, options)
    end

    def call_action(action, params={}, headers={}, options={})
      route = action.find_route(params)
      return http_call(
        route.method,
        route.path(params),
        params.reject { |par, _| route.params_in_path.include? par.to_s },
        headers, options)
    end

    # Low level call to the API. Suitable for calling actions not covered by
    # apipie documentation. For all other cases use {#call}
    # @param [String] http_method one of +get+, +put+, +post+, +destroy+, +patch+
    # @param [String] path URL path that should be called
    # @param [Hash] params parameters to be send in the request
    # @param [Hash] headers extra headers to be sent with the request
    # @param [Hash] options options to influence the how the call is processed
    #   * *:response* (Symbol) *:raw* - skip parsing JSON in response
    #   * *:reduce_response_log* (Bool) - do not show response content in the log.
    #   * *:with_authentication* (Bool) *true* - use rest client with/without auth configuration
    # @example show user data
    #   http_call('get', '/api/users/1')
    def http_call(http_method, path, params={}, headers={}, options={})
      headers ||= { }

      args = [http_method]
      if %w[post put].include?(http_method.to_s)
        #If using multi-part forms, the paramaters should not be json
        if ((headers.include?(:content_type)) and (headers[:content_type] == "multipart/form-data"))
          args << params
        else
          args << params.to_json
        end
      else
        headers[:params] = params if params
      end

      log.info "Server: #{@uri}"
      log.info "#{http_method.to_s.upcase} #{path}"
      log.debug "Params: #{inspect_data(params)}"
      log.debug "Headers: #{inspect_data(headers)}"

      args << headers if headers

      if dry_run?
        empty_response = ApipieBindings::Example.new('', '', '', 200, '')
        ex = options[:fake_response ] || empty_response
        response = create_fake_response(ex.status, ex.response, http_method, URI.join(@uri || 'http://example.com', path).to_s, args)
      else
        apidoc_without_auth = (path =~ /\/apidoc\//) && !@apidoc_authenticated
        authenticate = options[:with_authentication].nil? ? !apidoc_without_auth : options[:with_authentication]
        begin
          client = authenticate ? authenticated_client : unauthenticated_client
          response = call_client(client, path, args)
          update_cache(response.headers[:apipie_checksum])
        rescue => e
          log.error e.message
          log.debug inspect_data(e)
          if e.respond_to?(:response) && e.response.respond_to?(:headers)
            update_cache(e.response.headers[:apipie_checksum])
          end
          override_e = @authenticator.error(e) if authenticate && @authenticator
          raise override_e.is_a?(StandardError) ? override_e : e
        end
      end

      result = options[:response] == :raw ? response : process_data(response)
      log.debug "Response: %s" % (options[:reduce_response_log] ? "Received OK" : inspect_data(result))
      log.debug "Response headers: #{inspect_data(response.headers)}" if response.respond_to?(:headers)
      result
    end


    def update_cache(cache_name)
      if !cache_name.nil? && (cache_name != @apidoc_cache_name)
        clean_cache
        log.debug "Cache expired. (#{@apidoc_cache_name} -> #{cache_name})"
        @apidoc_cache_name = cache_name
      end
    end

    def clean_cache
      @apidoc = nil
      Dir["#{@apidoc_cache_dir}/*#{cache_extension}"].each { |f| File.delete(f) }
    end

    def check_cache
      begin
        response = http_call('get', "/apidoc/apipie_checksum", {}, { :accept => "application/json" })
        response['checksum']
      rescue
        nil
      end
    end

    def retrieve_apidoc
      FileUtils.mkdir_p(@apidoc_cache_dir) unless File.exist?(@apidoc_cache_dir)
      if language
        response = retrieve_apidoc_call("/apidoc/v#{@api_version}.#{language}.json", :safe => true)
        language_family = language.split('_').first
        if !response && language_family != language
          response = retrieve_apidoc_call("/apidoc/v#{@api_version}.#{language_family}.json", :safe => true)
        end
      end
      unless response
        begin
          response = retrieve_apidoc_call("/apidoc/v#{@api_version}.json")
        rescue Exception => e
          raise ApipieBindings::DocLoadingError.new(
            "Could not load data from #{@uri}: #{e.message}\n"\
            " - is your server down?\n"\
            " - was rake apipie:cache run when using apipie cache? (typical production settings)", e)
        end
      end
      File.open(apidoc_cache_file, "w") { |f| f.write(response.body) }
      log.debug "New apidoc loaded from the server"
      load_apidoc
    end

    def log
      @logger
    end

    private

    def legacy_authenticator(config)
      if config[:user] || config[:username] || config[:password]
        Authenticators::BasicAuth.new(config[:user] || config[:username], config[:password])
      elsif config[:credentials] && config[:credentials].respond_to?(:to_params)
        log.warn("Credentials are now deprecated, use custom authenticator instead.")
        Authenticators::CredentialsLegacy.new(config[:credentials])
      elsif config[:oauth]
        log.warn("Passing oauth credentials in hash is now deprecated, use oauth authenticator instead.")
        oauth = config[:oauth]
        Authenticators::Oauth.new(oauth[:consumer_key], oauth[:consumer_secret], oauth[:options])
      end
    end

    def call_client(client, path, args)
      block = rest_client_call_block
      client[path].send(*args, &block)
    end

    def rest_client_call_block
      Proc.new do |response, request, result, &block|
        # include request for rest_client < 1.8.0
        response.request ||= request

        request.args[:authenticator].response(response) if request && request.args[:authenticator]

        if [301, 302, 307].include?(response.code) && [:always, :never].include?(@follow_redirects)
          if @follow_redirects == :always
            log.debug "Response redirected to #{response.headers[:location]}"

            if response.method(:follow_redirection).arity == 0
              # rest-client > 1.8
              response.follow_redirection(&block)
            else
              # rest-client <= 1.8
              response.follow_redirection(request, result, &block)
            end
          else
            raise exception_with_response(response)
          end
        else
          if response.method(:return!).arity.zero?  # 2.0.0+
            response.return!(&block)
          else
            response.return!(request, result, &block)
          end
        end
      end
    end

    def exception_with_response(response)
      begin
        klass = RestClient::Exceptions::EXCEPTIONS_MAP.fetch(response.code)
      rescue KeyError
        raise RestClient.RequestFailed.new(response, response.code)
      end
      raise klass.new(response, response.code)
    end

    def authenticated_client
      resource_config = @resource_config.dup
      resource_config[:authenticator] = get_authenticator

      log.debug "Using authenticator: #{resource_config[:authenticator].name}"

      RestClient::Resource.new(@config[:uri], resource_config)
    end

    def unauthenticated_client
      @client_without_auth ||= RestClient::Resource.new(@config[:uri], @resource_config)
    end

    def get_authenticator
      raise ApipieBindings::AuthenticatorMissingError if @authenticator.nil?
      @authenticator
    end

    def retrieve_apidoc_call(path, options={})
      begin
        http_call('get', path, {},
          {:accept => "application/json"}, {:response => :raw, :reduce_response_log => true})
      rescue
        raise unless options[:safe]
      end
    end

    def find_match(fakes, resource, action, params)
      resource = fakes[[resource, action]]
      if resource
        if resource.has_key?(params)
          return resource[params]
        elsif resource.has_key?(:default)
          return resource[:default]
        end
      end
      return nil
    end

    def cache_extension
      language ? ".#{language}.json" : ".json"
    end

    def set_default_name(default='default')
      cache_file = Dir["#{@apidoc_cache_dir}/*#{cache_extension}"].first
      if cache_file
        File.basename(cache_file, cache_extension)
      else
        default
      end
    end

    def process_data(response)
      data = begin
               JSON.parse((response.respond_to?(:body) ? response.body : response) || '')
             rescue JSON::ParserError
               response.respond_to?(:body) ? response.body : response || ''
             end
      return data
    end

    def inspect_data(obj)
      ApipieBindings::Utils.inspect_data(obj.respond_to?(:response) ? process_data(obj.response) : obj)
    rescue => e
      log.debug "Error during inspecting response: #{e.message}"
      ''
    end

    def create_fake_response(status, body, method, path, args=[])
      request_args = {:method => args.shift || method, :url => path}
      request_args[:params] = args.shift if %w[post put].include?(method.to_s)
      request_args[:headers] = args.shift

      net_http_resp = Net::HTTPResponse.new(1.0, status, "")
      if RestClient.version >= '2.0.0'
        RestClient::Response.create(body, net_http_resp, create_fake_request(request_args))
      elsif RestClient.version >= '1.8.0'
        RestClient::Response.create(body, net_http_resp, request_args, create_fake_request(request_args))
      else
        RestClient::Response.create(body, net_http_resp, request_args)
      end
    end

    def create_fake_request(args)
      RestClient::Request.new(args)
    end
  end
end
