# Configurizer

Easily add a configuration component to your ruby gem or application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configurizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configurizer

## Usage

I like to create my configuration object in my project's base module:

```ruby
require "configurizer"

module MyProject
  # Include Configurizer in your base module
  include Configurizer

  # Set the configuration filename (don't include a path)
  self.config_filename = '.myproject'

  # Prevent specific config variables from being saved:
  self.do_not_save "calc_var1", "calc_var2"

  # Open Configurizer::Configuration class and add member
  # variables, methods, etc.
  class Configurizer::Configuration
    attr_accessor :value_a
    attr_accessor :value_b
    attr_accessor :calc_var1
    attr_accessor :calc_var2

    attr_reader :some_other_val
    attr_writer :verbose

    def some_other_val= some_val
      @some_other_val = some_val if some_val > 100
    end

    def verbose
      @verbose ||= false
    end

    # Nested config class
    class SomeObj
      attr_accessor :important_val
    end

    def auto_create_var
      @auto_create ||= SomeObj.new
    end
  end
end

# Call configure to force creation of the configuration object.
MyProject.configure
```

Now your configuration is available from elsewhere in your project.

```ruby
module MyProject
  class MyClass

    def initialize
      @verbose = MyProject.configuration.verbose
    end

    def configure_stuff
      puts "I'm configurizing" if @verbose

      # You can set configuration using block syntax:
      MyProject.configure do |config|
        config.value_b = "Hello!"
        config.some_other_val = 101
      end
    end
  end
end
```

Be sure to save your configuration when finished.

```ruby
# Save configuration to current working dir
MyProject.save_configuration

# or save configuration to specific dir
MyProject.save_configuration ENV["HOME"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jmcaffee/configurizer.

1. Fork it ( https://github.com/jmcaffee/configurizer/fork )
1. Clone it (`git clone git@github.com:[my-github-username]/configurizer.git`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create tests for your feature branch (pull requests not accepted without tests)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

