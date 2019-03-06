module ApipieBindings

  class Example

    attr_reader :http_method, :path, :args, :status, :response

    def initialize(http_method, path, args, status, response)
      @http_method = http_method
      @path = path
      @args = args
      @status = status.to_i
      @response = response
    end

    def self.parse(example)
      prep = /(\w+)\ ([^\n]*)\n?(.*)?\n(\d+)\n(.*)/m.match(example)
      new(*prep[1..5]) if prep
    end
  end

end
