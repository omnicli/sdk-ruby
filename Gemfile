# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in omnicli.gemspec
gemspec

# Add development dependencies
group :development, :test do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.0"
end

group :development, :test, :rubocop do
  gem "rubocop", "~> 1.60"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 2.25"
end
