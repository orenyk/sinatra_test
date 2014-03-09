require_relative '../spec_helper'

describe 'site pages' do

	subject { page }

	shared_examples_for 'all pages' do
		it { should have_link('Home', href: '/') }
		it { should have_link('About', href: '/about') }
		it { should have_link('Lists', href: '/lists') }
	end

	describe 'Home page', type: :feature do
		before { visit '/' }
		it_behaves_like 'all pages'
	end
end