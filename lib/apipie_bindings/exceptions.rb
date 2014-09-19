module ApipieBindings

  class ConfigurationError < StandardError; end
  class DocLoadingError < StandardError; end

  class MissingArgumentsError < StandardError
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def to_s
      "#{super}: #{params.join(',')}"
    end

  end

end
