# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

## override the output formatter setting in .rspec
task :spec do
  ENV['SPEC_OPTS'] ||= '--format progress'
end

Rails.application.load_tasks
