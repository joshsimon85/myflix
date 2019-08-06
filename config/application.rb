require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module Myflix
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_job.queue_adapter = :sidekiq

    config.assets.enabled = true
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
    end
    config.autoload_paths << "#{Rails.root}/lib"

    Raven.configure do |config|
      config.dsn = 'https://ed92627761944486ba9045c8d02e34d6:7360cd1ba832466586dcff72350734c0@sentry.io/1522294'
    end
  end
end
