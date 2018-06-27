require 'sinatra'
require 'sass'
require 'sqlite3'
require 'active_record'
require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/katelin.sqlite3.db' 
)

# MODELS
class Piece < ActiveRecord::Base
	has_many :images
end

class Image < ActiveRecord::Base
	belongs_to :piece
end

# ROUTING
get '/' do
	@pieces = Piece.where(visible: 1)
  erb :index
end

get '/pieces/:id' do
	@piece = Piece.find(params['id'])
	erb :piece
end

get '/about' do
  erb :about
end

get '/contact' do
  erb :contact
end

after do
  ActiveRecord::Base.connection.close
end
