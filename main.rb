# MODELS
class Meta < ActiveRecord::Base
	self.table_name = 'meta'
end
class Piece < ActiveRecord::Base
	has_many :images
end
class Image < ActiveRecord::Base
	belongs_to :piece
end

helpers do
	def protected!
	return if authorized?
		headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
		halt 401, "Not authorized\n"
	end

	def authorized?
		@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		@auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['USERNAME'], ENV['PASSWORD']]
	end
end

# ROUTING
get '/style.css' do
	scss :"/css/style"
end

get '/' do
	@page = Meta.find_by(page: 'work')
	@pieces = Piece.where(visible: 1)
  erb :index
end
post '/work' do
	protected!
	work = Meta.find_by(page: 'work')
	if work.update(content: params['content'], header: params['header'])
		redirect '/admin'
	end
end

get '/pieces/:id' do
	id = params['id'].split('-')[-1]
	@piece = Piece.find(id)
	erb :piece
end

get '/about' do
	@page = Meta.find_by(page: 'about')
  erb :about
end
post '/about' do
	protected!
	about = Meta.find_by(page: 'about')
	if about.update(content: params['content'], header: params['header'])
		redirect '/admin'
	end
end

get '/contact' do
  erb :contact
end

post '/contact' do 
	name = params['name']
	email = params['email']
	message = params['message']

	mail = Mail.new do
	  from     ENV['EMAIL_FROM']
	  to       ENV['EMAIL_TO']
	  subject  'Someone filled out the form on your website'
	  body     "New message from <#{name}>#{email}:\n#{message}\n"
	end
#	mail.delivery_method :logger, { 
	mail.delivery_method :smtp, { 
		:address              => 'smtp.gmail.com',
		:port                 => 587,
		:user_name            => ENV['EMAIL_USERNAME'],
		:password             => ENV['EMAIL_PASSWORD'],
		:authentication       => 'plain',
		:enable_starttls_auto => true  
	}
	mail.deliver!
	erb :thanks
end

# ADMIN
get '/admin' do
	protected!
	@about = Meta.find_by(page: 'about')
	@work = Meta.find_by(page: 'work')
	@pieces = Piece.all
	@images = Image.all
	erb :admin
end

get '/admin/edit/:id' do
	protected!
	@piece = Piece.find(params['id'])
	erb :edit
end

post '/admin/update' do
	protected!
	piece = Piece.find(params['id'])
	if piece.update(title: params['title'], subtitle: params['subtitle'], visible: params['visible'], description: params['description'])
		params['priorities'].each do |p|
			image = Image.find(p[0])		
			image.update(priority: p[1])
		end
		redirect '/admin'
	end
end

after do
  ActiveRecord::Base.connection.close
end
