require 'json'
require 'rest_client'
require 'oauth'
require 'logging'
require 'awesome_print'
module ApipieBindings

  class API

    attr_reader :apidoc_cache_name, :fake_responses
    attr_writer :dry_run

    def initialize(config, options={})
      @uri = config[:uri]
      @api_version = config[:api_version] || 2
      @apidoc_cache_dir = config[:apidoc_cache_dir] || File.join('/tmp/apipie_bindings', @uri.tr(':/', '_'))
      @apidoc_cache_name = config[:apidoc_cache_name] || set_default_name
      @dry_run = config[:dry_run] || false
      @fake_responses = {}

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
      if File.exist?(apidoc_cache_file)
        JSON.parse(File.read(apidoc_cache_file), :symbolize_names => true)
      end
    end

    def retrieve_apidoc
      FileUtils.mkdir_p(@apidoc_cache_dir) unless File.exists?(@apidoc_cache_dir)
      path = "/apidoc/v#{@api_version}.json"
      begin
        response = http_call('get', path, {},
          {:accept => "application/json;version=1"}, {:response => :raw})
      rescue
        raise "Could not load data from #{@uri}#{path}"
      end
      File.open(apidoc_cache_file, "w") { |f| f.write(response.body) }
      ApipieBindings.log.debug "New apidoc loaded from the server"
      load_apidoc
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

    def resources
      apidoc[:docs][:resources].keys.map { |res| resource(res) }
    end

    def call(resource_name, action_name, params={}, headers={}, options={})
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


    def http_call(http_method, path, params={}, headers={}, options={})
      headers ||= { }

      args = [http_method]
      if %w[post put].include?(http_method.to_s)
        args << params.to_json
      else
        headers[:params] = params if params
      end

      ApipieBindings.log.info "#{http_method.to_s.upcase} #{path}"
      ApipieBindings.log.debug "Params: #{params.ai}"
      # logger.debug "Headers: #{headers.inspect}"

      args << headers if headers

      if dry_run?
        empty_response = ApipieBindings::Example.new('', '', '', 200, '')
        ex = options[:fake_response ] || empty_response
        response = RestClient::Response.create(ex.response, ex.status, ex.args)
      else
        response = @client[path].send(*args)
        update_cache(response.headers[:apipie_apidoc_hash])
      end

      result = options[:response] == :raw ? response : process_data(response)
      ApipieBindings.log.debug "Response #{result.ai}"
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
        ApipieBindings.log.debug "Cache expired. (#{@apidoc_cache_name} -> #{cache_name})"
        @apidoc_cache_name = cache_name
      end
    end

    def clean_cache
      @apidoc = nil
      Dir["#{@apidoc_cache_dir}/*.json"].each { |f| File.delete(f) }
    end

    private

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
