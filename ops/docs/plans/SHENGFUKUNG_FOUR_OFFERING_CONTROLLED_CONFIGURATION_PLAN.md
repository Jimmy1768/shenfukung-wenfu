# Shengfukung Four-Offering Controlled Configuration Plan

Status: accepted for implementation

Accepted: 2026-08-13

Owner: Wenfu Planning

## Exact Base

- Canonical repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`
- Branch: `main`
- Accepted base: `e9e02c9d4802e0c2380c2314f09ce0040d30aed9`
- Governing roadmap:
  `ops/docs/plans/SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`

The accepted Phase 1 qualifying-registration accounting and Phase 2 tenant-
scoped patron-provider boundary are both ancestors of this base.

## Objective

Make the loader-ready Shengfukung offering configuration contain exactly the
four Planning-approved test-temple offerings, each at exactly TWD 50, while
ensuring neither speculative half of the ambiguous fifth worksheet row can be
created from source configuration or used as Phase 4 evidence.

## Exact Operational Catalog

The loader-ready `services:` list must contain exactly these slugs and retain
their existing accepted forms and labels:

1. `incense-donation` — 香油捐獻
2. `lamp-service` — 點燈作業
3. `ghost-festival-table` — 普渡供桌
4. `liberation-ritual` — 拔薦

Every entry must use currency `TWD` and persisted `price_cents: 5000`.
`Currency::Symbols` is authoritative here: TWD is a zero-decimal display
currency, while persisted monetary values remain minor units, so `5000`
renders and transacts as exactly `NT$50`.

## Ambiguous Fifth Row

The source worksheet's fifth row remains the Planning marker:
**DISABLED — awaiting an updated temple DOCX**.

The existing inferred templates:

- `peace-opera-household`; and
- `ritual-bucket-ceremony`

must be absent from the loader-ready Shengfukung YAML. They must not be priced,
created, seeded, activated, presented, registered, or included in Phase 4
evidence. Do not add a schema column, runtime flag, YAML `disabled` property,
or general loader feature. Existing Git history, intake material, working
drafts, and historical plans remain unchanged evidence and must not be
rewritten to imply temple approval.

If a database already contains records with either inferred slug, this packet
does not delete, publish, update, or otherwise mutate them. Template parity may
truthfully classify them as orphaned. Production reconciliation of an existing
row would require separate target-specific authority.

## Authorized Work

Control owns a bounded local implementation packet and one ephemeral
Implementer. It may change only:

- `rails/db/temples/offerings/shengfukung-wenfu.yml`;
- focused offering template/parity/config tests under `rails/test/services/offerings/`;
- a narrowly necessary local test helper under the same offering-test boundary;
- the Control handoff record.

The implementation may:

1. remove the two inferred ambiguous entries from the loader-ready YAML;
2. set all four accepted entries to `price_cents: 5000`, `currency: TWD`;
3. preserve their existing form, repeat-registration, period, and metadata
   contracts unless a purely mechanical YAML correction is required;
4. update stale tests that currently treat an inferred entry as accepted; and
5. add deterministic proof that a fresh template-parity application creates
   exactly the four accepted draft services with exact TWD 50 authority.

## Required Evidence

1. Parse the final YAML and prove the service slug set equals the four-item
   list exactly, with no duplicate slug and no event entry.
2. Prove each template has `currency: TWD` and `price_cents: 5000` and renders
   as `NT$50` through the repository's currency formatter.
3. In an explicitly guarded disposable Rails test database, run template
   parity against a fresh Shengfukung tenant and prove it creates exactly four
   draft services, with no inferred ambiguous service.
4. Prove a pre-existing inferred service is reported as orphaned and is not
   modified or deleted by `ensure_missing!`.
5. Run focused offering/template/bootstrap tests, all tests affected by the
   changed YAML, Ruby/YAML syntax or parsing checks, and `git diff --check`.
6. Run the full Rails suite if the focused matrix reveals shared-fixture or
   catalog coupling; otherwise Control must state why the bounded matrix is
   sufficient.

All database writes must use `RAILS_ENV=test` and an exact packet-owned
disposable database with configured/current-database fencing. Remove the
disposable database and temporary artifacts before acceptance.

## Exclusions

No production or shared-development database mutation; no creation/update of
real temple offerings; no Stripe, ECPay, fake-checkout lifecycle, credential,
provider, network, deployment, timer, release, push, Expo, or Vue action. Do
not edit the original intake, working draft, or historical acceptance records.
Do not begin Phase 4 in this packet.

## Acceptance And Integration

Control must work on an isolated `codex/` branch/worktree from the exact base.
On complete evidence, it may locally integrate the accepted result into clean
canonical `main` and return one immutable terminal packet. Any need to invent
the ambiguous fifth offering, alter a non-price product contract, touch an
existing non-test database, or expand beyond the owned paths is a stop for
Planning.

## Next Step

After Planning accepts the canonical Phase 3 terminal, Planning commits and
dispatches the separate Phase 4 simulated-ECPay registration QA plan. Phase 5
Stripe sandbox and live ECPay remain deferred and unauthorized.
