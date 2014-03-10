require 'sinatra'
require 'sinatra/reloader' if development?

# Configure application
configure do
	enable :sessions unless test?
	enable :method_override
end

helpers do
	# check for set existence
	def set_exists?(set)
		@sets = session[:sets]
		!@sets[set]
	end
end

# home page
get '/' do
	erb :application do
		erb :root
	end
end

# sets page
get '/sets/?' do
	@sets = session[:sets] ? session[:sets] : {}
	erb :application do
		erb :index
	end
end

# create and view sets with the same path?
get '/sets/:name/?' do
	@name = params[:name] == "new" ? "" : params[:name]
	@sets = session[:sets]
	@set = @sets ? @sets[@name] : nil
	erb :application do
		if @set
			erb :show
		else
			erb :new
		end
	end
end

# create a set
post '/sets/new' do
	@name = params[:name]
	@urls = params[:urls].split(',').map(&:strip)
	if @name.empty? or @urls == []
		@error = 'invalid parameters'
		erb :application do
			erb :new
		end
	else
		@sets = session[:sets] ? session[:sets] : {}
		@sets[@name] = { name: @name, urls: @urls }
		session[:sets] = @sets

		erb :application do
			erb :index
		end
	end

	# redirect to("/sets/#{@name}")
	# NOTE: we can't use redirects if we want to test the responses to requests
end

get '*/params/?' do
	erb :application do
		params.inspect
	end
end

get '/session/?' do
	erb :application do
		session.inspect
	end
end

get '/session/clear' do
	session.clear

	redirect to('/session')
end