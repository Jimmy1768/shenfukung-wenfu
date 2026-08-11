# Expo EAS project creation and link — safe receipt

Date: 2026-08-12

Scope: one authorized creation attempt for the exact public Expo target
`@jimmy1768/templemate`. This receipt records safe public outcome fields only.

## Protected invocation receipt

- Installed CLI: `/opt/homebrew/bin/eas` version `18.12.2`.
- Authenticated account label: `jimmy1768`.
- Collision preflight: the exact target was absent.
- One forced, noninteractive creation attempt: successful for
  `@jimmy1768/templemate`.
- Returned project ID: `c7b8523a-2fad-4123-bc96-0c0c85a23dec`.
- The command then exited nonzero only because dynamic `app.config.js` cannot
  be modified automatically. No creation retry occurred.
- A temporary local dependency-tree symlink was created only for the protected
  call and removed afterward.

## Local reconciliation

`mobile/app.config.js` now declares owner `jimmy1768` and the exact returned
project ID at `expo.extra.eas.projectId`. Development and production resolved
public config are guarded to use the same owner and project ID.

## Read-only reconciliation

- `CI=1 /opt/homebrew/bin/eas project:info` resolves exactly
  `@jimmy1768/templemate` with the same returned project ID; no other project
  was selected or linked.
- `CI=1 /opt/homebrew/bin/eas config --platform android --profile development
  --json` resolves the linked internal Android development-client APK profile:
  `TempleMate (Dev)`, `com.jimmy1768.komainu.dev`, `templemate`, API 36,
  development client, internal distribution, APK build type, the accepted
  camera/no-audio declaration, and
  `templemate://oauth/complete`.
- Both public config modes preserve the Komainu development/production
  identifier split, dummy default, version `1.0.0`, Android code `1`, iOS
  build `1`, local version authority, and no auto-increment.

## Local checks and terminal state

- `yarn test` passed 42 tests; `yarn lint` and `yarn verify` passed.
- Focused rejected-identifier, project-ID, secret, generated-native-artifact,
  signing-material, version, and diff checks passed.
- Temporary dependency symlinks were removed after the protected calls; no
  generated project, native artifact, credential, signing, provider,
  deployment, Metro, ADB, device, or release action occurred.

**Terminal classification:** `eas_project_created_and_linked`.

The next smallest separately authorized phase is Android signing/build
preflight or an EAS cloud development-client build packet. Neither is implied
by this project creation and link.
