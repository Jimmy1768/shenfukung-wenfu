# TempleMate EAS build and update lanes

This source contract defines `testflight` and `production` as distinct, app-version runtime lanes for TempleMate. Both use the public Shengfukung demo origin and tenant (`https://shengfukung.com.tw`, `shengfukung-wenfu`).

**`testflight` is a live EAS Update channel** (Director, 2026-08-31): iOS build 1 was uploaded, distributed, and installed by staff, and simple JS changes reach that lane as an OTA update rather than a rebuild. Native config, native dependency, and `runtimeVersion` changes still require a build. `production` remains reserved and unexercised.

This file describes the lane contract only. It is not a receipt: what has actually been built, uploaded, or published is tracked in `ops/docs/reference/templemate_release_receipts.md`.

The routine iteration lane is neither of these — it is the Android dev-client APK (`development` profile: internal distribution, `buildType: apk`, no channel) with JS served by `yarn dev-client`. Promote to iOS only for a production test.

`yarn build:testflight` and `yarn build:production` are cloud-build entry points requiring later Director authority. `yarn ota:testflight <message>` and `yarn ota:production <message> production` are guarded wrappers. They fail before EAS invocation without a clean attributed release source, accepted receipt, release environment, lane/message, and production scope token. Rollback is a separately authorized republish/reconciliation operation.

No values for signing, Apple, provider registration, privacy/support/deletion URLs, or EAS environments are stored here.
