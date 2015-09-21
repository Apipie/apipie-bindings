module ApipieBindings
  module Utils
    def self.inspect_data(obj)
      obj.respond_to?(:ai) ? obj.ai : obj.inspect
    end
  end
end
