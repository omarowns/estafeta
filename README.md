# Estafeta

This gem is a friendly way to retrieve the tracking information for a package
sent via Estafeta's postal service.
Currently to get the tracking information you have to visit the website and there's
no official way to get this through a webservice or API and integrate into your own
solution, thus this gem will do the heavy lifting for you.
This works by fetching the webpage through their 'endpoint' and search within
the page for the parts we are interested in.
Sounds complicated? It isn't really.
Sounds like if they change their layout this gem will break? Of course, that's why
we have tests and if it happens I will adapt the gem immediately.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'estafeta'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install estafeta

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/omarowns/estafeta. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

