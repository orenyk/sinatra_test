require 'sinatra'
require 'sinatra/reloader' if development?

# Configure application
configure do
	enable :sessions unless test?
	enable :method_override
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

get '/lists' do
	erb :application do
		erb :lists
	end
end