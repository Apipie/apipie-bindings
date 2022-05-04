module ApipieBindings

  class ConfigurationError < StandardError; end
  class DocLoadingError < StandardError
    attr_reader :original_error
    def initialize(msg, original_error)
      super(msg)
      @original_error = original_error
    end
  end
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

  class AuthenticatorError < StandardError
    attr_reader :type, :cause, :original_error

    def initialize(type, cause, original_error)
      @type = type
      @cause = cause
      @original_error = original_error
    end
  end
end
