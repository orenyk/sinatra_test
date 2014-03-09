require 'sinatra'

get '/' do
	erb :application do
		erb :index
	end
end

