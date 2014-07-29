require 'apipie_bindings/utilities'

module ApipieBindings

  class Param

    attr_reader :name, :params, :expected_type, :description, :validator

    def initialize(param)
      param = ApipieBindings::IndifferentHash.new(param)
      @name = param[:name]
      params = param[:params] || []
      @params = params.map { |p| ApipieBindings::Param.new(p) }
      @expected_type = param[:expected_type].to_sym
      @description = param[:description].gsub(/<\/?[^>]+?>/, "")
      @required = param[:required] || @params.inject(false) { |req, par| req ||= par.required? }
      @validator = param[:validator]
    end

    def tree(&block)
      ApipieBindings::Utilities.params_hash_tree(@params, &block)
    end

    def required?
      @required
    end

    def to_s
      "<Param #{ required? ? '*' : '' }#{@name} (#{@expected_type.to_s.capitalize})>"
    end

    def inspect
      to_s
    end

  end

end
