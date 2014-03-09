require_relative '../spec_helper'

describe 'Home page', type: :feature do
	it 'responds with successful status' do
		visit '/'
		page.status_code.should == 200
	end

	it 'contains the words "Hello, World!"' do
		visit '/'
		page.should have_content 'Hello, World!'
	end
end