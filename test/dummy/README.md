A dummy app with apipie definition allows:

1. easier adding of more complex cases of documentation (no need
   to craft the json document manually: just change the dummy app
   and regenerate the json

1. easier hanlding of next versions of apipie-rails: every change in the json
   API can be handled easier and issues spotted sooner as well

1. easier integration testing: the dummy app is responding almost real data
   that the bindings can be run against to see the results.

To regenerate the `dummy.json`, from the apipie-bindings root dir, just
delete the test/unit/data/dummy.json and it will be generated again on
next rake test or explicitly with `rake test/unit/data/dummy.json`

The dummy app can be used also for testing against real Rails app,
as it serves some dummy data (that can be customized by editing the
`data` folder:

1. bundle install
1. bundle exec rails s
1. `curl http://localhost:3000/users`

   `curl http://localhost:3000/users/1`

   `curl http://localhost:3000/users/1/posts`

   `curl http://localhost:3000/users/1/posts/1`

   `curl http://localhost:3000/users/1/posts/1/comments`

   `curl http://localhost:3000/users/1/posts/1/comments/1`
