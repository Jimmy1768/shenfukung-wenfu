if defined?(Sidekiq)
  require Rails.root.join("app", "services", "notifications", "alerts", "sidekiq_failure_handler").to_s

  Sidekiq.configure_server do |config|
    # 3-arg form (exception, context, sidekiq_config): Sidekiq::Config#handle_exception
    # detects the arity of the registered proc itself, not of whatever it
    # calls internally -- a 2-arg proc here would still trigger Sidekiq's
    # own deprecation warning even though SidekiqFailureHandler.call
    # accepts a third argument.
    config.error_handlers << proc do |exception, context, sidekiq_config|
      Notifications::Alerts::SidekiqFailureHandler.call(exception, context, sidekiq_config)
    end
  end
end
