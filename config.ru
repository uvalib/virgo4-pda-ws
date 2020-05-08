require './app'
#run Sinatra::Application
require "sinatra/reloader" if development?

require File.join(File.dirname(__FILE__), '<%= app_file -%>')

run <%= app_class -%>