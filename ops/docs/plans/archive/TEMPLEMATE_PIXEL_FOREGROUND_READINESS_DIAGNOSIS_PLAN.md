# TempleMate Pixel Foreground Readiness Diagnosis Plan

Status: accepted for direct read-only diagnosis after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`7206892328440da3e3df53802581d76de3c39cb8`

## Objective

Determine why Android 17 continues to report and render NotificationShade
after ordinary collapse, Back, a display-derived upward swipe and Home plus an
exact TempleMate activity start. This packet is read-only device diagnosis. It
must identify the screen/power/keyguard/window state before Planning selects
any further foreground method.

## Authorized Read-Only Evidence

On exact serial `39011FDJH00FQ8`, after reconfirming Pixel 8 / `shiba`, ADB
`device` state and installed `com.jimmy1768.komainu.dev`, Control may read only:

- interactive/display/power state;
- keyguard showing, secure, occluded and lock-task state;
- current/resumed/focused window and activity/package state;
- status-bar/notification-panel expansion state when available;
- physical display dimensions and rotation;
- one fresh UI hierarchy; and
- one temporary device screenshot for visual classification by Control.

The durable report records only sanitized classifications and may state the
visible system surface; it must not retain notification text, personal data,
account identifiers or screenshot pixels. Delete the screenshot and hierarchy
after classification.

## Prohibited Actions

No key event, tap, swipe, wake, sleep, unlock/dismiss-keyguard attempt,
status-bar command, activity start, launcher interaction, notification action,
app interaction, Metro/reverse, source/test/config/dependency change,
build/install, provider/API, deployment, push or external mutation.

## Required Return

Return one terminal report with:

- exact target/package fence result;
- whether display is interactive/on;
- whether keyguard is showing and whether it is secure;
- whether NotificationShade is visually expanded, a lock-screen shade, a
  stale focus record, or another classified system surface;
- current/resumed/underlying app relationship;
- smallest safe next foreground mechanism, or the exact prerequisite that
  cannot be satisfied without Director action; and
- proof all temporary evidence was deleted and no device mutation occurred.

Canonical integration is report-only and separately accepted by Planning.
