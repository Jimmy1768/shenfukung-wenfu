# TempleMate EAS build and update lanes

This source contract reserves `testflight` and `production` as distinct, app-version runtime lanes for TempleMate. Both use the public Shengfukung demo origin and tenant; they do not constitute an EAS channel, branch, build, or published update receipt.

`yarn build:testflight` and `yarn build:production` are cloud-build entry points requiring later Director authority. `yarn ota:testflight <message>` and `yarn ota:production <message> production` are guarded wrappers. They fail before EAS invocation without a clean attributed release source, accepted receipt, release environment, lane/message, and production scope token. Rollback is a separately authorized republish/reconciliation operation.

No values for signing, Apple, provider registration, privacy/support/deletion URLs, or EAS environments are stored here.
