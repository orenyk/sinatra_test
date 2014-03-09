ENV['RACK_ENV'] = 'test'
require_relative '../sinatra'
require 'rspec'
require 'capybara/rspec'

Capybara.app = Sinatra::Application.new