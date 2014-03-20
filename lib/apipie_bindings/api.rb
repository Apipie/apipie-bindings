require 'json'
require 'rest_client'
require 'oauth'
require 'awesome_print'
require 'apipie_bindings/rest_client_oauth'
require 'logger'
require 'tmpdir'
module ApipieBindings

  class API

    attr_reader :apidoc_cache_name, :fake_responses
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
    # @option config [Hash] :headers additional headers to send with the requests
    # @option config [String] :api_version ('1') version of the API
    # @option config [String] :apidoc_cache_dir ('/tmp/apipie_bindings/<URI>') where
    #   to cache the JSON description of the API
    # @option config [String] :apidoc_cache_name ('default.json') name of te cache file.
    #   If there is cache in the :apidoc_cache_dir, it is used.
    # @option config [Hash] :fake_responses ({}) responses to return if used in dry run mode
    # @option config [Bool] :dry_run (false) dry run mode allows to test your scripts
    #   and not touch the API. The results are taken form exemples in the API description
    #   or from the :fake_responses
    # @option config [Bool] :aggressive_cache_checking (false) check before every request
    #   if the local cache of API description (JSON) is up to date. By default it is checked
    #   *after* each API request
    # @option config [Object] :logger (Logger.new(STDERR)) custom logger class
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
      @apidoc_cache_dir = config[:apidoc_cache_dir] || File.join(Dir.tmpdir, 'apipie_bindings', @uri.tr(':/', '_'))
      @apidoc_cache_name = config[:apidoc_cache_name] || set_default_name
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
      headers.merge!(config[:headers]) unless config[:headers].nil?
      headers.merge!(options.delete(:headers)) unless options[:headers].nil?

      resource_config = {
        :user     => config[:username],
        :password => config[:password],
        :oauth    => config[:oauth],
        :headers  => headers
      }.merge(options)

      @client = RestClient::Resource.new(config[:uri], resource_config)
      @config = config
    end

    def set_default_name(default='default')
      cache_file = Dir["#{@apidoc_cache_dir}/*.json"].first
      if cache_file
        File.basename(cache_file, ".json")
      else
        default
      end
    end

    def apidoc_cache_file
       File.join(@apidoc_cache_dir, "#{@apidoc_cache_name}.json")
    end

    def load_apidoc
      check_cache if @aggressive_cache_checking
      if File.exist?(apidoc_cache_file)
        JSON.parse(File.read(apidoc_cache_file), :symbolize_names => true)
      end
    end


    def apidoc
      @apidoc = @apidoc || load_apidoc || retrieve_apidoc
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
    # with other attributes neccessary to do an API call.
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
    # @example show user data
    #   call(:users, :show, :id => 1)
    def call(resource_name, action_name, params={}, headers={}, options={})
      check_cache if @aggressive_cache_checking
      resource = resource(resource_name)
      action = resource.action(action_name)
      route = action.find_route(params)
      #action.validate(params)
      options[:fake_response] = find_match(fake_responses, resource_name, action_name, params) || action.examples.first if dry_run?
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
    # @example show user data
    #   http_call('get', '/api/users/1')
    def http_call(http_method, path, params={}, headers={}, options={})
      headers ||= { }

      args = [http_method]
      if %w[post put].include?(http_method.to_s)
        args << params
      else
        headers[:params] = params if params
      end

      log.info "#{http_method.to_s.upcase} #{path}"
      log.debug "Params: #{params.ai}"

      args << headers if headers

      if dry_run?
        empty_response = ApipieBindings::Example.new('', '', '', 200, '')
        ex = options[:fake_response ] || empty_response
        response = RestClient::Response.create(ex.response, ex.status, args)
      else
        response = @client[path].send(*args)
        update_cache(response.headers[:apipie_checksum])
      end

      result = options[:response] == :raw ? response : process_data(response)
      log.debug "Response #{result.ai}"
      result
    end

    def process_data(response)
      data = begin
               JSON.parse(response.body)
             rescue JSON::ParserError
               response.body
             end
      # logger.debug "Returned data: #{data.inspect}"
      return data
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
      Dir["#{@apidoc_cache_dir}/*.json"].each { |f| File.delete(f) }
    end

    def check_cache
      begin
        response = http_call('get', "/apidoc/apipie_checksum", {}, {:accept => "application/json"})
        response['checksum']
      rescue
        nil
      end
    end

    def log
      @logger
    end

    private

    def retrieve_apidoc
      FileUtils.mkdir_p(@apidoc_cache_dir) unless File.exists?(@apidoc_cache_dir)
      path = "/apidoc/v#{@api_version}.json"
      begin
        response = http_call('get', path, {},
          {:accept => "application/json"}, {:response => :raw})
      rescue
        raise ApipieBindings::DocLoadingError.new(
          "Could not load data from #{@uri}#{path}\n"\
          " - is your server down?\n"\
          " - was rake apipie:cache run when using apipie cache? (typical production settings)")
      end
      File.open(apidoc_cache_file, "w") { |f| f.write(response.body) }
      log.debug "New apidoc loaded from the server"
      load_apidoc
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

  end

end
