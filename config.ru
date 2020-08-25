require 'rubygems'
require 'bundler'

# Auto require Gemfile
# Some gems need a different require name,
# generally specify 'require' in the Gemfile instead of here
Bundler.require :default, ENV['RACK_ENV']


#
# Prometheus
#
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
use Rack::Deflater, if: ->(_, _, _, body) { body.respond_to?( :map ) && body.map(&:bytesize).reduce(0, :+) > 512 }
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

use Rack::Cors do
  allow do
    origins '*'
    resource '/orders', headers: :any, methods: [:post, :options], logger: ->{env['rack.logger']}
  end
end


configure do
  # JWT Auth
  #
  unless ENV['V4_JWT_KEY']
    raise "V4_JWT_KEY required."
  end
  NO_AUTH_PATHS = %w(/version /healthcheck)
  use Rack::JWT::Auth, {secret: ENV['V4_JWT_KEY'], verify: true, options: { algorithm: 'HS256' },
                        exclude: NO_AUTH_PATHS
                      }

  set :server, :puma
  set :logger, Logger.new(STDOUT)
  enable :logging
  require 'i18n'
  require 'i18n/backend/fallbacks'
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(settings.root, 'config', 'locales', '*.yml')]
  I18n.backend.load_translations
  I18n.default_locale = :en
  $logger = Sinatra::Application.logger

  # Email config
  Pony.options = {
                  from: ENV['SMTP_FROM_EMAIL'],
                  via: :smtp,
                  via_options: {
                    address: ENV['SMTP_HOST'],
                    port: ENV['SMTP_PORT']
                  }
                }

end

# require models
current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

Dir["#{current_dir}/helpers/*.rb"].each { |file| require file }

require './app'

run Sinatra::Application