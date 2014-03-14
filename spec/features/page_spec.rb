require_relative '../spec_helper'

describe 'site pages' do

	subject { last_response.body }

	shared_examples_for 'all pages' do
		it { should have_link('Home', href: '/') }
		it { should have_link('Sets', href: '/sets') }
	end

	shared_examples_for 'new page' do
		it { should have_selector('h1', text: 'Create New Set') }
		it { should have_selector("input[value='pants']") }
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
				fill_in 'name', with: 'pants'
				fill_in 'vidnums', with: 'foo, bar, buzz'
			end
			it 'should save' do
				click_button 'Create'
				subject.should have_selector('h1', text: 'pants')
				subject.should have_link('Edit', href: '/sets/pants/edit')
			end
		end

		context 'with no set name' do
			before { fill_in 'vidnums', with: 'foobar' }
			it 'should not save' do
				click_button 'Create'
				subject.should have_selector('h1', text: 'Create New Set')
				subject.should have_selector("span[class='error']", text: 'invalid parameters')
			end
		end

		context 'with no links' do
			before { fill_in 'name', with: 'buzzbar' }
			it 'should not save' do
				click_button 'Create'
				subject.should have_selector('h1', text: 'Create New Set')
				subject.should have_selector("span[class='error']", text: 'invalid parameters')
			end
		end
	end

	# USING RACK::TEST
	# now we can test whether or not the session is modified with the form
	describe 'Create method', type: :feature do
		let(:session) { last_request.env['rack.session'] }
		context 'with valid parameters' do
			before do
				post '/sets/new', { name: 'fizzbuzz', vidnums: 'one, two, three' }, { 'rack.session' => { sets: { } } }
			end
			it 'should update the session' do
				get '/sets'
				expect(session[:sets]).to eq({ "fizzbuzz" => { name: 'fizzbuzz', vidnums: ['one', 'two', 'three'] } })
			end
		end

		context 'with invalid name' do
			before do
				post '/sets/new', { name: '', vidnums: 'one, two, three' }, { 'rack.session' => { sets: { } } }
			end
			it 'should not update the session' do
				get '/sets'
				expect(session[:sets]).to eq({ })
			end
		end

		context 'with invalid vidnums' do
			before do
				post '/sets/new', { name: 'fizzbuzz', vidnums: '' }, { 'rack.session' => { sets: { } } }
			end
			it 'should not update the session' do
				get '/sets'
				expect(session[:sets]).to eq({ })
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
			it_behaves_like 'new page'
		end
	end

	# USING RACK::TEST
	# we can only test the existence of the edit page for an existing set; however, since we can't access the session using Capybara, we can't run through the edit set form since there will be no existing sets
	describe 'Edit set page', type: :feature do
		let(:session) { last_request.env['rack.session'] }
		context 'with existing set' do
			before do
				define_set_in_session('pants')
				get '/sets/pants/edit'
			end

			it_behaves_like 'all pages'
			it { should have_selector('h1', text: 'Edit pants') }
			it { should have_selector("input[value='pants']") }
			it { should have_selector("input[value='a, b, c']") }

			describe 'with valid information' do
				describe 'with same name' do
					before { put '/sets/pants', { name: 'pants', vidnums: 'one, two, three' } }
					it 'should update the session' do
						expect(session[:sets]).to eq({ "pants" => { name: 'pants', vidnums: ['one', 'two', 'three'] } })
					end
					it 'should show the new information' do
						subject.should have_selector('h1', text: 'pants')
						subject.should have_link('Edit', href: '/sets/pants/edit')
						subject.should have_selector('td', text: '["one", "two", "three"]')
					end
				end

				describe 'with different name' do
					before { put '/sets/pants', { name: 'fizzbuzz', vidnums: 'one, two, three' } }
					it 'should update the session' do
						expect(session[:sets]).to eq({ "fizzbuzz" => { name: 'fizzbuzz', vidnums: ['one', 'two', 'three'] } })
					end
					it 'should show the new information' do
						subject.should have_selector('h1', text: 'fizzbuzz')
						subject.should have_selector('td', text: '["one", "two", "three"]')
					end
				end
			end
			describe 'with invalid information' do
				describe 'with invalid name' do
					before { put '/sets/pants', { name: '', vidnums: 'one, two, three' } }
					it 'should not update the session' do
						expect(session[:sets]).to eq({ "pants" => { name: 'pants', vidnums: ['a', 'b', 'c'] } })
					end
					it 'should show the old information with error' do
						subject.should have_selector('h1', text: 'Edit pants')
						subject.should have_selector("span[class='error']", text: 'invalid parameters')
						subject.should have_selector("input[value='pants']")
						subject.should have_selector("input[value='a, b, c']")
					end

					describe 'with invalid vidnums' do
						before { put '/sets/pants', { name: 'pants', vidnums: '' } }
						it 'should not update the session' do
							expect(session[:sets]).to eq({ "pants" => { name: 'pants', vidnums: ['a', 'b', 'c'] } })
						end
						it 'should show the old information with error' do
							subject.should have_selector('h1', text: 'Edit pants')
							subject.should have_selector("span[class='error']", text: 'invalid parameters')
							subject.should have_selector("input[value='pants']")
							subject.should have_selector("input[value='a, b, c']")
						end
					end
				end
			end
		end

		context 'without existing set' do
			before { put '/sets/pants' }
			it_behaves_like 'all pages'
			it_behaves_like 'new page'
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

	# test the delete page
	describe 'Delete page', type: :feature do
		context 'with existing set' do
			before do
				define_sets_in_session('fizzbuzz', 'pants')
				get '/sets/pants/delete'
			end
			it_behaves_like 'all pages'
			it 'displays the delete page' do
				subject.should have_selector('h1', 'Delete pants')
				subject.should have_selector("input[value='Delete']")
			end
		end

		context 'without existing sets' do
			before do
				define_set_in_session('fizzbuzz')
				get '/sets/pants/delete'
			end
			it_behaves_like 'all pages'
			it 'displays the sets index with error' do
				subject.should have_selector("span[class='error']", text: 'invalid set')
				subject.should have_selector('h1', text: 'Sets')
				subject.should have_content('fizzbuzz')
			end
		end
	end

	# test the #destroy action
	describe 'Destroy method', type: :feature do
		let(:session) { last_request.env['rack.session'] }
		context 'with existing set' do
			before do
				define_sets_in_session('fizzbuzz', 'pants')
				delete '/sets/pants'
			end
			it 'modifies the session' do
				expect(session[:sets]).to eq({ "fizzbuzz" => { name: 'fizzbuzz', vidnums: ['a', 'b', 'c'] } })
			end
			it_behaves_like 'all pages'
			it 'displays the sets index' do
				subject.should have_selector('h1', text: 'Sets')
				subject.should have_content('fizzbuzz')
				subject.should_not have_content('pants')
			end
		end

		context 'without existing sets' do
			before do
				define_set_in_session('fizzbuzz')
				delete '/sets/pants'
			end
			it_behaves_like 'all pages'
			it 'displays the sets index with error' do
				subject.should have_selector("span[class='error']", text: 'invalid set')
				subject.should have_selector('h1', text: 'Sets')
				subject.should have_content('fizzbuzz')
			end
		end
	end
end

# helpers

# create a set in the Rack::Test MockSession
def define_set_in_session(name, vidnums=['a','b','c'])
	get '/', {}, { 'rack.session' => { "sets" => { "#{name}" => { :name => "#{name}", :vidnums => ["#{vidnums[0]}", "#{vidnums[1]}", "#{vidnums[2]}"] } } } }
end

# create two sets in the Rack::Test MockSession
def define_sets_in_session(name1, name2)
	get '/', {}, { 'rack.session' => { "sets" => { "#{name1}" => { :name => "#{name1}", :vidnums => ["a", "b", "c"] }, "#{name2}" => { :name => "#{name2}", :vidnums => ["a", "b", "c"] } } } }
end