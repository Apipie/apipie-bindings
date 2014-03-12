module ApipieBindings

  class Resource

    attr_reader :name

    def initialize(name, api)
      raise NameError.new("Resource '#{name}' does not exist in the API") unless api.apidoc[:docs][:resources].key?(name)
      @name = name
      @api = api
    end

    def call(action, params={}, headers={}, options={})
      @api.call(@name, action, params, headers, options)
    end

    def apidoc
      @api.apidoc[:docs][:resources][@name]
    end

    def actions
      apidoc[:methods].map { |a| action(a[:name].to_sym) }
    end

    def has_action?(name)
      apidoc[:methods].any? { |action| action[:name].to_sym == name }
    end

    def action(name)
      ApipieBindings::Action.new(@name, name, @api)
    end

    def singular_name
      ApipieBindings::Inflector.singularize(@name.to_s)
    end

    def to_s
      "<Resource :#{@name}>"
    end

    def inspect
      to_s
    end

  end

end
