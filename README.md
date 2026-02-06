# Resol

![https://github.com/umbrellio/resol](https://github.com/umbrellio/resol/actions/workflows/test.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/umbrellio/resol/badge.svg?branch=master)](https://coveralls.io/github/umbrellio/resol?branch=master)
[![Gem Version](https://badge.fury.io/rb/resol.svg)](https://badge.fury.io/rb/resol)

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

`Resol` supports two gems, which provide abstract initialization flow for classes:

1. [smart_initializer](https://github.com/smart-rb/smart_initializer), which was default provider for a very long time.
2. [dry-initializer](https://dry-rb.org/gems/dry-initializer/3.1), additional provider with DSL almost identical to the smart_core's DSL.

There is an _important restriction_ on using different initializers in different services.
Descendants of a parent, into which initializer logic has already been imported, cannot override the provider

You can use both providers for a different services:

```ruby
# Types is a namespace for all types, defined by smart_types.
class FirstService < Resol::Service
  inject_initializer :smartcore_injector

  param :first, Types::String
  param :second, Types::Integer
end

# Types is a namespace for all types, defined by dry-types.
class SecondService < Resol::Service
  inject_initializer :dry_injector

  param :first, Types::Strict::String
  param :second, Types::Strict::Integer
end
```

Both initializers support inheritance. And base features for initialization flow
like default value, arguments accessors visibility level, coercible attributes and so on.

List of all supported initializers you can see at `DependencyContainer` definition.

#### Return a result

**Note** – calling `success!`/`fail!` methods interrupts `call` method execution.

- `success!(value)` – finish with a success value
- `fail!(code, data = nil)` – fail with any error code and optional data

#### Define callbacks

You can define callbacks to be executed before calling the `#call` method.

```ruby
class FindUser < Resol::Service
  param :id

  before_call :set_user

  def call
    if user
      success!(user)
    else
      fail!(:not_found)
    end
  end

  private

  attr_accessor :user

  def set_user
    self.user = User.find(id)
  end
end
```

### Result objects

Methods:

- `success?` — returns `true` for success result and `false` for failure result
- `failure?` — returns `true` for failure result and `false` for success result
- `value!` — unwraps a result object, returns the value for success result, and throws an error for failure result
- `value_or(other_value, &block)` — returns a value for success result or `other_value` for failure result (either calls `block` in case it given)
- `error` — returns `nil` for success result and error object (with code and data) for failure result
- `or(&block)` — calls block for failure result, for success result does nothing
- `either(success_proc, failure_proc)` — for success result calls success_proc with result value in args, for failure result calls failure_proc with error in args.
- `bind` — using with `block` for success result resolve value and pass it to the `block`, used to chain multiple monads. Block can return anything. Failure result ignore block and return `self`.
- `fmap` — like the `bind`, but wraps value returned by block by success monad.

### Error object

In case of failure you can get an error object with error code
and data from `fail!` arguments. This can be done by method `error` on
the result object and the returned object will have corresponding
methods `code` and `data`.

### Configuration

Configuration constant references to `SmartCore::Initializer::Configuration`. You can read
about available configuration options [here](https://github.com/smart-rb/smart_initializer#configuration).

### Plugin System

Resol implements the basic logic of using plugins to extend and change the base service class.
You can write your own plugin and applie it by calling `Resol::Service#plugin(plugin_name)`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests.
If you want to check coverage, then set env variable `COVER` to `true` before running `bin/rspec`:
`COVER=true bin/rspec`.
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
