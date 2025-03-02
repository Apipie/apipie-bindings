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
      @required = !!param[:required]
      @validator = param[:validator]
      # We expect a value from API param docs, but in case it's not there, we want to show it in help by default
      @show = param[:show].nil? ? true : param[:show]
    end

    def required?
      @required
    end

    def show?
      @show
    end

    def to_s
      "<Param #{ required? ? '*' : '' }#{@name} (#{@expected_type.to_s.capitalize})>"
    end

    def inspect
      to_s
    end

  end

end
