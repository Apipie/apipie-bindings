module ApipieBindings

  class ConfigurationError < StandardError; end
  class DocLoadingError < StandardError; end

  class ValidationError < StandardError; end

  class InvalidArgumentTypeError < ValidationError
    attr_reader :param, :expected_type

    def initialize(param, expected_type)
      @param = param
      @expected_type = expected_type
    end

    def to_s
      "#{super}: #{param} - #{expected_type} was expected"
    end
  end

  class MissingArgumentsError < ValidationError
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def to_s
      "#{super}: #{params.join(',')}"
    end

  end

end
