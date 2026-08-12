const test = require('node:test');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const { createDummyAdapter } = require('../app/dummy/adapter');
const { createOAuthController } = require('../app/oauth/transaction');
const { base64ToBase64Url, verifierFromBytes } = require('../app/oauth/pkce');

const returnUrl = 'templemate://oauth/complete';
let serial = 0;
const pkce = async () => {
  const verifier = verifierFromBytes(Uint8Array.from({ length: 32 }, (_, index) => (index + ++serial) % 256));
  const digest = createHash('sha256').update(verifier).digest('base64');
  return { verifier, challenge: base64ToBase64Url(digest), method: 'S256' };
};
const controllerFor = adapter => createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: adapter.openOAuthBrowser });

test('dummy Google and Apple journeys are deterministic, injected, visibly fixture-only, and network-free', async () => {
  for (const provider of ['google', 'apple']) {
    for (const [journey, expected] of Object.entries({ success: 'authenticated', profile_required: 'profile_required', cancellation: 'cancelled', denial: 'denied', failure: 'failed', interruption: 'interrupted' })) {
      const adapter = createDummyAdapter(undefined, { oauthJourney: journey }); const controller = controllerFor(adapter);
      assert.equal((await controller.begin(provider)).phase, expected, `${provider}:${journey}`);
      if (journey === 'success') assert.equal(adapter.snapshot().profile.email, 'member@example.test', `${provider}:account_snapshot`);
      if (journey === 'interruption') assert.equal((await controller.restore()).phase, 'interrupted');
      else assert.equal(await adapter.oauthStorage.loadPending(), null, `${provider}:${journey}:clean`);
      assert.equal(adapter.network, 'disabled');
    }
  }
});

test('dummy reset, tenant clear, and invalid/replayed callbacks clear the fixture transaction without a network fallback', async () => {
  const adapter = createDummyAdapter(undefined, { oauthJourney: 'interruption' }); const controller = controllerFor(adapter);
  await controller.begin('google'); assert.ok(await adapter.oauthStorage.loadPending());
  adapter.reset(); assert.equal(await adapter.oauthStorage.loadPending(), null);
  await controller.begin('apple'); await adapter.clearTenantState(); assert.equal(await adapter.oauthStorage.loadPending(), null);
  assert.equal((await controller.handleReturn(`${returnUrl}?code=fixture-apple-success`)).phase, 'invalid');
});
