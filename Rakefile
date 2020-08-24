require 'rubygems'
require 'bundler'
Bundler.require :default, ENV['RACK_ENV']


require "sinatra/activerecord/rake"
Dir.glob('lib/tasks/*.rake').each { |r| load r}

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

Dir["#{current_dir}/helpers/*.rb"].each { |file| require file }

namespace :db do
  task :load_config do
    require "./app"
  end
end
