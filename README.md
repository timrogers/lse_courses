# LSE Courses

A gem for accessing course data from the [London School of Economics](http://lse.ac.uk)'s [Calendar](http://www.lse.ac.uk/resources/calendar/).

I'm planning to use this for a project, but I'm not 100% sure what yet - perhaps
something along the line of [YalePlus](http://yaleplus.com/)'s Bluebook+.

## Usage

Add the gem to your Gemfile, then run `bundle install`:

```
gem 'lse_courses', git: 'git@github.com:timrogers/lse_courses.git'
```

You might need to add a call to `require 'lse_courses'` in your code, 
dependent on your setup.

You can retrieve an array with every course offered at LSE:

```ruby
courses = LSECourses::Course.all
courses.each do |course|
  puts "#{course.code} - #{course.name}"
end
```

...or you can fetch a specific course by code:

```ruby
course = LSECourses::Course.find_by_code("LSE100")
puts course.name
```

Upcoming features that should be added are some kind of search (e.g. for
finding a course by name) and a way to find courses by type (e.g. undergraduate, graduate)...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

