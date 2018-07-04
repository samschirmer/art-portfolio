require 'sinatra'
require 'sqlite3'
require 'mail'
require 'active_record'
require 'dotenv/load'
require 'sinatra/activerecord'
require File.expand_path '../main.rb', __FILE__

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/katelin.sqlite3.db' 
)

run Sinatra::Application
