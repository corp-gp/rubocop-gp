## About
This gem inspired https://github.com/airbnb/ruby, but reconfigurable cops and no lock versions of `rubocop`, `rubocop-*` 

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'rubocop-gp', github: 'corp-gp/rubocop-gp'
end
```

And then run:

```bash
$ bundle install
```

## Usage

Create a `.rubocop.yml` with the following directives:

```yaml
inherit_gem:
  rubocop-gp:
    - .rubocop.yml
```

Now, run:

```bash
$ bin/bundle exec rubocop
```

You do not need to include rubocop directly in your application's dependences. This gem will include a specific version of `rubocop` and `rubocop-rspec` that is shared across all projects.
