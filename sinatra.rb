require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
	erb :application do
		erb :index
	end
end

get '/lists' do
	erb :application do
		erb :lists
	end
end