require 'sinatra'
require 'sass'
require 'sqlite3'
require 'active_record'
require 'sinatra/activerecord'
require 'rack-rewrite'
require File.expand_path '../main.rb', __FILE__

use Rack::Rewrite do
end

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/katelin.sqlite3.db' 
)

run Sinatra::Application
