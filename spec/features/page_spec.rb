require_relative '../spec_helper'

describe 'site pages' do

	subject { last_response.body }

	shared_examples_for 'all pages' do
		it { should have_link('Home', href: '/') }
		it { should have_link('Sets', href: '/sets') }
	end

	describe 'Home page', type: :feature do
		before { get '/' }
		it_behaves_like 'all pages'
	end

	describe 'Sets page', type: :feature do
		before { get '/sets' }
		it_behaves_like 'all pages'
		it { should have_selector('h1', text: 'Sets') }

		context 'with existing sets' do
			# we're using Rack::Tests for this since we need to modify the session
			before { define_set_in_session('pants') }
			it 'should show the set' do
				get '/sets'
				subject.should have_content 'pants'
				subject.should have_link('View', href:'/sets/pants')
			end
		end
	end

	# USING CAPYBARA
	# not ideal because this means we can't use redirects and we're not actually testing that the session changes...
	describe 'New set page', type: :feature do
		subject { page }
		before { visit '/sets/new' }
		it_behaves_like 'all pages'
		it { should have_selector('h1', text: 'Create New Set')}

		context 'with valid information' do
			before do
				fill_in 'name', with: 'fizzbuzz'
				fill_in 'urls', with: 'foo, bar, buzz'
			end
			it 'should save' do
				click_button 'Create'
				subject.should have_selector('h1', text: 'fizzbuz')
				subject.should have_link('Edit', href: '/sets/fizzbuzz/edit')
			end
		end

		context 'with no set name' do
			before { fill_in 'urls', with: 'foobar' }
			it 'should not save' do
				click_button 'Create'
				subject.should have_no_content('foobar')
				subject.should have_selector("span[class='error']", text: 'invalid parameters')
			end
		end

		context 'with no links' do
			before { fill_in 'name', with: 'buzzbar' }
			it 'should not save' do
				click_button 'Create'
				subject.should have_no_content('buzzbar')
				subject.should have_selector("span[class='error']", text: 'invalid parameters')
			end
		end
	end

	describe 'Show set page', type: :feature do
		context 'with existing set' do
			before do
				define_set_in_session('pants')
				get '/sets/pants'
			end
			it_behaves_like 'all pages'
			it 'should display the set information' do
				subject.should have_selector('h1', text: 'pants')
			end
			it 'should have edit, play, and delete links' do
				subject.should have_link('Edit', href: '/sets/pants/edit')
				subject.should have_link('Play', href: '/sets/pants/play')
				subject.should have_link('Delete', href:'/sets/pants/delete')
			end
		end

		context 'without existing set' do
			before { get '/sets/pants' }
			it_behaves_like 'all pages'
			it 'should redirect to the new set page' do
				subject.should have_selector('h1', text: 'Create New Set')
			end
			it 'should have the set name filled in' do
				subject.should have_selector("input[value='pants']")
			end
		end
	end

	describe 'Edit set page', type: :feature do
		before { }
		context 'with existing set' do
			pending 'tests for edit page'
			describe 'with valid information' do
				pending 'tests for create action'
			end
			describe 'with invalid information' do
				pending 'test for redirect with error'
			end
		end
		context 'without existing set' do
			pending 'tests for new page'
		end
	end

	describe 'Play set page', type: :feature do
		context 'with existing set' do
			pending 'tests for play page'
			pending 'tests for video embed?'
		end
		context 'without existing set' do
			pending 'tests for new page'
		end
	end

	describe 'Delete set link' do
		context 'with existing set' do
			pending 'test for deletion'
			pending 'test for redirection to sets page'
		end
		context 'without existing sets' do
			pending 'test for redirection to sets page'
		end
	end
end

# helpers

# create a set in the Rack::Test MockSession
def define_set_in_session(name, urls=['a','b','c'])
	get '/', {}, { 'rack.session' => { "sets" => { "pants" => {:name => "pants", :urls => ["#{urls[0]}", "#{urls[1]}", "#{urls[2]}"] } } } }
end