# Resol

![https://github.com/umbrellio/resol](https://github.com/umbrellio/resol/actions/workflows/main.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/umbrellio/resol/badge.svg?branch=master)](https://coveralls.io/github/umbrellio/resol?branch=master)

Ruby Gem for creating simple service objects and other any object ruby patterns.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resol'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install resol

## Usage

### Sample usage

```ruby
class FindUser < Resol::Service
  param :id

  def call
    user = User.find(id)
    if user
      success!(user)
    else
      fail!(:not_found)
    end
  end
end

# when user exists
FindUser.call(1) # => Resol::Success(<user object>)
FindUser.call!(1) # => <user object>

# when user doesn't exist
FindUser.call(100) # => Resol::Failure(:not_found)
FindUser.call!(100) # => raised FindUser::Failure: :not_found
```

So method `.call` always returns the [result object](#result-objects)
and method `.call!` returns a value or throws an error (in case of `fail!` has been called).

#### Params defining

All incoming params and options can be defined using a [smart_initializer](https://github.com/smart-rb/smart_initializer) gem interface.

#### Return a result

**Note** – calling `success!`/`fail!` methods interrupts `call` method execution.

- `success!(value)` – finish with a success value
- `fail!(code, data = nil)` – fail with any error code and optional data

### Result objects

Methods:

- `success?` – returns `true` for success result and `false` for failure result
- `failure?` – returns `true` for failure result and `false` for success result
- `value!` – unwraps a result object, returns the value for success result, and throws an error for failure result
- `value_or(other_value, &block)` – returns a value for success result or `other_value` for failure result (either calls `block` in case it given)


### Configuration

Configuration constant references to `SmartCore::Initializer::Configuration`. You can read
about available configuration options [here](https://github.com/smart-rb/smart_initializer#configuration).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umbrellio/resol.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Authors

Created by [Aleksei Bespalov](https://github.com/nulldef).

<a href="https://github.com/umbrellio/">
<img style="float: left;" src="https://umbrellio.github.io/Umbrellio/supported_by_umbrellio.svg" alt="Supported by Umbrellio" width="439" height="72">
</a>
