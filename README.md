# omnicli (sdk-ruby)

Ruby SDK for building Omni commands.

## Overview

`omnicli` is a Ruby gem that provides functionality to help build commands that will be executed by Omni. It offers various utilities and helpers that make it easier to work with Omni's features from within Ruby.

## Installation

```bash
gem install omnicli
```

Or add this line to your application's Gemfile:

```ruby
gem 'omnicli'
```

And then execute:
```bash
bundle install
```

## Features

### Argument Parsing

The SDK can read omni-parsed arguments from environment variables into a familiar Ruby Hash format:

```ruby
require 'omnicli'

begin
  args = OmniCli.parse!
  # Access your command's arguments as hash keys
  if args[:verbose]
    puts "Verbose mode enabled"
  end
  if args[:input_file]
    puts "Processing file: #{args[:input_file]}"
  end
rescue OmniCli::ArgListMissingError
  puts "No Omni CLI arguments found. Make sure 'argparser: true' is set for your command."
end
```

The arguments are returned as a Hash with symbol keys, with their values in the expected types (strings, integers, floats, booleans or arrays of these types).

### Integration with omni

The argument parser of omni needs to be enabled for your command. This can be done as part of the [metadata](https://omnicli.dev/reference/custom-commands/path/metadata-headers) of your command, which can either be provided as a separate file:

```
your-repo
└── commands
    ├── your-command.rb
    └── your-command.metadata.yaml
```

```yaml
# your-command.metadata.yaml
argparser: true
```

Or as part of your Ruby command headers:

```ruby
# your-command.rb
#
# argparser: true
require 'omnicli'
...
```

## Requirements

- Ruby 2.6 or higher
- No additional dependencies required

## Development

After checking out the repo, run:

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec
```

For local development, you can also run:
```bash
# Clone the repository
omni clone https://github.com/omnicli/sdk-ruby.git
# Install dependencies
omni up
# Run tests
omni test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/omnicli/sdk-ruby.

## License

The gem is available as open source under the terms of the MIT License.
