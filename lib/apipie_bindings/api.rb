require 'json'
require 'rest_client'
require 'oauth'
module ApipieBindings

  class API

    def initialize(config, options={})
      @apidoc_cache_dir = config[:apidoc_cache_dir] || File.join('/tmp/apipie_bindings', config[:uri].tr(':/', '_'))
      @apidoc_cache_file = config[:apidoc_cache_file] || File.join(@apidoc_cache_dir, 'apidoc.json')
      @api_version = config[:api_version] || 2

      config = config.dup
      # self.logger = config.delete(:logger)

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

    def load_apidoc
      if File.exist?(@apidoc_cache_file)
        JSON.parse(File.read(@apidoc_cache_file), :symbolize_names => true)
      end
    end

    def retrieve_apidoc
      FileUtils.mkdir_p(@apidoc_cache_dir) unless File.exists?(@apidoc_cache_dir)

      apidoc_url = @config[:uri] + '/apidoc'
      apidoc_url << "/v#{@api_version}.json"
      response = Net::HTTP.get_response(URI.parse(apidoc_url))
      unless response.code == "200"
        raise "Could not load data from #{url}"
      end
      body = response.body
      File.open(@apidoc_cache_file, "w") { |f| f.write(body) }

      load_apidoc
    end

    def apidoc
      @apidoc = @apidoc || load_apidoc || retrieve_apidoc
      @apidoc
    end

    def has_resource?(name)
      apidoc[:docs][:resources].has_key? name
    end

    def resource(name)
      ApipieBindings::Resource.new(name, self)
    end

    def resources
      apidoc[:docs][:resources].keys
    end

    def call(resource_name, action_name, params, headers)
      resource = resource(resource_name)
      action = resource.action(action_name)
      route = action.find_route(params)
      #action.validate(params)
      return http_call(
        route.method,
        route.path(params),
        params.reject { |par, _| route.params_in_path.include? par.to_s },
        headers)
    end


    def http_call(http_method, path, params = { }, headers = { })
      headers ||= { }

      args = [http_method]
      if %w[post put].include?(http_method.to_s)
        args << params.to_json
      else
        headers[:params] = params if params
      end

      # TODO logging
      # logger.info "#{http_method.upcase} #{path}"
      # logger.debug "Params: #{params.inspect}"
      # logger.debug "Headers: #{headers.inspect}"

      args << headers if headers
      process_data(@client[path].send(*args))
    end

    def process_data(response)
      data = begin
               JSON.parse(response.body)
             rescue JSON::ParserError
               response.body
             end
      # logger.debug "Returned data: #{data.inspect}"
      return data, response
    end

  end

end
