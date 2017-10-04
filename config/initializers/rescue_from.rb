exception_secrets = Rails.application.secrets.exception
OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = Rails.application.config.consider_all_requests_local

  config.app_name = 'Biglearn-API'
  config.app_env = exception_secrets['environment_name']
  config.contact_name = exception_secrets['contact_name']
  config.sender_address = exception_secrets['sender']
  config.exception_recipients = exception_secrets['recipients']
end

# Exceptions in controllers might be reraised or not depending on the settings above
ActionController::Base.use_openstax_exception_rescue

# URL generation errors are caused by bad routes, for example, and should not be ignored
ExceptionNotifier.ignored_exceptions.delete("ActionController::UrlGenerationError")
