# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'rspec'
require 'pry-byebug'

ENV['RACK_ENV'] = 'test'
Bundler.require :default, ENV['RACK_ENV']

current_dir = Dir.pwd
Dir["#{current_dir}/{models,helpers}/*.rb"].each { |file| require file }

require File.expand_path '../../app.rb', __FILE__

namespace :db do
  task :load_config do
    require "./app"
  end
end


module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  def jwt_claims
    {role: 'guest', canPurchase: true, userId: 'test'}
  end
  # creates a barebones JWT for testing
  def generate_jwt options


    "Bearer " + Rack::JWT::Token.encode(jwt_claims.merge(options), ENV['V4_JWT_KEY'], 'HS256')
  end
end

# For RSpec 2.x
RSpec.configure do |config|
  config.include RSpecMixin

  config.formatter = :documentation
  config.tty = true
  config.color = true
end

