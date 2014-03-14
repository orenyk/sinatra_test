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
		@vidnums = params[:vidnums].split(',').map(&:strip)
		[@name, @vidnums]
	end

	# write set to session
	def write_set(name, vidnums)
		@sets = session[:sets] ? session[:sets] : {}
		@sets[name] = { name: name, vidnums: @vidnums }
		session[:sets] = @sets
	end

	# remove set from session
	def remove_set(name)
		@sets = session[:sets]
		if @sets
			@sets.delete(name)
			session[:sets] = @sets
		end
	end

	def randomvideo(set)
		set.sample
	end

	def embedyoutube(videonumber)
		%{
		<body style="margin:0;">
		<object height="100%" width="100%"><param name="movie" value="http://www.youtube.com/v/#{videonumber}&autoplay=1" /><embed height="100%" src="http://www.youtube.com/v/#{videonumber}&autoplay=1" type="application/x-shockwave-flash" width="100%"></embed></object>
		</body>
		}
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
	@name, @vidnums = extract_set_params()
	# if invalid parameters
	if @name.empty? or @vidnums == []
		@error = 'invalid parameters'
		erb :application do
			erb :new
		end
	else
		# write set
		@sets = write_set(@name, @vidnums)
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
			@vidnums = @set[:vidnums]
			erb :edit
		else
			erb :new
		end
	end
end

# update sets
put '/sets/:oldname/?' do
	@oldname = params[:oldname] == "new" ? "" : params[:oldname]
	@set = extract_set(@oldname)
	# if set exists
	if @set
		@name, @vidnums = extract_set_params()
		# if invalid parameters
		if @name.empty? or @vidnums == []
			@error = 'invalid parameters'
			@name = @oldname
			@vidnums = @set[:vidnums]
			erb :application do
				erb :edit
			end
		else
			# if no name change
			if @name == @oldname
				write_set(@name, @vidnums)
			# with name change
			else
				write_set(@name, @vidnums)
				remove_set(@oldname)
			end
			@set = @sets[@name]
			erb :application do
				erb :show
			end
		end
	# if set doesn't exist
	else
		@name = @oldname
		erb :application do
			erb :new
		end
	end
end

# delete sets - display the delete form if set exists
get '/sets/:name/delete/?' do
	@name = params[:name]
	@set = extract_set(@name)
	if @set
		erb :application do
			erb :delete
		end
	else
		@sets = session[:sets]
		@error = 'invalid set'
		erb :application do
			erb :index
		end
	end
end

delete '/sets/:name/?' do
	@name = params[:name]
	@set = extract_set(@name)
	if @set
		remove_set(@name)
		@sets = session[:sets]
		erb :application do
			erb :index
		end
	else
		@sets = session[:sets]
		@error = 'invalid set'
		erb :application do
			erb :index
		end
	end
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