# TempleMate version, build, and update receipts

| App version | iOS build | Android code | iOS build state | Published OTA update |
| --- | --- | --- | --- | --- |
| 1.0.0 | 1 | 1 | uploaded, distributed, installed by staff | see the update table below |
| 1.0.0 | 2 | 1 | prepared in `versioning.js`, not confirmed uploaded | none recorded |

Build 1 was uploaded to TestFlight, installed by Director's staff, and reported
green (Director, 2026-08-31). `versioning.js` was subsequently bumped to
iOS build 2 (`5e1e3cd`); whether that build was uploaded is not confirmed here.

Apple-side state is not visible from this repository. Any claim about
submission, review, or acceptance status must come from the Director or App
Store Connect, never from inference off `versioning.js`.

## Published OTA updates

| Update group | Date | Channel | Runtime | Platforms | Source commit |
| --- | --- | --- | --- | --- | --- |
| `ad7dd713-f47a-425c-89ce-0b3e04dfbefe` | 2026-09-03 | `testflight` | 1.0.0 | android, ios | `92cd19a` |
| `74f188d5-6b61-48c0-b82b-8df94005ede5` | 2026-09-03 | `testflight` | 1.0.0 | android, ios | `6095967` |
| `ad7dd713…` republished as rollback | 2026-09-03 | `testflight` | 1.0.0 | android, ios | `92cd19a` |
| `a81381b8-bbec-4bcd-baa3-564685a92fe1` | 2026-09-04 | `testflight` | 1.0.0 | android, ios | `a2c7450` |
| `b15df493-30a7-4535-a573-e9844f3ca4f3` | 2026-09-04 | `testflight` | 1.0.0 | android, ios | `cd6a257` |
| `1f1dd0ec-31a2-4f58-82ed-294b99ddf04c` | 2026-09-04 | `testflight` | 1.0.0 | android, ios | `c7a8d0a` |
| `4c774de9-1cb6-499b-81ef-8b2b5968b192` | 2026-09-05 | `testflight` | 1.0.0 | android, ios | `de6bc98` |

Message: "profile parity, OAuth prefill, remembered temple, demo tenant name".
Published by the Director from `release-1.0.0`, the first publish under the
release-branch rule.

EAS recorded the commit with a trailing `*`, meaning the working tree was not
clean. Nothing under `mobile/` was dirty — the untracked `.claude/` directory
and an in-progress edit to `ops/protocol/claude_work_mode.md` were — so the
published bundle matches `92cd19a` exactly.

Carried, being every mobile change since build 1 was reported green:

- `984018d` existing registrations surfaced, profile name prefilled, real temple name
- `6224452` demo tenant shows 示範宮廟 rather than the real temple's name
- `b2faeab` profile screen to four fields, real error messages
- `b54a58f` OAuth resolution prefilled from the provider's name and email
- `751ea19` remembered temple survives sign-out

`74f188d5` follows because that last one did not work. `751ea19` stopped
`App.js` clearing the binding but not `adapter.logout()`, which clears it
through `clearRetainedState` — so signing out still returned the patron to the
QR scanner. `6095967` removes the clear from the adapter and is covered by a
test that fails if it comes back.

Both updates carry a trailing `*` on the commit, meaning an unclean tree. In
both cases nothing under `mobile/` differed, so each bundle matches its commit
exactly; the untracked `.claude/` directory accounts for it.

### 2026-09-04: three updates crashed before one worked

`ae82ad6` (dummy client removed) crashed on launch. `a2c7450` added a boot
guard and did not fire, which narrowed it to render rather than module scope.
`868bbee` added an error boundary that caught the crash but rendered a white
screen -- its failure screen used SafeAreaProvider, which renders null until it
measures. `75cd73c` made that screen dependency-free.

The cause was found on the Pixel dev client against local Rails in minutes,
not through those OTA cycles: `AccountSurface` referenced `loadingText`, which
is defined inside `AppBody` and never passed to it. Pre-existing, and only
reachable once a release build could restore its temple and stop landing on
TenantSetupGate -- the earlier binding bug had been hiding it. `cd6a257` fixes
it and adds a test that fails if the prop is dropped again.

`c7a8d0a` follows and was found the recorded way -- on the Pixel against local
Rails, before publishing. Two faults the Director hit on production: OAuth
sign-in never called loadCollections, so Google users saw the registrations
bootstrap returns and no offerings at all; and every bound screen carried the
removed dummy client's disclosure, telling patrons the app never contacts a
service while it was talking to the server.

**Lesson recorded because it cost three publishes:** debug on the dev client
against a local server. An OTA round trip tells you almost nothing, and the
device is only reachable through TestFlight for iOS -- which is exactly why the
error boundary is worth keeping, and why it was verified by throwing on purpose
and reading the result off the device rather than assumed to work.

### 2026-09-05: an event's own image, and a fixture that lied

`de6bc98` sends `hero_image_url` in `offering_payload` and renders it in
`OfferingList`. The offering's OWN picture only -- `EventShow.vue:37` falls
back to the temple's `event` image because one large hero about one event is
worth showing even when it is the default, but in a list every image-less row
would carry that same picture. The Director's ruling: "own image only, no
fallback."

**This update is inert until the Rails side ships.** The app reads a key the
droplet does not send yet, so it renders no image -- exactly today's behavior,
no regression, but no feature either. `de6bc98` must reach `release/current`
and the droplet be restarted before a patron sees anything change.

Verified on the Pixel dev client against local Rails before publishing, as the
2026-09-04 lesson requires. The first attempt looked like a bug and was not:
the test fixture pointed at `placehold.co`, which serves `image/svg+xml` by
default, and React Native's `Image` cannot render SVG -- it laid out the 132dp
box and drew nothing, with no error in logcat, on device, or in the bundle.
Adding `.png` to the URL rendered it immediately. **A fixture can fail in a way
that is indistinguishable from the code failing.**

Consequence still open: nothing validates that a pasted `hero_image_url` is a
raster format, so a temple admin pasting an SVG gets a silently blank box in
the app while the website renders it fine.

The new test is mutation-checked -- reintroducing the fallback fails it with
its own message, so it is not passing for the wrong reason.

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
