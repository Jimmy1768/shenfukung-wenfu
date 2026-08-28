# frozen_string_literal: true

require 'cgi'
require 'socket'

module Notifications
  module Alerts
    class SidekiqFailureHandler
      # Sidekiq::Config#handle_exception (sidekiq/config.rb) detects a
      # 2-arg handler and logs a DEPRECATION warning on every single
      # invocation. The 3-arg form is the supported shape going forward.
      # _sidekiq_config (Sidekiq's own Config object) isn't used here: its
      # most useful field -- which queues a process serves -- only matters
      # once several differently-scoped Sidekiq processes exist, which
      # isn't the case today (one production unit, one staging unit).
      def self.call(exception, context, _sidekiq_config = nil)
        return unless exception

        job = extract_job(context)
        timestamp = Time.current.utc.iso8601
        environment_label = "#{Rails.env} (#{Socket.gethostname})"

        if job
          log_and_alert_job_failure(exception:, job:, timestamp:, environment_label:)
        else
          log_and_alert_infra_error(exception:, context:, timestamp:, environment_label:)
        end
      rescue => e
        Rails.logger.error "[Notifications::Alerts::SidekiqFailureHandler] error: #{e.class}: #{e.message}"
      end

      # A real job failure calls handle_exception with
      # {context: "Job raised exception", job: job_hash} (or similar) --
      # the job's real class/args/jid/queue/retry_count live nested one
      # level down, at context[:job]. An internal error with no job in
      # flight (e.g. a Redis-unreachable fetch-loop failure) calls
      # handle_exception(ex) with no context argument at all, defaulting
      # to {}: there is truthfully no job there. The previous version of
      # this handler read job_class/args off the top-level context hash,
      # a key that is never present in either case, so it always reported
      # 'unknown'/nil -- for every Sidekiq failure, not only Redis
      # outages.
      def self.extract_job(context)
        return nil unless context

        context[:job] || context['job']
      end

      # context is a literal Ruby hash written at Sidekiq's own call
      # sites ({context: "...", job: job_hash}), so it is symbol-keyed in
      # practice -- but job_hash is Sidekiq's job payload deserialized
      # from JSON, so it is string-keyed. Each accessor below tolerates
      # both anyway: cheap insurance against a future Sidekiq version
      # changing either convention, not evidence that either currently
      # varies.
      def self.job_field(job, key)
        job[key.to_s] || job[key.to_sym]
      end

      def self.context_description(context)
        return nil unless context

        context[:context] || context['context']
      end

      def self.log_and_alert_job_failure(exception:, job:, timestamp:, environment_label:)
        job_class = job_field(job, :class) || 'unknown'
        arguments = job_field(job, :args)
        jid = job_field(job, :jid)
        queue = job_field(job, :queue)
        retry_count = job_field(job, :retry_count)

        Notifications::Logging::EventLogger.log(
          event: 'notifications.sidekiq.failure',
          details: {
            kind: 'job_failure',
            job_class: job_class,
            jid: jid,
            queue: queue,
            retry_count: retry_count,
            exception: exception.class.to_s,
            message: exception.message,
            args: arguments.inspect,
            environment: environment_label,
            timestamp: timestamp
          }
        )

        detail_rows = [
          jid ? "<p>Job ID: #{CGI.escapeHTML(jid.to_s)}</p>" : nil,
          queue ? "<p>Queue: #{CGI.escapeHTML(queue.to_s)}</p>" : nil,
          retry_count ? "<p>Retry count: #{CGI.escapeHTML(retry_count.to_s)}</p>" : nil
        ].compact.join

        AlertSender.call(
          # job_class alone would repeat the original bug's shape at a
          # smaller radius: two different exceptions in the same job
          # class would still share one 5-minute throttle window, so a
          # new failure mode could hide behind an already-alerted one.
          alert_key: "sidekiq_failure:job:#{job_class}:#{exception.class}",
          subject: "[Alert] Sidekiq job failed: #{job_class}",
          body: <<~HTML
            <p>Sidekiq job <strong>#{CGI.escapeHTML(job_class.to_s)}</strong> failed at #{CGI.escapeHTML(timestamp)} (#{CGI.escapeHTML(environment_label)}).</p>
            <p>Exception: #{CGI.escapeHTML(exception.class.to_s)} – #{CGI.escapeHTML(exception.message)}</p>
            <p>Arguments: #{CGI.escapeHTML(arguments.inspect)}</p>
            #{detail_rows}
          HTML
        )
      end

      def self.log_and_alert_infra_error(exception:, context:, timestamp:, environment_label:)
        # context[:context] is Sidekiq's own human-readable description
        # for this failure site (e.g. "Invalid JSON for job", "Exception
        # during Sidekiq lifecycle event"). It's absent for the bare
        # fetch-loop case (handle_exception(ex), no context at all) --
        # the exact shape of the incident that prompted this fix.
        description = context_description(context) || 'no job was being processed'

        Notifications::Logging::EventLogger.log(
          event: 'notifications.sidekiq.failure',
          details: {
            kind: 'infra_error',
            description: description,
            exception: exception.class.to_s,
            message: exception.message,
            environment: environment_label,
            timestamp: timestamp
          }
        )

        AlertSender.call(
          # Keyed on exception class, not collapsed to one shared bucket:
          # a Redis blip and a sustained Redis outage should throttle
          # together (that's the suppression we want), but an unrelated
          # infra failure -- a different exception class entirely --
          # should not be hidden behind it.
          alert_key: "sidekiq_failure:infra:#{exception.class}",
          subject: '[Alert] Sidekiq internal error (no job)',
          body: <<~HTML
            <p>Sidekiq hit an internal error at #{CGI.escapeHTML(timestamp)} (#{CGI.escapeHTML(environment_label)}): #{CGI.escapeHTML(description)}.</p>
            <p>No job was in flight -- nothing was dequeued or lost.</p>
            <p>Exception: #{CGI.escapeHTML(exception.class.to_s)} – #{CGI.escapeHTML(exception.message)}</p>
          HTML
        )
      end

      private_class_method :extract_job, :job_field, :context_description,
        :log_and_alert_job_failure, :log_and_alert_infra_error
    end
  end
end
