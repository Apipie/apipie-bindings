module ApipieBindings

  class ConfigurationError < StandardError; end
  class DocLoadingError < StandardError; end
  class AuthenticatorMissingError < StandardError; end

  ErrorData = Struct.new(:kind, :argument, :details)

  class ValidationError < StandardError
    attr_reader :params

    def initialize(params)
      @params = params
    end
  end

  class InvalidArgumentTypesError < ValidationError
    def to_s
      preformated = params.map { |p| "#{p[0]} - #{p[1]} was expected" }
      "#{super}: #{preformated.join(', ')}"
    end
  end

  class MissingArgumentsError < ValidationError
    def to_s
      "#{super}: #{params.join(', ')}"
    end
  end

end
