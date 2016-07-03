module ApipieBindings

  class Resource

    attr_reader :name

    def initialize(name, api)
      raise NameError.new("Resource '#{name}' does not exist in the API") unless api.apidoc[:docs][:resources].key?(name)
      @name = name
      @api = api
    end

    # Execute an action on a resource
    #
    # @param action [Symbol]
    # @param params [Hash]
    # @param headers [Hash]
    # @param options [Hash]
    # @return [Hash]
    def call(action, params={}, headers={}, options={})
      @api.call(@name, action, params, headers, options)
    end

    # Get API documentation for a resource
    #
    # @return [Hash]
    def apidoc
      @api.apidoc[:docs][:resources][@name]
    end

    # Get list of all actions for a resource
    #
    # @return [Array<ApipieBindings::Action>]
    def actions
      apidoc[:methods].map { |a| action(a[:name].to_sym) }
    end

    # Determine if resource has a particular action
    #
    # @param name [Symbol] name of action to check
    # @return [Bool]
    def has_action?(name)
      apidoc[:methods].any? { |action| action[:name].to_sym == name }
    end

    # Get ApipieBindings::Action
    #
    # @param name [Symbol] action name
    # @return [ApipieBindings::Action]
    def action(name)
      ApipieBindings::Action.new(@name, name, @api)
    end

    # Get simiple string representation
    #
    # @return [String] ApipieBindings::Resource as a string
    def singular_name
      ApipieBindings::Inflector.singularize(@name.to_s)
    end

    # Get string representation
    #
    # @return [String] ApipieBindings::Resource as a string
    def to_s
      "<Resource :#{@name}>"
    end

    # Get string representation
    #
    # @return [String] ApipieBindings::Resource as a string
    # @note same as to_s method
    def inspect
      to_s
    end

  end

end
