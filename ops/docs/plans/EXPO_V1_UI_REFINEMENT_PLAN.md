# Expo V1 UI Refinement Plan

Status: accepted final core-V1 phase boundary; planned after functional parity;
not current implementation authority

Created: 2026-08-11

Owner: Wenfu Planning

Parent roadmap: `ops/docs/plans/EXPO_ACCOUNT_APP_V1_ROADMAP.md`

## Objective

Refine the already-functional account app after dummy UI, native foundation,
and core account parity are accepted. This phase improves presentation and
interaction quality without changing V1 features, Rails contracts, or
authorization semantics.

## Included Refinement

- coherent account information hierarchy and navigation labels;
- shared colors, typography, spacing, radii, icons, and component primitives;
- screen consistency for loading, empty, validation, retry, pending,
  confirmation, success, and signed-out states;
- keyboard behavior, focus order, touch targets, screen-reader labels, dynamic
  text, reduced motion, contrast, and accessible error presentation;
- Android 16 edge-to-edge, system bars/insets, back navigation, app resume, and
  form behavior;
- iOS layout and interaction checks when the authorized packet includes an
  available simulator/device;
- Traditional Chinese and English copy consistency for the included core V1
  surface;
- low-connectivity and interrupted-flow presentation for requests already in
  V1;
- removal of remaining placeholder, template, admin, and test-only visual
  residue from the functional app surface.

DojoMate and sibling repositories may guide mature native interaction and
component patterns. They do not override TempleMate identity or Wenfu account
behavior.

## Explicit Exclusions

- new screens, resources, CRUD operations, providers, permissions, or product
  features;
- OAuth or payment scope;
- branding/domain/store asset creation for distribution;
- AAB/store submission, deployment, production data, or release promotion.

## Immutable Acceptance Criteria

1. Every core V1 flow remains functionally equivalent to its accepted pre-
   refinement behavior.
2. Refinement adds no route, field, operation, provider, permission, or
   business rule.
3. Account-only and tenant-isolation boundaries remain unchanged.
4. The included screens have coherent reusable native components and complete
   Traditional Chinese/English copy.
5. Required accessibility, Android 16, keyboard, back, resume, and interruption
   checks pass for the included flows.
6. No OAuth, payment, production, distribution, or release work occurs.
7. Focused checks pass and final source state is clean and attributable.

## Current Gate

This phase begins only after core account parity is functionally accepted. UI
uncertainty before then is not a blocker to the preceding infrastructure and
parity phases.
