# TempleMate Phase 3 UI Audit Findings

Status: closed for V1; historical findings retained

Opened: 2026-08-14

Owner: Director / Wenfu Planning

Runtime session authority:
`ops/docs/plans/TEMPLEMATE_PHASE_3_UI_AUDIT_RUNTIME_SESSION_PLAN.md`

Parent audit:
`ops/docs/plans/TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md`

Accepted runtime baseline: canonical `main` at session dispatch
`032634234030944800c94e5792ae19abbfc64f01`

This is a rolling Director-owned findings record. Observations here are review
evidence, not source-edit authority. The original observations below remain
unchanged; the V1 closeout records their accepted disposition.

## V1 Closeout

The Director review is complete and the resulting bound TempleMate UI is
sufficient for V1. Finding 001 maps to the accepted tenant gate, Settings
switch placement, and device evidence. Finding 002 maps to the accepted
Assistance/Contact presentation and retained destination distinction. Finding
003 maps to the accepted native-form contract implementation and evidence.

The later accepted Header utility repair keeps Settings beside Sign out, while
the five business destinations form one non-wrapping horizontal line. The
compact-height repair restored natural navigation height and centered pills;
its bound runtime confirmation was accepted at
`1b1cb69e74dad282793fb4ccdfe196dc48dbda76`. Noncritical observations remain
historical future evidence rather than a newly inferred source defect.

## Finding 001 — Temple binding hierarchy and unbound gate

- Screen/state: authenticated Home; bound and unbound temple states; currently
  observed in Traditional Chinese on the Android development client.
- Severity: high.
- Scope: global navigation/onboarding decision with Home and Settings
  presentation consequences.
- Observed problem:
  - When a temple is already bound, `Switch temple` is displayed prominently on
    Home even though changing the tenant should be rare and deliberate.
  - When no temple is bound, the normal account navigation remains available
    even though the temple-scoped product has no meaningful working context.
- Director direction:
  - Move ordinary temple switching off Home and place it low in Settings as the
    least prominent action.
  - In the unbound state, invert the hierarchy: temple QR binding becomes the
    dominant gate and the only meaningful product action, apart from safe
    escape such as sign-out.
  - Use clear onboarding copy such as “Scan your temple QR code to finish
    setup”; authentication and temple binding must not be presented as the
    same security event.
- Intended outcome: a bound patron sees their temple as stable context rather
  than a frequent switch control. An unbound patron cannot wander through
  empty or misleading temple-scoped screens and is directed immediately to
  TempleMate's in-app QR scanner.
- Explicit non-goals: do not weaken switch confirmation/cleanup, tenant
  isolation, QR trust validation, or the in-app CameraView-only rule. Do not
  expose the fixture connection-link input in a production-facing treatment.

## Finding 002 — Settings support actions are indistinguishable

- Screen/state: Settings, Assistance, and Contact Temple; both locales/themes
  still require later visual review.
- Severity: high.
- Scope: shared information architecture and copy, with distinct backend
  semantics.
- Observed problem: `Need help` and `Contact temple` appear as peer buttons
  without explaining their different destinations or expected response path.
  They look like placeholder/fake options in the current development client.
- Verified Rails distinction:
  - Assistance is a retained `TempleAssistanceRequest`. It is tenant-scoped,
    appears in the temple admin dashboard and assistance-request queue, supports
    registration/profile context, has open/closed state, and can be closed by
    an authorized admin.
  - Contact Temple sends an email to the configured temple recipient through
    Brevo and sends an acknowledgement email to the patron. It writes an audit
    event, but it does **not** create an admin-webapp message or inbox record.
  - In explicit dummy mode, both actions are fixture-only local state and send
    nothing to Rails, administrators, or email.
- Intended outcome/open Director decision: either keep both with explicit
  labels and short destination descriptions (admin assistance queue versus
  temple email), or consolidate/remove one. Do not leave two unexplained
  generic message forms.
- Explicit non-goals: do not claim that Contact Temple creates a system
  message, and do not silently convert email delivery into retained admin work
  without a separately accepted product decision.

## Finding 003 — Expo support forms do not satisfy the Rails native contracts

- Screen/state: Assistance and Contact Temple in real adapter mode.
- Severity: high functional defect.
- Scope: Expo form/payload contract and focused Rails/native integration
  evidence; not a native rebuild concern.
- Verified mechanism:
  - Expo Assistance sends only `message`. Rails requires a valid assistance
    `channel` (`profile`, `registration_list`, or `registration_detail`) before
    it can persist the admin-visible request.
  - Expo Contact Temple renders only a message input and sends only `message`.
    Rails requires a nonempty subject and a message of 10–2,000 characters.
  - Existing real-adapter tests invoke structurally valid payloads directly and
    therefore do not prove that the rendered Expo forms satisfy those
    contracts.
  - Dummy-mode success proves only local fixture behavior.
- Intended outcome: once Finding 002's product direction is accepted, each
  retained action must render the necessary fields/context, validate them
  consistently, submit the correct native payload, and prove its actual
  destination. Error/success copy must not imply delivery when only dummy state
  changed.
- Explicit non-goals: no provider, email credential, deployment, production
  message, or admin-data mutation is authorized by this audit finding.

## Historical Audit Boundary

The Phase 3 Director gate is closed for V1. These retained findings do not
authorize a further source edit; future work requires its own accepted plan.
