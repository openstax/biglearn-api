OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = Rails.application.config.consider_all_requests_local

  config.app_name = 'Biglearn-API'
  config.contact_name = Rails.application.secrets.exception[:contact_name]

  # Notify devs using sentry-raven
  config.notify_proc = ->(proxy, controller) do
    extra = {
      error_id: proxy.error_id,
      class: proxy.name,
      message: proxy.message,
      first_line_of_backtrace: proxy.first_backtrace_line,
      cause: proxy.cause,
      dns_name: resolve_ip(controller.request.remote_ip)
    }
    extra.merge!(proxy.extras) if proxy.extras.is_a? Hash

    Raven.capture_exception(proxy.exception, extra: extra)
  end
  config.notify_background_proc = ->(proxy) do
    extra = {
      error_id: proxy.error_id,
      class: proxy.name,
      message: proxy.message,
      first_line_of_backtrace: proxy.first_backtrace_line,
      cause: proxy.cause
    }
    extra.merge!(proxy.extras) if proxy.extras.is_a? Hash

    Raven.capture_exception(proxy.exception, extra: extra)
  end
  require 'raven/integrations/rack'
  config.notify_rack_middleware = Raven::Rack
end

# Exceptions in controllers are not automatically reraised in production-like environments
ActionController::Base.use_openstax_exception_rescue
