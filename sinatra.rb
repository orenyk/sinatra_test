require 'sinatra'
require 'sinatra/reloader' if development?

# Configure application
configure do
	enable :sessions
	enable :method_override
end

helpers do
	# extract the set with a given name
	def extract_set(name)
		@sets = session[:sets]
		@sets ? @sets[name] : nil
	end

	# extract set parameters from form
	def extract_set_params()
		@name = params[:name]
		@urls = params[:urls].split(',').map(&:strip)
		[@name, @urls]
	end

	# write set to session
	def write_set(name, urls)
		@sets = session[:sets] ? session[:sets] : {}
		@sets[@name] = { name: @name, urls: @urls }
		session[:sets] = @sets
	end

	# remove set from session
	def remove_set(name)
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
	@name, @urls = extract_set_params()
	# if invalid parameters
	if @name.empty? or @urls == []
		@error = 'invalid parameters'
		erb :application do
			erb :new
		end
	else
		# write set
		@sets = write_set(@name, @urls)
		erb :application do
			@set = @sets[@name]
			erb :show
		end
	end
end

# edit sets
get '/sets/:name/edit/?' do
	@name = params[:name]
	@set = extract_set(@name)
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
put '/sets/:oldname/?' do
	@oldname = params[:oldname]
	@name, @urls = extract_set_params()
	# if invalid parameters
	if @name.empty? or @urls == []
		@error = 'invalid parameters'
		# redirect to edit
	else
		# if no name change
		if @name == @oldname
			write_set(@name, @urls)
		# with name change
		else
			write_set(@name, @urls)
			remove_set(@oldname)
		end
		erb :application do
			@set = @sets[@name]
			erb :show
		end
	end
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
	@set = extract_set(@name)
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