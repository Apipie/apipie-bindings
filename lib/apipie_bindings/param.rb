require 'active_support/core_ext/hash/indifferent_access'

module ApipieBindings

  class Param

    attr_reader :name, :params, :expected_type, :description, :validator

    def initialize(param)
      param = param.with_indifferent_access
      @name = param[:name]
      params = param[:params] || []
      @params = params.map { |p| ApipieBindings::Param.new(p) }
      @expected_type = param[:expected_type].to_sym
      @description = param[:description].gsub(/<\/?[^>]+?>/, "")
      @required = param[:required]
      @validator = param[:validator]
    end

    def required?
      @required
    end

  end

end
