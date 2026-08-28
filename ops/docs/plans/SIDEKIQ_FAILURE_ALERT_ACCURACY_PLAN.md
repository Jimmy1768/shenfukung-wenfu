# Sidekiq Failure Alert Accuracy — First Draft Plan

Status: Planning-owned first draft, reviewed by OperatorKit Strategy on
2026-08-26 and revised below to incorporate that review. Not yet
implemented -- awaiting the Director's go-ahead to implement. This document
grants no implementation, deployment, or migration authority by itself.

Reviewer routing note: this draft was originally addressed to "OperatorKit
Recovery." Corrected per Strategy: Recovery is a Fable 5 session the
Director invokes manually by copy-paste, not peer-requestable. Route future
review requests of this kind to OperatorKit Strategy directly.

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

The zero-context case reaches the handler at all (rather than bailing at
`return unless exception && context`) because `handle_exception`'s default
is `ctx = {}`, not `nil` -- an empty hash is truthy, so the guard passes and
the handler runs with nothing to extract. Confirmed against
`sidekiq/config.rb:291`.

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

1. **Extract from the correct shape.** Read `context[:job]`, tolerating
   both symbol and string keys on the outer `context` hash but expecting
   string keys inside `job_hash` specifically -- not defensive
   superstition, but because of where each hash actually comes from: the
   wrapping `context` hash is a literal Ruby hash written at the call
   sites (`{context: "...", job: job_hash}`, symbol keys), while
   `job_hash` itself is Sidekiq's job payload deserialized from JSON
   (string keys). When present, pull real
   `class`/`args`/`jid`/`queue`/`retry_count`.
2. **Tell the truth when there is no job -- in the subject line too, not
   just the body.** When `context[:job]` is absent, do not say a job named
   `unknown` failed, anywhere in the alert. The body should report it as
   what it is: a Sidekiq-internal error with no job in flight, using
   Sidekiq's own `context[:context]` description string when present
   (e.g. `"Invalid JSON for job"`, `"Exception during Sidekiq lifecycle
   event"`) and a plain fallback (e.g. `"Sidekiq internal error (no job
   was being processed)"`) for the zero-context case the Aug 26 incident
   hit. The current subject line
   (`"[Alert] Sidekiq failure #{job_class}"` -> `"[Alert] Sidekiq failure
   unknown"` today) is not addressed by extracting the body correctly --
   it's a separate string built from the same `job_class` variable, and
   it's the first thing an operator reads. For the no-job case it needs
   its own wording too, e.g. `"[Alert] Sidekiq internal error (no job)"`,
   not "failure" attached to a phantom job name.
3. **Fix the throttle key -- but not by repeating the same collapse at a
   smaller scale.** Infra-level errors (no job) should throttle on
   exception class: a Redis blip and a sustained Redis outage sharing one
   bucket is correct, since the goal there is exactly to suppress a flood
   of identical infra noise, not to see every individual reconnect
   attempt. But for real job failures, throttling on `job_class` alone
   repeats the original bug's shape at a smaller radius: two different
   exceptions in the same job class would still share one bucket, so a
   new failure mode in a job silently hides behind an already-alerted one.
   Key job failures on `job_class + exception_class` together.
4. **Migrate to the 3-argument handler form**
   (`|exception, context, sidekiq_config|`) to clear the deprecation
   warning already visible in production's own logs. Low incremental
   value beyond that today (the config object's most useful field is
   which queues a given Sidekiq process serves, which only matters once
   there are multiple differently-scoped Sidekiq processes; today there is
   exactly one production unit and one staging unit) -- worth doing for
   the deprecation alone, not worth building extra alert content around
   yet.
5. **Put environment/host in the alert body itself, sourced from `Rails`
   and the hostname -- not from the handler's 3rd argument.** Today,
   production and staging alerts are disambiguated only by which inbox
   they land in (`AlertSender.target_email` branches on
   `Rails.env.production?`,
   `app/services/notifications/alerts/alert_sender.rb:27-33`) -- the email
   content itself says nothing about which environment sent it.
   `Rails.env` and `Socket.gethostname` (or equivalent) give this directly
   and correctly regardless of the argument-count migration in (4); no
   reason to couple the two.
6. **Add test coverage** for both the real-job-failure extraction path and
   the no-job infra-error path, since neither exists today.

### Worked example against the actual Aug 26 event

With this fix, the exact same incident (`handle_exception(ex)`, zero
context, `RedisClient::CannotConnectError`) would read something like:

> Subject: [Alert] Sidekiq internal error (no job)
>
> Sidekiq could not reach Redis while polling for jobs, at
> 2026-08-26T06:15:16Z (production, taiwan-01-web).
> No job was in flight -- nothing was dequeued or lost.
> Exception: RedisClient::CannotConnectError – Connection refused -
> connect(2) for 127.0.0.1:6379 (redis://localhost:6379)

Truthful, specific, and doesn't invent a job name that doesn't exist --
in the subject an operator sees first, not just the body.

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
  Redis-backed per `config/environments/production.rb:21-28` -- still worth
  independently confirming whether `REDIS_CACHE_URL` / `REDIS_APPSTATE_URL`
  is actually set for this droplet, since that determines whether the
  throttle cache is vulnerable to the same class of outage this whole
  alert is about; not yet checked).

## Review record (OperatorKit Strategy, 2026-08-26)

Diagnosis independently verified against the installed Sidekiq 7.3.9 gem,
line by line, and confirmed exact. Four open questions were asked; answers
below, already folded into the proposal above.

1. **Wording** -- the no-job body sentence ("No job was in flight -- nothing
   was dequeued or lost") was endorsed close to verbatim: it states impact,
   which is what an operator needs, and is what the old alert falsely
   implied the opposite of. But the original draft only fixed the body --
   the subject line is what's read first and wasn't addressed. Fixed above
   (proposal 2).
2. **Throttle granularity** -- exception-class keying for infra errors is
   correct (a blip and an outage sharing a bucket is desirable
   suppression). Job-side keying on `job_class` alone was under-specified:
   it repeats the original collapse at smaller scale, since two different
   exceptions in the same job class would still share a bucket. Fixed
   above (proposal 3): job failures key on `job_class + exception_class`.
3. **Was the `unknown` collapse deliberate?** No. `git log` on
   `alert_throttler.rb` shows exactly one commit, `412b211` ("building
   temple management system v1", a bulk initial commit) -- the key has
   never been anything else. It was written alongside the same extraction
   bug in the handler, so the collapse is a consequence of that bug, not a
   traded-off design decision.
4. **Third handler argument** -- modest value; don't manufacture a use for
   it. Its most useful field (which queues a process serves) matters once
   several differently-scoped Sidekiq processes exist, which isn't the
   case today (one production unit, one staging unit). Environment/host
   for the alert body should come from `Rails`/hostname directly, not
   `sidekiq_config` -- simpler and correct independent of the migration.
   Fixed above (proposals 4-5).

One addition from review not in the original draft: proposal 1's "tolerate
both symbol and string keys" now states *why* (different hashes from
different sources: a literal Ruby hash at the call site vs. a JSON-derived
job payload) rather than reading as unexplained defensiveness that a future
cleanup could remove by mistake.

Reviewer's own summary: "Not authorizing implementation -- that is the
Director's. This is the review they were waiting on."

## Current classification and next action

Classification: `sidekiq_failure_alert_accuracy_plan_reviewed`.

Reviewed and revised. Not yet implemented. Awaiting the Director's decision
on whether to proceed to implementation.
