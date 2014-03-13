require 'sinatra'
require 'sinatra/reloader' if development?

# Configure application
configure do
	enable :sessions
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

		redirect('/sets')
	end
end

# edit sets
get '/sets/:name/edit/?' do
	@name = params[:name]
	@sets = session[:sets]
	@set = @sets ? @sets[@name] : nil
	erb :application do
		if @set
			@urls = @set[:urls]
			erb :edit
		else
			erb :new
		end
	end
end

# update sets
put '/sets/:name/?' do
end

# delete sets - currently use GET since I'm not sure how to fake a DELETE request
get '/sets/:name/delete/?' do
end

# play set - TODO
get '/sets/:name/play/?' do
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

# sets page
get '/sets/?' do
	@sets = session[:sets] ? session[:sets] : {}
	erb :application do
		erb :index
	end
end


get '/sets/:name/params/?' do
	erb :application do
		params.inspect
	end
end

get '/sets/:name/:method/params/?' do
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


# FOR LATER?
# # can we get all the methods in one route?
# get '/sets/?:name?/?:method?/?' do
# 	@sets = session[:sets] ? session[:sets] : {}
# 	@name = params[:name]
# 	if @name.empty?
# 		@method = 'index'
# 	else
# 		@set = @sets ? @sets[@name] : nil
# 		@method = params[:method]
# 		if @method.empty?
# 			@method = 'show'
# 		end