# LSE Courses

A gem for accessing course data from the [London School of Economics](http://lse.ac.uk)'s [Calendar](http://www.lse.ac.uk/resources/calendar/).

I'm planning to use this for a project, but I'm not 100% sure what yet - perhaps
something along the line of [YalePlus](http://yaleplus.com/)'s Bluebook+.

## Usage

Add the gem to your Gemfile, then run `bundle install`:

```ruby
# Install from RubyGems
source "http://rubygems.org"
gem 'lse_courses', '0.0.3'

# Install the latest version via Git
gem 'lse_courses', git: 'git@github.com:timrogers/lse_courses.git'
```

You might need to add a call to `require 'lse_courses'` in your code, 
dependent on your setup.

You can retrieve an array with every course offered at LSE:

```ruby
# You can just fetch the most basic information - name, code and type (e.g. undergraduate)
courses = LSECourses::Course.all

# ...or you can grab everything at once - this will take a long time
courses = LSECourses::Course.all(preload: true)

courses.each do |course|
  puts "#{course.code} - #{course.name}"

  # Fetch a more detailed attribute, and we'll grab all of them for you
  # and store them if you didn't preload the data originally
  puts course.department

  # LSE records include surveys on courses - stored in #survey on the object
  puts "#{course.survey.recommended_by}% of students recommend this cause"
end
```

...or you can fetch a specific course by code:

```ruby
course = LSECourses::Course.find("LSE100")
puts course.name

# All the data is loaded straight up, since there's only one course to fetch
puts course.department
```

Upcoming features that should be added are some kind of search (e.g. for
finding a course by name) and a way to find courses by type (e.g. undergraduate, graduate)...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

