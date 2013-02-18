[cu-open-libraries](http://cu-open-libraries.herokuapp.com/)
===========
An app for displaying the currently open libraries on Columbia's Morningside Heights campus. The app scrapes and parses the Columbia library hours pages nightly at midnight using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) and stores the day's hours in a database at [MongoHQ](http://mongohq.com). The scraper/parser is implemented in ` Rakefile.rb ` and is capable of handling libraries that are closed, open for a defined hour range, or open 24 hours. 
