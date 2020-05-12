require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'rack/jwt'
current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

#
# JWT Auth
#
unless ENV['V4_JWT_KEY']
  raise "V4_JWT_KEY required."
end
NO_AUTH_PATHS = %w(/version /healthcheck)
use Rack::JWT::Auth, {secret: ENV['V4_JWT_KEY'], verify: true, options: { algorithm: 'HS256' },
                      exclude: NO_AUTH_PATHS
                     }

get '/orders' do
  Order.all.to_json
end

get '/orders/:id' do |id|
  Order.find(id).to_json
end

post '/orders' do
  order = Order.new(params)
  if order.save
    status 201
    order.to_json
  else
    status 400
    order.errors.to_json
  end
end

get '/healthcheck' do
  return nil
end

get '/version' do
  buildtag = Dir.glob('buildtag*').first
  buildtag = if buildtag
    buildtag.gsub('buildtag.','')
  else
    'unknown'
  end

  return {
    buildtag: buildtag,
    git_commit: %x{git log --pretty=format:'%h' -n 1}
  }.to_json
end