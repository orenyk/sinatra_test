### sinatra_test ###

Example [Sinatra](http://www.sinatrarb.com/) app with [RSpec](http://rspec.info/) and [Capybara](http://jnicklas.github.io/capybara/) used for testing.  Based on the Yale STC Intro to Web Development course (route specifications [here](https://github.com/yale-stc-developer-curriculum/Yalies-On-Rails-2014-Spring/wiki/RESTful-Routes)).

These tests makes the following assumptions about the app's structure:
* the app is built in the [classic style](http://www.sinatrarb.com/intro.html#Modular%20vs.%20Classic%20Style)
* the application includes navigation links on every page
  * 'Home' => `/`
  * 'Sets' => `/sets`
* the application stores sets inside a session hash item of the following form: `"sets" => { <SETNAME>: { name: <SETNAME>, vidnums: [<VIDNUM1>, <VIDNUM2>] } }`
  * in other words, the `sets` hash uses each set name as the key to the hash with information for each set
  * this hash stores the set name under the `name` key and an array of video numbers under the `vidnums` key
* the application displays error messages inside a `span` element with the class `error`
  * for invalid parameters within #create or #update requests, the error message is 'invalid parameters'
  * for GET requests to links with invalid set paths the error message is 'invalid set'
* the application doesn't implement actual redirects; however, for requests with invalid set names we expect the following behavior
  * for GET requests to 'sets/<NAME>' or 'sets/<NAME>/edit', or PUT requests to 'sets/<NAME>', we expect the page to show the new page form with the invalid name filled in
  * for GET requests to 'sets/<NAME>/delete' or DELETE requests to 'sets/<NAME>', we expect the page to show the sets index page

Please submit any questions or bug reports as [issues](https://github.com/orenyk/sinatra_test/issues/new) under this repository.  Thanks!