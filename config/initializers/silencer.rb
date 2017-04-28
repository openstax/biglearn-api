require 'silencer/logger'

NOISY_POST_ACTIONS = [
  '/fetch_ecosystem_metadatas',
  '/fetch_ecosystem_events',
  '/fetch_course_metadatas',
  '/fetch_course_events'
]

Rails.application.configure do
  config.middleware.swap Rails::Rack::Logger, Silencer::Logger, post: NOISY_POST_ACTIONS
end
