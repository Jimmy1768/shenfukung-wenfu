const test = require('node:test');
const assert = require('node:assert/strict');
const { createOAuthController, returnMatches } = require('../app/oauth/transaction');
const { createPkce, validVerifier } = require('../app/oauth/pkce');

const returnUrl = 'templemate://oauth/complete';
const memoryStorage = () => { let pending = null; return { savePending: async value => { pending = { ...value }; }, loadPending: async () => pending && { ...pending }, clearPending: async () => { pending = null; } }; };
const pkce = (() => { let byte = 0; return async () => createPkce({ randomBytes: async count => Uint8Array.from({ length: count }, () => ++byte), sha256: async value => `challenge-${value}`.replace(/[^A-Za-z0-9_-]/g, '').padEnd(43, 'x').slice(0, 43) }); })();
const fakeAdapter = ({ storage = memoryStorage(), exchange = null, start = null, clearOAuthSession = null } = {}) => {
  const calls = [];
  return {
    calls, oauthStorage: storage,
    startOAuth: async input => { calls.push({ kind: 'start', input }); return start || { authorization_url: 'https://central.example.test/authorize', redirect_uri: returnUrl, transaction_token: 'opaque-transaction', provider: input.provider, expires_in: 60 }; },
    exchangeOAuth: async input => { calls.push({ kind: 'exchange', input }); if (exchange instanceof Error) throw exchange; return typeof exchange === 'function' ? exchange(input) : exchange || { snapshot: { profile: { email: 'member@example.test' } }, oauth: { provider: 'google', profile_required: false } }; },
    ...(clearOAuthSession ? { clearOAuthSession } : {})
  };
};

test('fresh S256 PKCE values are generated without retaining the verifier after successful exchange', async () => {
  const adapter = fakeAdapter();
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=central-code` }) });
  assert.equal((await controller.begin('google')).phase, 'authenticated');
  const first = adapter.calls.find(call => call.kind === 'start').input;
  const exchange = adapter.calls.find(call => call.kind === 'exchange').input;
  assert.equal(first.pkceMethod, 'S256'); assert.equal(validVerifier(exchange.pkceVerifier), true); assert.equal(await adapter.oauthStorage.loadPending(), null);
  await controller.begin('google');
  const second = adapter.calls.filter(call => call.kind === 'start')[1].input;
  assert.notEqual(first.pkceChallenge, second.pkceChallenge);
});

test('callback handling requires the active expected return, consumes state before exchange, and rejects replay', async () => {
  const adapter = fakeAdapter(); const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'interrupted' }) });
  assert.equal((await controller.begin('apple')).phase, 'interrupted');
  assert.equal((await controller.handleReturn('templemate://wrong/complete?code=x')).phase, 'invalid');
  assert.equal(await adapter.oauthStorage.loadPending(), null);
  await controller.begin('google');
  assert.equal((await controller.handleReturn(`${returnUrl}?code=once`)).phase, 'authenticated');
  assert.equal((await controller.handleReturn(`${returnUrl}?code=once`)).phase, 'invalid');
  assert.equal(returnMatches(`${returnUrl}?code=x`, returnUrl), true);
  assert.equal(returnMatches('templemate://oauth/other?code=x', returnUrl), false);
});

test('cancellation, denial, failure, expiry, tamper, interruption and reset all fail closed or retain only a valid interrupted return', async () => {
  let now = 1000;
  const cases = [
    [{ type: 'cancel' }, 'cancelled'],
    [{ type: 'success', url: `${returnUrl}?error=access_denied` }, 'denied'],
    [{ type: 'success', url: `${returnUrl}?error=upstream_failure` }, 'failed'],
    [{ type: 'success', url: `${returnUrl}` }, 'invalid']
  ];
  for (const [browserResult, phase] of cases) {
    const adapter = fakeAdapter(); const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => browserResult, now: () => now });
    assert.equal((await controller.begin('google')).phase, phase); assert.equal(await adapter.oauthStorage.loadPending(), null);
  }
  const expiredStorage = memoryStorage(); await expiredStorage.savePending({ provider: 'google', redirectUri: returnUrl, transactionToken: 'token', verifier: 'v'.repeat(64), createdAt: 1, expiresAt: 999 });
  const expired = createOAuthController({ adapter: fakeAdapter({ storage: expiredStorage }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'cancel' }), now: () => now });
  assert.equal((await expired.restore()).phase, 'expired'); assert.equal(await expiredStorage.loadPending(), null);
  const interruptedStorage = memoryStorage(); const interrupted = createOAuthController({ adapter: fakeAdapter({ storage: interruptedStorage }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'interrupted' }), now: () => now });
  assert.equal((await interrupted.begin('apple')).phase, 'interrupted'); assert.equal((await interrupted.restore()).phase, 'interrupted'); await interrupted.clear(); assert.equal(await interruptedStorage.loadPending(), null);
});

test('profile-required, closed-account, and malformed exchange outcomes do not create an untrusted session state', async () => {
  const profile = createOAuthController({ adapter: fakeAdapter({ exchange: { snapshot: { profile: {} }, oauth: { provider: 'google', profile_required: true } } }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=profile` }) });
  assert.equal((await profile.begin('google')).phase, 'profile_required');
  const closed = createOAuthController({ adapter: fakeAdapter({ exchange: Object.assign(new Error('closed'), { code: 'account_closed' }) }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=closed` }) });
  assert.equal((await closed.begin('google')).phase, 'closed');
  const malformed = createOAuthController({ adapter: fakeAdapter({ exchange: { snapshot: null, oauth: { provider: 'google', profile_required: false } } }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=bad` }) });
  assert.equal((await malformed.begin('google')).phase, 'failed');
});

test('a normal browser return is exclusive of the restored-link handler and cannot overwrite an authenticated state', async () => {
  let resolveBrowser;
  const browser = new Promise(resolve => { resolveBrowser = resolve; });
  let resolveExchange;
  const adapter = fakeAdapter({ exchange: () => new Promise(resolve => { resolveExchange = resolve; }) });
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => browser });
  const started = controller.begin('google');
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(controller.snapshot().phase, 'browser_opened');
  assert.equal((await controller.handleInterruptedReturn(`${returnUrl}?code=duplicate`)).phase, 'browser_opened');
  assert.equal(adapter.calls.filter(call => call.kind === 'exchange').length, 0);
  resolveBrowser({ type: 'success', url: `${returnUrl}?code=once` });
  await new Promise(resolve => setImmediate(resolve));
  const duplicate = controller.handleReturn(`${returnUrl}?code=once`);
  resolveExchange({ snapshot: { profile: {} }, oauth: { provider: 'google', profile_required: true } });
  assert.equal((await started).phase, 'profile_required');
  assert.equal((await duplicate).phase, 'profile_required');
  assert.equal((await controller.handleInterruptedReturn(`${returnUrl}?code=duplicate`)).phase, 'profile_required');
  assert.equal(adapter.calls.filter(call => call.kind === 'exchange').length, 1);
});

test('malformed and provider-mismatched exchange results clear an adapter-applied session before failing', async () => {
  for (const result of [
    { snapshot: { profile: { email: 'member@example.test' } }, oauth: { provider: 'apple', profile_required: false } },
    { snapshot: null, oauth: { provider: 'google', profile_required: false } }
  ]) {
    let applied = true;
    const adapter = fakeAdapter({ exchange: result, clearOAuthSession: async () => { applied = false; } });
    const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=bad` }) });
    assert.equal((await controller.begin('google')).phase, 'failed');
    assert.equal(applied, false);
    assert.equal(await adapter.oauthStorage.loadPending(), null);
  }
});
