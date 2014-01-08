module ApipieBindings

  class Route

    attr_reader :method, :description

    def initialize(path, method, description="")
      @path = path
      @method = method.downcase
      @description = description
    end

    def params_in_path
      @path.scan(/:([^\/]*)/).map { |m| m.first }
    end

    def path(params=nil)
      return @path if params.nil?

      path = params_in_path.inject(@path) do |p, param_name|
        param_value = (params[param_name.to_sym] or params[param_name.to_s]) or
          raise ArgumentError, "missing param '#{param_name}' in parameters"
        p.sub(":#{param_name}", URI.escape(param_value.to_s))
      end
    end

    def to_s
      "<Route #{@path}>"
    end

    def inspect
      to_s
    end

  end

end
