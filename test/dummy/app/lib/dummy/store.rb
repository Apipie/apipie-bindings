require 'forwardable'

module Dummy
  class Store

    class << self
      extend Forwardable
      def_delegators :instance, :index, :show

      def instance
        @store ||= Store.new
      end
    end

    def initialize(base_dir = File.join(Rails.root, '/data/example'))
      @base_dir = base_dir
    end

    def index(path, data = {})
      show_files(path).map { |file| load_json(file) }
    end

    def show(path, data = {})
      file = real_path("#{path}/show.json")
      if File.exists?(file)
        load_json(file)
      end
    end

    private

    def show_files(resource_path)
      Dir.glob(real_path("#{resource_path}/*/show.json"))
    end

    def load_from_path(abstract_path)
      load_json(real_path(abstract_path))
    end

    def load_json(path)
      JSON.load(File.read(path))
    end

    def real_path(path)
      File.join(@base_dir, path)
    end

  end

end
