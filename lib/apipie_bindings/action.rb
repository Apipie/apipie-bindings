module ApipieBindings

  class Action

    attr_reader :name, :resource

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

    def validate!(parameters)
      errors = validate(params, parameters)

      missing_arguments, errors = errors.partition { |e| e.kind == :missing_argument }
      missing_arguments.map! { |e| e.argument }
      raise ApipieBindings::MissingArgumentsError.new(missing_arguments) unless missing_arguments.empty?

      invalid_types, errors = errors.partition { |e| e.kind == :invalid_type }
      invalid_types.map! { |e| [e.argument, e.details] }
      raise ApipieBindings::InvalidArgumentTypesError.new(invalid_types) unless invalid_types.empty?

      errors.map! { |e| e.argument }
      raise ApipieBindings::ValidationError.new(errors) unless errors.empty?
    end

    def validate(params, values, path=nil)
      return [ErrorData.new(:invalid_type, path, 'Hash')] unless values.respond_to?(:keys)
      # check required
      required_keys = params.select(&:required?).map(&:name)
      given_keys = values.keys.select { |par| !values[par].nil? }.map(&:to_s)
      missing_params = required_keys - given_keys
      errors = missing_params.map { |p| ErrorData.new(:missing_argument, add_to_path(path, p)) }

      # check individuals one by one
      values.each do |param, value|
        param_description = params.find { |p| p.name == param.to_s }
        if param_description

          # nested?
          if !param_description.params.empty? && !value.nil?
            # array
            if param_description.expected_type == :array
              value.each.with_index do |item, i|
                errors += validate(param_description.params, item, add_to_path(path, param_description.name, i))
              end
            end
            # hash
            if param_description.expected_type == :hash
              errors += validate(param_description.params, value, add_to_path(path, param_description.name))
            end
          end
        end
      end

      errors
    end

    def add_to_path(path, *additions)
      path ||= ''
      additions.inject(path) { |new_path, add| new_path.empty? ? "#{add}" : "#{new_path}[#{add}]" }
    end

    def to_s
      "<Action :#{@name}>"
    end

    def inspect
      to_s
    end
  end
end
