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
			before { post '/sets/new', params={ name: 'pants', urls: 'a, b,c' } }
			it 'should show the set' do
				visit '/sets'
				last_response.body.should have_content 'pants'
			end
		end
	end

	describe 'New set page', type: :feature do
		before { visit '/sets/new' }
		context 'with no set name' do
			before { fill_in 'urls', with: 'foobar' }
			it 'should not save' do
				click_button 'submit'
				expect(page).to have_no_content('foobar')
			end
		end

		context 'with no links' do
			before { fill_in 'name', with: 'buzzbar' }
			it 'should not save' do
				click_button 'submit'
				expect(page).to have_no_content('buzzbar')
			end
		end
	end

end