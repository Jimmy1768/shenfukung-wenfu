const test = require('node:test');
const assert = require('node:assert/strict');
const { createDummyAdapter } = require('../app/dummy/adapter');
const { createOAuthController } = require('../app/oauth/transaction');

const returnUrl = 'templemate://oauth/complete';
let serial = 0;
const pkce = async () => ({ verifier: `v${String(++serial).padStart(63, '0')}`, challenge: `c${String(serial).padStart(42, '0')}`, method: 'S256' });
const controllerFor = adapter => createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: adapter.openOAuthBrowser });

test('dummy Google and Apple journeys are deterministic, injected, visibly fixture-only, and network-free', async () => {
  for (const provider of ['google', 'apple']) {
    for (const [journey, expected] of Object.entries({ success: 'authenticated', profile_required: 'profile_required', cancellation: 'cancelled', denial: 'denied', failure: 'failed', interruption: 'interrupted' })) {
      const adapter = createDummyAdapter(undefined, { oauthJourney: journey }); const controller = controllerFor(adapter);
      assert.equal((await controller.begin(provider)).phase, expected, `${provider}:${journey}`);
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
