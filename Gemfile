source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

## used for input/output payload schema validation
gem 'json-schema'

## database query DSL
gem 'squeel'

## datetime string parsing
gem 'chronic'

## entity-relationship disagram gem
gem 'rails-erd'

## bulk import for ActiveRecord
gem 'activerecord-import'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  ## RSpec test framework
  gem 'rspec-rails'

  ## fixture creation
  gem 'factory_girl_rails', '~> 4.0'

  ## ability to manipulate the passage of time
  gem 'timecop'

  ## lorem ipsum generator
  gem 'faker'
end

group :test do
  ## clean up the database before/after specs
  gem 'database_cleaner'

  ## convenience matchers for specs
  gem 'shoulda-matchers'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # re-run specs when files change
  gem 'spring-commands-rspec'
  gem 'rb-readline' # needed for Guard to work on Ruby's built without readline
  gem 'guard-rspec'

  gem 'thin'
end

group :production do
  # Unicorn production server
  gem 'unicorn'
end

