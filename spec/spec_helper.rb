require 'simplecov'
SimpleCov.start
require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'pry'

Bundler.setup
require 'cloak_id' # and any other gems you need
require 'support/test_model'
require 'zlib'

RSpec.configure do |config|
  config.debug = false
  config.color_enabled = true
  config.formatter = 'documentation'
end

ActiveRecord::Base.establish_connection adapter:'sqlite3', database:':memory:'

load File.dirname(__FILE__) + '/schema.rb'