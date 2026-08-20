const test = require('node:test');
const assert = require('node:assert/strict');
const { createOAuthController, returnMatches, phases } = require('../app/oauth/transaction');
const { createPkce, validVerifier } = require('../app/oauth/pkce');
const { copy, oauthErrorPhases } = require('../app/ui/copy');

const returnUrl = 'templemate://oauth/complete';
const memoryStorage = () => { let pending = null; return { savePending: async value => { pending = { ...value }; }, loadPending: async () => pending && { ...pending }, clearPending: async () => { pending = null; } }; };
const pkce = (() => { let byte = 0; return async () => createPkce({ randomBytes: async count => Uint8Array.from({ length: count }, () => ++byte), sha256: async value => `challenge-${value}`.replace(/[^A-Za-z0-9_-]/g, '').padEnd(43, 'x').slice(0, 43) }); })();
const fakeAdapter = ({ storage = memoryStorage(), exchange = null, start = null, clearOAuthSession = null, consumeResolution = undefined } = {}) => {
  const calls = [];
  return {
    calls, oauthStorage: storage,
    startOAuth: async input => { calls.push({ kind: 'start', input }); return start || { authorization_url: 'https://central.example.test/authorize', redirect_uri: returnUrl, transaction_token: 'opaque-transaction', provider: input.provider, expires_in: 60 }; },
    exchangeOAuth: async input => { calls.push({ kind: 'exchange', input }); if (exchange instanceof Error) throw exchange; return typeof exchange === 'function' ? exchange(input) : exchange || { snapshot: { profile: { email: 'member@example.test' } }, oauth: { provider: 'google', profile_required: false } }; },
    ...(clearOAuthSession ? { clearOAuthSession } : {}),
    ...(consumeResolution !== undefined ? { consumeOAuthResolution: async input => { calls.push({ kind: 'consumeResolution', input }); if (consumeResolution instanceof Error) throw consumeResolution; return typeof consumeResolution === 'function' ? consumeResolution(input) : consumeResolution; } } : {})
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

test('an unmatched identity enters account_resolution with the token kept only in memory, not cleared like a failure', async () => {
  let sessionCleared = false;
  const exchangeError = Object.assign(new Error('unmatched'), { code: 'account_resolution_required', oauth: { provider: 'google', resolution_token: 'resolve-me' } });
  const adapter = fakeAdapter({ exchange: exchangeError, clearOAuthSession: async () => { sessionCleared = true; } });
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=unmatched` }) });
  const next = await controller.begin('google');
  assert.equal(next.phase, 'account_resolution');
  assert.equal(next.provider, 'google');
  assert.equal(next.detail, 'resolve-me');
  assert.equal(sessionCleared, false, 'no session was ever applied for an unmatched identity, so nothing should be cleared');
  assert.equal(await adapter.oauthStorage.loadPending(), null, 'pending was already consumed before exchange, same as any other outcome');
});

test('a 409 missing a resolution_token falls back to a normal failure instead of entering an unusable resolution phase', async () => {
  const exchangeError = Object.assign(new Error('unmatched'), { code: 'account_resolution_required', oauth: null });
  const adapter = fakeAdapter({ exchange: exchangeError });
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=bad` }) });
  assert.equal((await controller.begin('google')).phase, 'failed');
});

test('consumeResolution completes an account_resolution into authenticated, passing the retained token and provider through -- the contract is login-shaped, no profile_required branch', async () => {
  const adapter = fakeAdapter({
    exchange: Object.assign(new Error('unmatched'), { code: 'account_resolution_required', oauth: { provider: 'apple', resolution_token: 'tok-1' } }),
    consumeResolution: { user: { id: 1 }, session: { access_token: 'a', refresh_token: 'r' } }
  });
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=unmatched` }) });
  assert.equal((await controller.begin('apple')).phase, 'account_resolution');
  const next = await controller.consumeResolution({ mode: 'new', email: 'new@example.test', password: 'secret', name: 'New User', termsAccepted: true });
  assert.equal(next.phase, 'authenticated'); assert.equal(next.provider, 'apple');
  const call = adapter.calls.find(item => item.kind === 'consumeResolution').input;
  assert.equal(call.provider, 'apple'); assert.equal(call.resolutionToken, 'tok-1'); assert.equal(call.mode, 'new'); assert.equal(call.email, 'new@example.test'); assert.equal(call.termsAccepted, true);
});

test('consumeResolution rejects without disturbing state when the adapter rejects (wrong password, duplicate email, etc.)', async () => {
  const adapter = fakeAdapter({
    exchange: Object.assign(new Error('unmatched'), { code: 'account_resolution_required', oauth: { provider: 'google', resolution_token: 'tok-2' } }),
    consumeResolution: Object.assign(new Error('bad credentials'), { code: 'invalid_credentials' })
  });
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=unmatched` }) });
  assert.equal((await controller.begin('google')).phase, 'account_resolution');
  await assert.rejects(() => controller.consumeResolution({ mode: 'existing', email: 'x@example.test', password: 'wrong' }), { code: 'invalid_credentials' });
  assert.equal(controller.snapshot().phase, 'account_resolution', 'a rejected attempt should leave the user able to retry, not fail the whole flow');
});

test('consumeResolution refuses to run outside account_resolution, and refuses against an adapter that cannot complete it', async () => {
  const idleController = createOAuthController({ adapter: fakeAdapter({ consumeResolution: {} }), createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'cancel' }) });
  await assert.rejects(() => idleController.consumeResolution({ mode: 'existing', email: 'x@example.test', password: 'y' }));
  const adapter = fakeAdapter({ exchange: Object.assign(new Error('unmatched'), { code: 'account_resolution_required', oauth: { provider: 'google', resolution_token: 'tok-3' } }) });
  delete adapter.consumeOAuthResolution;
  const controller = createOAuthController({ adapter, createPkce: pkce, expectedReturnUrl: returnUrl, openBrowser: async () => ({ type: 'success', url: `${returnUrl}?code=unmatched` }) });
  assert.equal((await controller.begin('google')).phase, 'account_resolution');
  await assert.rejects(() => controller.consumeResolution({ mode: 'existing', email: 'x@example.test', password: 'y' }));
});

test("App.js's oauthErrorPhases allowlist stays a strict subset of the real phase set and excludes every non-error outcome", () => {
  // Real bug, 2026-08-20: App.js's beginOAuth used to treat every phase
  // except an ad hoc exclusion list ('authenticated', 'profile_required',
  // 'interrupted') as an error. When account_resolution was added later,
  // nobody updated that list, so a legitimate new-account/link-account
  // transition rendered "External sign-in did not complete" over the
  // resolution screen it had just successfully reached. oauthErrorPhases
  // inverts this to a closed allowlist so the same class of mistake can't
  // recur silently -- a new non-error phase does nothing until someone
  // deliberately adds it to the error set, instead of erroring until
  // someone remembers to exclude it.
  for (const phase of oauthErrorPhases) assert.ok(phases.has(phase), `${phase} must be a real transaction phase`);
  for (const phase of ['account_resolution', 'authenticated', 'profile_required', 'interrupted', 'idle', 'pending', 'browser_opened', 'returned', 'exchanging']) {
    assert.equal(oauthErrorPhases.has(phase), false, `${phase} is not an error outcome and must not be in oauthErrorPhases`);
  }
  for (const locale of Object.keys(copy)) {
    for (const phase of oauthErrorPhases) assert.ok(copy[locale].oauthOutcome[phase], `copy.${locale}.oauthOutcome.${phase} must have text for every error phase`);
  }
});
