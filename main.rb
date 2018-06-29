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
	id = params['id'].split('-')[-1]
	@piece = Piece.find(id)
	erb :piece
end

get '/about' do
  erb :about
end

get '/contact' do
  erb :contact
end

post '/contact' do 
	name = params['name']
	email = params['email']
	message = params['message']

	mail = Mail.new do
	  from     'katelinvhull@gmail.com'
	  to       'katelinvhull@gmail.com'
	  subject  'Someone filled out the form on your website'
	  body     "New message from <#{name}>#{email}:\n#{message}\n"
	end
	mail.delivery_method :logger, { 
#	mail.delivery_method :smtp, { 
		:address              => "smtp.gmail.com",
		:port                 => 587,
		:user_name            => '<username>',
		:password             => '<password>',
		:authentication       => 'plain',
		:enable_starttls_auto => true  
	}
	mail.deliver!
	erb :thanks
end

# ADMIN
get '/admin/edit/:id' do
	@piece = Piece.find(params['id'])
	erb :admin
end

post '/admin/update' do
	piece = Piece.find(params['id'])
	if piece.update(title: params['title'], subtitle: params['subtitle'], description: params['description'])
		erb :thanks
	end
end

after do
  ActiveRecord::Base.connection.close
end
