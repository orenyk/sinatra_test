require_relative '../spec_helper'

describe 'site pages' do

	subject { page }

	shared_examples_for 'all pages' do
		it { should have_link('Home', href: '/') }
		it { should have_link('Sets', href: '/sets') }
	end

	describe 'Home page', type: :feature do
		before { visit '/' }
		it_behaves_like 'all pages'
	end

	describe 'Sets page', type: :feature do
		before { visit '/sets' }
		it_behaves_like 'all pages'
		it { should have_selector('h1', text: 'Sets') }

		context 'with existing sets' do
			# we're using Rack::Tests for this since we need to modify the session
			before { define_set_in_session('pants') }
			it 'should show the set' do
				get '/sets'
				expect(last_response.body).to have_content 'pants'
			end
		end
	end

	describe 'New set page', type: :feature do
		before { visit '/sets/new' }

		context 'with valid information' do
			before do
				fill_in 'name', with: 'fizzbuzz'
				fill_in 'urls', with: 'foo, bar, buzz'
			end
			it 'should save' do
				click_button 'Create'
				expect(page).to have_content 'fizzbuzz'
				expect(page).to have_content 'View'
			end
		end

		context 'with no set name' do
			before { fill_in 'urls', with: 'foobar' }
			it 'should not save' do
				click_button 'Create'
				expect(page).to have_no_content('foobar')
			end
		end

		context 'with no links' do
			before { fill_in 'name', with: 'buzzbar' }
			it 'should not save' do
				click_button 'Create'
				expect(page).to have_no_content('buzzbar')
			end
		end
	end

end

# helpers
def define_set_in_session(name)
	get '/', {}, { 'rack.session' => { sets: { pants: { name: "#{name}", urls: ["a", "b", "c"] } } } }
end