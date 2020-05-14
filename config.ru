require 'rubygems'
require 'bundler'

# Auto require Gemfile
# Some gems need a different require name,
# generally specify 'require' in the Gemfile instead of here
Bundler.require :default, ENV['RACK_ENV']

use Rack::Cors do
  allow do
    origins '*'
    resource '/orders', headers: :any, methods: [:post, :options], logger: ->{env['rack.logger']}
  end
end

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
$logger = Sinatra::Application.logger

# require models
current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

require './app'

run Sinatra::Application