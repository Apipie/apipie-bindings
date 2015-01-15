require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "action_controller/railtie"
require "action_view/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy

  class ObserverMiddleware
    def initialize(app)
      @app = app
    end

    def log(msg)
      puts msg
    end

    def call(env)
      status, headers, body = @app.call(env)
      if body.respond_to?(:map)
        log "#{env['REQUEST_METHOD']} #{env['PATH_INFO']} #{status}"
        log body.map { |l| "  #{l}"}.join("\n")
      end
      [status, headers, body]
    end
  end

  class Application < Rails::Application
    config.autoload_paths += %w[#{config.root}/app/lib]

    config.middleware.insert_before(ActionDispatch::ShowExceptions, ObserverMiddleware)
  end
end
