require 'apipie_bindings/utilities'

module ApipieBindings

  class Action

    attr_reader :name

    def initialize(resource, name, api)
      @resource = resource
      @name = name.to_sym
      @api = api
    end

    def call(params={}, headers={}, options={})
      @api.call(@resource, @name, params, headers, options)
    end

    def apidoc
      methods = @api.apidoc[:docs][:resources][@resource][:methods].select do |action|
        action[:name].to_sym == @name
      end
      methods.first
    end

    def routes
      apidoc[:apis].map do |api|
        ApipieBindings::Route.new(
          api[:api_url], api[:http_method], api[:short_description])
      end
    end

    def params
      if apidoc
        apidoc[:params].map do |param|
          ApipieBindings::Param.new(param)
        end
      else
        []
      end
    end

    def examples
      apidoc[:examples].map do |example|
        ApipieBindings::Example.parse(example)
      end
    end

    def find_route(params={})
      sorted_routes = routes.sort_by { |r| [-1 * r.params_in_path.count, r.path] }

      suitable_route = sorted_routes.find do |route|
        route.params_in_path.all? { |path_param| params.keys.map(&:to_s).include?(path_param) }
      end

      suitable_route ||= sorted_routes.last
      return suitable_route
    end

    def validate!(params)
      missing_params = missing_params(api_params_tree { |par| par.required? }, params_tree(params))
      raise ApipieBindings::MissingArgumentsError.new(missing_params) unless missing_params.empty?
    end

    def api_params_tree(&block)
      ApipieBindings::Utilities.params_hash_tree(self.params, &block)
    end

    def params_tree(params)
      params.inject([]) do |tree, (key, val)|
        subtree = val.is_a?(Hash) ? { key.to_s => params_tree(val) } : key.to_s
        tree << subtree
        tree
      end
    end

    def missing_params(master, slave)
      missing = []
      master.each do |required_param|
        if required_param.is_a?(Hash)
          key = required_param.keys.first
          slave_hash = slave.select { |p| p.is_a?(Hash) && p[key] }
          missing << missing_params(required_param[key], slave_hash.first ? slave_hash.first[key] : [])
        else
          missing << required_param unless slave.include?(required_param)
        end
      end
      missing.flatten.sort
    end

    def to_s
      "<Action :#{@name}>"
    end

    def inspect
      to_s
    end

  end
end
