# TempleMate version, build, and update receipts

| App version | iOS build | Android code | iOS build state | Published OTA update |
| --- | --- | --- | --- | --- |
| 1.0.0 | 1 | 1 | uploaded, distributed, installed by staff | none recorded |
| 1.0.0 | 2 | 1 | prepared in `versioning.js`, not confirmed uploaded | none recorded |

Build 1 was uploaded to TestFlight, installed by Director's staff, and reported
green (Director, 2026-08-31). `versioning.js` was subsequently bumped to
iOS build 2 (`5e1e3cd`); whether that build was uploaded is not confirmed here.

Apple-side state is not visible from this repository. Any claim about
submission, review, or acceptance status must come from the Director or App
Store Connect, never from inference off `versioning.js`.

## Working lanes (Director, 2026-08-31)

- **Iterate on the Android dev-client APK.** Build the dev client once
  (`eas build --platform android --profile development` — internal
  distribution, `buildType: apk`, no channel), then serve JS to it with
  `yarn dev-client`. This mirrors DojoMate-Expo, which likewise has no
  `build:*:development` script because the APK is a one-time artifact.
- **Promote to iOS only when ready for a production test**, not for routine
  verification.
- **`testflight` is an EAS Update channel.** Simple JS changes ship to it as
  an OTA update; they do not require a rebuild. Native config, native
  dependency, or `runtimeVersion` changes still do.

`runtimeVersion` is pinned to `versioning.appVersion` (`1.0.0`) at the top
level of `app.config.js`, so OTA updates only reach builds sharing that
version.

## Source

- `mobile/versioning.js` — the single version/build source.
- `mobile/eas.json` — `development`, `testflight`, `production` profiles.
- `mobile/package.json` — `dev-client`, `build:testflight`, `ota:testflight`.
- `ops/docs/reference/templemate_eas_ota_release_lanes.md` — the lane contract
  and the guarded OTA wrappers.
