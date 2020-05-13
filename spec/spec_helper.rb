# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'rspec'
require 'pry-byebug'

ENV['RACK_ENV'] = 'test'
Bundler.require :default, ENV['RACK_ENV']

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

require File.expand_path '../../app.rb', __FILE__


module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

# For RSpec 2.x
RSpec.configure do |config|
  config.include RSpecMixin

  config.formatter = :documentation
  config.tty = true
  config.color = true
end