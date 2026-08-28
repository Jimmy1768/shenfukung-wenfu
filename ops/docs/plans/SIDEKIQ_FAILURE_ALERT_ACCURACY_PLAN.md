# Sidekiq Failure Alert Accuracy — First Draft Plan

Status: Planning-owned first draft only. Not yet implemented. Written for
OperatorKit Recovery review before any code change. This document grants no
implementation, deployment, or migration authority by itself.

Recorded against `main` at `b4e7bc7` on 2026-08-26 (droplet clock; see
`shengfukung_wenfu_config.yml`).

## Trigger

Production emailed the Director this alert on 2026-08-26 06:15:16Z:

> Sidekiq job unknown failed at 2026-08-26T06:15:16Z.
> Exception: RedisClient::CannotConnectError – Connection refused -
> connect(2) for 127.0.0.1:6379 (redis://localhost:6379)
> Arguments: nil

Live-log investigation (`journalctl`) showed the underlying event was benign
and self-recovered: production and staging Sidekiq were both mid-restart at
the exact moment `redis-server` itself restarted, so a 2-second job-fetch
poll hit "connection refused" before Redis finished coming back up. No job
was lost -- nothing was ever dequeued. Zero recurrences since. That part is
not in question and needs no code change.

What the Director flagged instead: `job unknown` / `Arguments: nil` is not
informative. This document is about making the alert itself truthful and
useful, not about the Aug 26 incident.

## Root cause, read directly from the code

`app/services/notifications/alerts/sidekiq_failure_handler.rb`, registered
via `config/initializers/sidekiq_notification_alerts.rb`:

```ruby
job_class = context['class'] || context[:class] || 'unknown'
arguments = context['args'] || context[:args]
```

Checked against the actual Sidekiq 7.3.9 call sites
(`sidekiq/processor.rb`, `sidekiq/config.rb`) that invoke error handlers:

- A real job failure calls
  `handle_exception(e, {context: "Job raised exception", job: job_hash})`
  -- the job's real class/args/jid/queue/retry_count live **nested one level
  down**, at `context[:job]["class"]`, `context[:job]["args"]`, etc. (string
  keys, since `job_hash` is Sidekiq's JSON-derived job payload).
- An internal error with no job in flight -- exactly the fetch-loop failure
  in the Aug 26 incident -- calls `handle_exception(ex)` with **no context
  argument at all**, defaulting to `{}`. There is no job here, truthfully,
  because nothing was ever fetched.

The handler reads `context['class']` / `context[:class']` -- keys that are
**never present at that top level in either case**. This is not narrowly a
"Redis outage" bug: **`job_class` is `'unknown'` and `arguments` is `nil`
for every Sidekiq failure this handler has ever reported**, including a real
job crashing with a real class and real arguments. The Aug 26 incident is
just the one that happened to make this visible, because "unknown" is at
least arguably defensible when there truly is no job -- it is actively
false for a real job failure.

### Two further consequences of the same bug, not just noise

1. **Alert throttling is broken across job types.** `AlertThrottler` keys
   its 5-minute suppression window on `alert_key: "sidekiq_failure:#{job_class}"`
   (`app/services/notifications/alerts/sidekiq_failure_handler.rb:29`). Since
   `job_class` is always `'unknown'`, every Sidekiq failure -- regardless of
   which job, or whether it's even a job at all -- shares one throttle
   bucket. A `PlatformBillingLifecycleJob` failure can silently suppress a
   `SidekiqFatalFailure`-style alert for an unrelated job five minutes
   later. This is a real risk to noticing unrelated incidents, not cosmetic.
2. **The handler is registered in Sidekiq's deprecated 2-argument form.**
   `Sidekiq::Config#handle_exception` (`sidekiq/config.rb:296-299`) detects a
   2-arg handler and logs `DEPRECATION: Sidekiq exception handlers now take
   three arguments` on every single invocation -- visible in the exact
   journal excerpt that surfaced this incident. Confirmed via
   `gem contents`: Sidekiq 7.3.9 still supports the 2-arg form but flags it;
   worth clearing before a future major version removes it outright.

### No existing test coverage

`grep`/`find` across `test/` found zero tests for
`Notifications::Alerts::SidekiqFailureHandler`, `AlertSender`, or
`AlertThrottler`. Nothing would have caught this extraction bug.

## Proposed fix (first draft -- this is the part asking for review)

1. **Extract from the correct shape.** Read `context[:job]` (tolerate both
   symbol and string keys defensively, since job hashes come from Sidekiq
   internals as string-keyed but the wrapping `context` hash is
   symbol-keyed at the call sites above). When present, pull real
   `class`/`args`/`jid`/`queue`/`retry_count`.
2. **Tell the truth when there is no job.** When `context[:job]` is absent,
   do not say a job named `unknown` failed. Report it as what it is: a
   Sidekiq-internal error with no job in flight, using Sidekiq's own
   `context[:context]` description string when present (e.g. `"Invalid
   JSON for job"`, `"Exception during Sidekiq lifecycle event"`) and a
   plain fallback (e.g. `"Sidekiq internal error (no job was being
   processed)"`) for the zero-context case the Aug 26 incident hit.
3. **Fix the throttle key** to use the real job class when known, and a
   distinct bucket for infra-level errors (e.g. keyed by exception class
   instead of the literal string `unknown`) so unrelated failures stop
   sharing suppression state.
4. **Migrate to the 3-argument handler form**
   (`|exception, context, sidekiq_config|`) to clear the deprecation
   warning already visible in production's own logs.
5. **Put environment/host in the alert body itself.** Today, production
   and staging alerts are disambiguated only by which inbox they land in
   (`AlertSender.target_email` branches on `Rails.env.production?`,
   `app/services/notifications/alerts/alert_sender.rb:27-33`) -- the email
   content itself says nothing about which environment sent it. Worth
   adding explicitly so the alert is self-sufficient truth, not
   inbox-routing-dependent truth.
6. **Add test coverage** for both the real-job-failure extraction path and
   the no-job infra-error path, since neither exists today.

### Worked example against the actual Aug 26 event

With this fix, the exact same incident (`handle_exception(ex)`, zero
context, `RedisClient::CannotConnectError`) would read something like:

> Sidekiq could not reach Redis while polling for jobs, at
> 2026-08-26T06:15:16Z (production, taiwan-01-web).
> No job was in flight -- nothing was dequeued or lost.
> Exception: RedisClient::CannotConnectError – Connection refused -
> connect(2) for 127.0.0.1:6379 (redis://localhost:6379)

Truthful, specific, and doesn't invent a job name that doesn't exist.

## Explicitly out of scope for this patch

- The Aug 26 Redis/Sidekiq restart coincidence itself, or root-causing why
  `redis-server` restarted at that exact moment (needs root-level
  `/var/log/apt/history.log` / `/var/log/unattended-upgrades/` access this
  session doesn't have; a separate, optional follow-up if the Director
  wants it pursued).
- Redis or Sidekiq reliability/HA changes.
- Where alerts are routed (`AppConstants::Emails.ops_alert_email` /
  `dev_app_notification_email`) or who receives them.
- `AlertThrottler`'s cache-store choice (`Rails.cache`, itself possibly
  Redis-backed per `config/environments/production.rb:21-28` -- worth
  Recovery independently confirming whether `REDIS_CACHE_URL` /
  `REDIS_APPSTATE_URL` is actually set for this droplet, since that
  determines whether the throttle cache is vulnerable to the same class of
  outage this whole alert is about).

## Open questions for OperatorKit Recovery

1. Does the proposed no-job wording read as truthful and calm, not
   alarming, matching the same plain-language standard applied to
   patron-facing copy elsewhere in this repo recently?
2. Is keying the infra-level throttle bucket by exception class the right
   granularity, or should some infra errors (e.g. this exact
   `RedisClient::CannotConnectError`) get their own dedicated key instead
   of sharing one generic "infra" bucket?
3. Any reason not visible from this repo alone that the throttle key was
   originally left collapsed to `unknown` -- i.e., is per-job-class
   throttling intentionally undesired for some operational reason this
   plan hasn't considered?
4. Anything about the 3-argument handler migration (`sidekiq_config` as the
   third argument) worth using beyond clearing the deprecation warning --
   e.g. reading concurrency/queue state for the alert body?

## Current classification and next action

Classification: `sidekiq_failure_alert_accuracy_plan_draft`.

No implementation yet. Sent to OperatorKit Recovery for review; the
Director is waiting on that return before any code change proceeds.
