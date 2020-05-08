require 'rubygems'
require 'bundler/setup'

# myapp.rb
require 'sinatra'
require 'json'
require "sinatra/activerecord"
current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }


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