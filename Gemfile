source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Use PostgreSQL as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'

# Run unicorn when using the `rails server` or `rails s` command
gem 'unicorn-rails'

# Prevent server memory from growing until OOM
gem 'unicorn-worker-killer'

# Used for input/output payload schema validation
gem 'json-schema'

# ActiveRecord import method (upsert)
gem 'activerecord-import'

# Entity-relationship diagram gem
gem 'rails-erd'

# Faster JSON serialization
gem 'oj'
gem 'oj_mimic_json'

# Silence logs for certain actions
gem 'silencer'

# Notify developers of Exceptions in production
gem 'openstax_rescue_from'

# Sentry integration (the require disables automatic Rails integration since we use rescue_from)
gem 'sentry-raven', require: 'raven/base'

# Real time application monitoring
gem 'scout_apm'

# Respond to ELB healthchecks in /ping and /ping/
gem 'openstax_healthcheck'

# Manage SQL functions
gem 'fx'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # RSpec test framework
  gem 'rspec-rails'

  # Fixture creation
  gem 'factory_bot_rails'

  # Lorem Ipsum generator
  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'

  # Re-run specs when files change
  gem 'spring-commands-rspec'
  # Needed for Guard to work on Ruby's built without readline
  gem 'rb-readline'
  gem 'guard-rspec'
end

group :test do
  # Clean up the database before/after specs
  gem 'database_cleaner'

  # Convenience matchers for specs
  gem 'shoulda-matchers'
end

group :production do
  gem 'aws-ses', require: 'aws/ses'
end
