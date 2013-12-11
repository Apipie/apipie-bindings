module ApipieBindings

  class Resource

    def initialize(name, api)
      @name = name
      @api = api
    end

    def call(action, params={}, headers={}, options={})
      @api.call(@name, action, params, headers, options)
    end

    def resource_doc
      @api.apidoc[:docs][:resources][@name]
    end

    def actions
      resource_doc[:methods].map { |action| action[:name].to_sym }
    end

    def has_action?(name)
      resource_doc[:methods].any? { |action| action[:name].to_sym == name }
    end

    def action(name)
      ApipieBindings::Action.new(@name, name, @api)
    end

  end

end
