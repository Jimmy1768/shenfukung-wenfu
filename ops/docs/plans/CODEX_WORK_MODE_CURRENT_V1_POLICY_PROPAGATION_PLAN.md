# Codex Work Mode Current V1 Policy Propagation Plan

Status: Strategy policy propagation accepted for local implementation

Owner: Wenfu Planning

Date: 2026-08-10

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Planning base: `99a0a6929c5cb0eace21d5fa074cdab3950b269c`

Registered cross-repository gate: `codex_work_mode.package.f737dc3.v1`

## Purpose And Boundary

Propagate the current unchanged-v1 Codex Work Mode policy into Wenfu's portable
package and directly required local builder-governance sources. This is a
Strategy-owned policy correction applied locally through ordinary
Planning -> authoritative Control -> one ephemeral Implementer routing. It
does not change Wenfu product/runtime, payment, provider, deployment, secret,
account, tenant, or production authority.

`AGENTS.md` and `agents/openai.yaml` are byte-preservation surfaces. No local
conflict is observed: the existing `AGENTS.md` source map and Wenfu safety
boundaries remain compatible with the current policy. They must not be edited.

## Canonical Package Evidence

Read only committed bytes from OperatorKit commit
`f737dc3ef92f54f31685e5526bece10cb9bb80fc`; the observed OperatorKit main
commit `5fb8084a2cf075a6635ea25464287046ad987d74` retains these same package
bytes. The package identity remains:

- schema: `codex_work_mode_skill_package_manifest:v1`
- package ref/version: `codex_work_mode_skill_package` / `v1`
- identity: `operatorkit:codex_work_mode_skill_package:v1`

| Portable path | Required SHA-256 |
| --- | --- |
| `SKILL.md` | `6547d2aeee198bcc9e16c6f8fb6120f0efd443fe1d39b828ecaff2ca872182ae` |
| `agents/openai.yaml` | `f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007` |
| `codex_work_mode_skill_package_manifest.yml` | `0afe96c5f10ad621c720d248e3dcd4d84e98279de62052933b5d250cd8ca623a` |

The manifest stays self-excluding: it names only the two payload files. The
three-file package closure remains exact.

## Immutable Local Criteria

### Package and preservation

1. Replace only the local `SKILL.md` and self-excluding manifest with their
   exact committed OperatorKit bytes. Keep the descriptor byte-identical;
   package version and identity do not change.
2. Preserve `AGENTS.md` byte-for-byte, preserve all Wenfu product/runtime and
   safety rules, and do not copy any OperatorKit source beyond the three-file
   package.

### Routing, packets, repair, and receipts

3. Local ordinary work is Planning -> authoritative Control A/B -> one
   ephemeral Implementer. Planning commits an accepted plan and immutable
   criteria, then sends them directly to Control. It does not freeze an
   implementation packet, select implementation details, receive intermediate
   repair/status traffic, or monitor the Implementer.
4. Strategy receives a Planning message only for a cross-repository decision
   affecting another Planning task, a Strategy-owned lifecycle action, or
   changed evidence requiring re-evaluation of a registered gate. Local plan
   status, cleanup, closeout, terminal packets, and receipts remain between
   Planning and Control. A local-only packet misrouted to Strategy receives
   exactly: `Route this packet to the local Planning owner.`
5. A Control-owned conformance defect within unchanged criteria is a bounded,
   nonterminal repair. Control records the failed attempt/evidence, records an
   immutable repair packet with the direct mechanism and checks, and keeps at most
   one ephemeral Implementer active. It sends no Planning packet until an
   accepted outcome, true Planning design gap, Director authority decision, or
   no evidence-backed direct repair remains.
6. One immutable Control terminal packet identifies its delivery, attempt,
   source Control, target Planning, continuation disposition, and next
   owner/action. Planning sends the paired direct receipt with
   `released_terminal_idle`. Planning then classifies the parent and directly
   continues any known authorized local work; no `active_packet: none` is
   allowed without the exact missing decision and owner.

### Evidence, protected validation, and terminology

7. Preserve evidence-before-assertion and configured/documented/observed/
   unknown labels. Use immutable-artifact language precisely: commit the
   accepted plan, record criteria as immutable, Control records an immutable
   packet, and send the packet. Do not use generic active-prose "freeze".
8. A protected validation invocation requires a registered immutable policy
   with identity/version, repository/target/validator/command/worktree/commit,
   credential injection owner, safe receipt schema, side-effect/concurrency,
   nonce/replay, expiry/revocation, preconditions/postconditions, and
   uncertain-outcome fence. A trusted local credential-bearing validator—not
   Planning or the Director—holds credentials, verifies the manifest, executes
   an exact one-use match, and emits only a typed safe receipt. An unavailable
   policy/validator/tool is `protected_validator_unavailable`; human output is
   evidence, not follow-on authority.

### Allocation

9. Active allocation is Strategy `gpt-5.6-sol/xhigh`, Planning
   `gpt-5.6-sol/high`, and Control `gpt-5.6-terra/high` by default. A normal
   ephemeral Implementer is `gpt-5.6-terra/medium`; Terra/high requires an
   explicit packet complexity rationale. Handoff eligibility precedes model
   choice; it remains exceptional, with certified mechanical Luna/medium only
   after eligibility. GPT-5.5 is absent and Luna is never ephemeral.

## Exact Local Surface

Control determines exact packet-owned paths, but the bounded source set is:

- `.agents/skills/codex-work-mode/SKILL.md`
- `.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml`
- `ops/docs/reference/codex_work_mode.md`
- `ops/protocol/codex_work_mode.yml`
- `ops/docs/handoffs/templates/codex_control_implementation.md`
- `ops/docs/handoffs/codex_work_mode_current.md`
- `ops/scripts/verify_codex_work_mode_skill.sh`

`AGENTS.md`, `.agents/skills/codex-work-mode/agents/openai.yaml`, all product
source, historical archive records, deployment material, and external systems
are excluded.

## Acceptance Evidence

1. The local three-file package hashes and manifest payload hashes equal the
   table above; a direct byte comparison against OperatorKit commit `f737dc3e`
   passes; and no extra package file exists.
2. `AGENTS.md` and `agents/openai.yaml` are unchanged from the Planning base.
3. Local reference, protocol, template, snapshot, and verifier deterministically
   cover the immutable routing, nonterminal-repair/final-terminal receipt,
   protected-validation, immutable-artifact, and model-rationale rules.
4. Protocol YAML parses; the focused verifier, shell syntax, package/hash,
   committed-byte, residue, and diff checks pass; repository status is clean
   and staging is empty.

## Explicit Exclusions

No product/runtime code, database, configuration, environment, provider,
secret, account, payment, scheduler, deployment, production-data, push, or
external action is authorized. No intermediate local status is sent to
Strategy. After local acceptance, Planning sends Strategy only the compact
completion required for registered gate `codex_work_mode.package.f737dc3.v1`.
