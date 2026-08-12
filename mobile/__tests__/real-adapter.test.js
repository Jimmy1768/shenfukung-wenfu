const test = require('node:test');
const assert = require('node:assert/strict');
const { createRealAdapter } = require('../app/real/adapter');
const { resolveClientConfig, localTenantBinding } = require('../app/real/config');
const { sessionKey } = require('../app/real/storage');
const { createOAuthController } = require('../app/oauth/transaction');

const config = { mode: 'real', apiBaseUrl: 'http://local.test', tenantSlug: 'fixture-temple', environment: 'test' };
const store = () => { const values = new Map(); return { values, getItem: async key => values.get(key) || null, setItem: async (key, value) => values.set(key, value), deleteItem: async key => values.delete(key) }; };
const user = { id: 1, email: 'member@example.test', native_name: '林小安' };
const session = { access_token: 'access-1', refresh_token: 'refresh-1', token_type: 'Bearer', expires_in: 900 };
const response = (body = {}, status = 200) => ({ ok: status >= 200 && status < 300, status, body });

function fixtureTransport(calls, failures = {}, overrides = {}) {
  return async request => {
    calls.push(request);
    const path = request.url.replace(/^.*\/native/, '').replace(/\?.*$/, '');
    if (overrides[path]) return overrides[path];
    if (failures[path]) return failures[path];
    if (path === '/login' || path === '/signup' || path === '/password/reset') return response({ user, session });
    if (path === '/oauth/start') return response({ oauth: { authorization_url: 'https://central.example.test/authorize', redirect_uri: 'templemate://oauth/complete', transaction_token: 'opaque-native-transaction', provider: JSON.parse(request.body).oauth.provider, expires_in: 300 } }, 201);
    if (path === '/oauth/exchange') return response({ user, session, oauth: { provider: 'google', profile_required: false } });
    if (path === '/refresh') return response({ session: { ...session, access_token: 'access-2', refresh_token: 'refresh-2' } });
    if (path === '/bootstrap') return response({ user, temple: { slug: 'fixture-temple', name: 'Fixture' }, preferences: { locale: 'zh-TW' }, registrations: [{ id: 9, offering: { id: 1, title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, quantity: 1, total_amount_cents: 1200, fulfillment_status: 'pending', payment_status: 'unpaid', lifecycle: 'pending', payment_state: 'unpaid' }], certificates: [{ id: 3 }] });
    if (path === '/profile') return response({ user: { ...user, native_name: '新名字' } });
    if (path === '/dependents') return request.method === 'GET' ? response({ dependents: [{ id: 4, native_name: '家屬', relationship_label: '家人' }] }) : response({ dependent: { id: 5, native_name: '新家屬', relationship_label: '子女' } }, request.method === 'POST' ? 201 : 200);
    if (/^\/dependents\//.test(path)) return request.method === 'DELETE' ? response({}, 204) : response({ dependent: { id: 4, native_name: '家屬', relationship_label: '家人' } });
    if (path === '/registrations') return request.method === 'GET' ? response({ registrations: [{ id: 9, offering: { id: 1, title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, quantity: 1, total_amount_cents: 1200, fulfillment_status: 'pending', payment_status: 'unpaid', lifecycle: 'pending', payment_state: 'unpaid' }] }) : response({ registration: { id: 10, offering: { id: 2, title: '超薦', slug: 'memorial', account_action: 'event', price_cents: 600, currency: 'TWD' }, quantity: 1, total_amount_cents: 600, fulfillment_status: 'pending', payment_status: 'unpaid', lifecycle: 'pending', payment_state: 'unpaid' } }, 201);
    if (/^\/registrations\/new/.test(path)) return response({ offering: { id: 1, title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, registration: { quantity: 1 }, registrants: [{ scope: 'self', id: 1, label: '林小安' }] });
    if (/^\/registrations\/\d+\/edit/.test(path)) return response({ registration: { id: 9, offering: { id: 1, title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, quantity: 1, total_amount_cents: 1200 } });
    if (/^\/registrations\/\d+/.test(path)) return response({ registration: { id: 9, offering: { id: 1, title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, quantity: 1, total_amount_cents: 1200, fulfillment_status: 'pending', payment_status: 'unpaid', lifecycle: 'pending', payment_state: 'unpaid' } });
    if (['/events', '/services', '/galleries', '/certificates', '/privacy', '/preferences'].includes(path)) return response({ [path.slice(1)]: [] });
    if (/^\/galleries\//.test(path)) return response({ gallery: { id: 1 } });
    return response({ accepted: true }, request.method === 'POST' ? 201 : 200);
  };
}

test('real mode is deliberate and cannot be configured without local tenant and API inputs', () => {
  assert.deepEqual(resolveClientConfig({}), { mode: 'dummy', apiBaseUrl: '', tenantSlug: '', environment: 'development', oauthReturnUrl: 'templemate://oauth/complete' });
  assert.throws(() => resolveClientConfig({ clientMode: 'real' }), { code: 'REAL_CONFIG_REQUIRED' });
  assert.equal(resolveClientConfig({ clientMode: 'real', localApiBaseUrl: 'http://local.test/', localTenantSlug: 'fixture', clientEnvironment: 'test' }).tenantSlug, 'fixture');
  assert.throws(() => resolveClientConfig({ clientMode: 'real', localApiBaseUrl: 'https://example.com', localTenantSlug: 'fixture' }), { code: 'LOCAL_API_REQUIRED' });
  assert.throws(() => resolveClientConfig({ nativeOAuthReturnUrl: 'templemate://wrong' }), { code: 'NATIVE_OAUTH_RETURN_REQUIRED' });
  assert.deepEqual(localTenantBinding(config), { state: 'bound', tenant: { id: 'fixture-temple', name: 'fixture-temple' }, error: null, source: 'local-test' });
});

test('real adapter maps the complete account contract and never falls back to dummy data', async () => {
  const calls = []; const local = store(); const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport(calls) });
  const signedIn = await adapter.signIn({ email: user.email, password: 'test-password' });
  assert.equal(adapter.kind, 'real'); assert.equal(adapter.network, 'local-test'); assert.equal(signedIn.profile.name, '林小安');
  assert.deepEqual(signedIn.registrations[0], { id: '9', offering: { id: '1', title: '祈福', slug: 'prayer', account_action: 'event', price_cents: 1200, currency: 'TWD' }, registrantName: '', registrantScope: 'self', dependentId: null, quantity: 1, totalAmountCents: 1200, state: 'pending', lifecycle: 'pending', paymentState: 'unpaid', readOnly: false });
  await adapter.signUp({ email: user.email, password: 'test-password' });
  await adapter.recoverPassword({ email: user.email }); await adapter.resetPassword({ token: 'local-reset', password: 'test-password', password_confirmation: 'test-password' });
  await adapter.refresh(); assert.equal(adapter.snapshot().profile.email, user.email);
  await adapter.updateProfile({ name: '新名字' }); await adapter.addPassword({ password: 'new-password', password_confirmation: 'new-password' });
  await adapter.listDependents(); await adapter.showDependent(4); await adapter.createDependent({ name: '新家屬', relationship: '子女' }); await adapter.updateDependent(4, { name: '家屬', relationship: '家人' }); await adapter.deleteDependent(5);
  await adapter.listRegistrations(); await adapter.showRegistration(9); await adapter.newRegistration({ offering: 'prayer' }); await adapter.createRegistration({ offering: 'prayer', registrantName: '林小安' }); await adapter.editRegistration(9); await adapter.updateRegistration(9, { registrantName: '林小安' });
  await adapter.events(); await adapter.services(); await adapter.galleries(); await adapter.gallery(1); await adapter.certificates(); await adapter.submitAssistance({ message: 'help' }); await adapter.contactTemple({ subject: 'hello', message: 'help' }); await adapter.preferences(); await adapter.updatePreferences({ locale: 'zh-TW', mobile_theme_id: 'default' }); await adapter.privacy(); await adapter.requestPrivacy({ kind: 'export' });
  assert.ok(calls.every(call => call.url.includes('temple_slug=fixture-temple')));
  assert.ok(calls.some(call => call.headers.Authorization === 'Bearer access-1' || call.headers.Authorization === 'Bearer access-2'));
  const profile = calls.find(call => call.url.includes('/profile?') && call.method === 'PATCH');
  assert.deepEqual(JSON.parse(profile.body), { profile: { native_name: '新名字' } });
  assert.equal(calls.some(call => /admin|oauth|checkout|provider/i.test(call.url)), false);
  assert.equal(JSON.stringify(signedIn.registrations[0]).match(/provider|checkout|payment_reference/i), null);
  await adapter.logout(); assert.equal(local.values.size, 0);
});

test('real session expiry, replay, revocation, closure and tenant cleanup clear the scoped state without dummy fallback', async () => {
  for (const code of ['session_invalid', 'session_replayed', 'session_revoked', 'account_closed']) {
    const local = store(); const initial = createRealAdapter({ config, store: local, transport: fixtureTransport([]) });
    await initial.signIn({ email: user.email, password: 'test-password' });
    const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport([], { '/bootstrap': response({ code }, 401) }) });
    await assert.rejects(adapter.restoreSession(), { code });
    assert.equal(local.values.size, 0, code);
  }
  const local = store(); const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport([]) });
  await adapter.signIn({ email: user.email, password: 'test-password' });
  assert.ok(local.values.has(sessionKey({ environment: 'test', tenantId: 'fixture-temple' })));
  await adapter.clearTenantState(); assert.equal(local.values.size, 0);
  await adapter.signIn({ email: user.email, password: 'test-password' }); await adapter.closeAccount(); assert.equal(local.values.size, 0);
});

test('real transport errors are surfaced and never return fixture data', async () => {
  const adapter = createRealAdapter({ config, store: store(), transport: fixtureTransport([], { '/login': response({ code: 'invalid_credentials' }, 401) }) });
  await assert.rejects(adapter.signIn({ email: user.email, password: 'bad' }), { code: 'invalid_credentials' });
  assert.equal(adapter.snapshot().profile.email, '');
});

test('real OAuth adapter sends only the accepted Rails native start and exchange envelopes', async () => {
  const calls = []; const local = store(); const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport(calls) });
  const started = await adapter.startOAuth({ provider: 'google', pkceChallenge: 'c'.repeat(43), pkceMethod: 'S256' });
  assert.deepEqual(started, { authorization_url: 'https://central.example.test/authorize', redirect_uri: 'templemate://oauth/complete', transaction_token: 'opaque-native-transaction', provider: 'google', expires_in: 300 });
  const exchanged = await adapter.exchangeOAuth({ code: 'return-code', transactionToken: 'opaque-native-transaction', pkceVerifier: 'v'.repeat(64) });
  assert.equal(exchanged.oauth.provider, 'google'); assert.equal(exchanged.snapshot.profile.email, user.email);
  const start = calls.find(call => call.url.includes('/oauth/start?'));
  const exchange = calls.find(call => call.url.includes('/oauth/exchange?'));
  assert.deepEqual(JSON.parse(start.body), { oauth: { provider: 'google', pkce_challenge: 'c'.repeat(43), pkce_method: 'S256' } });
  assert.deepEqual(JSON.parse(exchange.body), { oauth: { code: 'return-code', transaction_token: 'opaque-native-transaction', pkce_verifier: 'v'.repeat(64) }, device: { device_id: 'local-test-client', platform: 'expo' } });
  assert.equal(calls.filter(call => /google|apple|sourcegrid/i.test(call.url)).length, 0);
  assert.ok(local.values.has(sessionKey({ environment: 'test', tenantId: 'fixture-temple' })));
});

test('real OAuth session cleanup removes an exchange-applied session and every scoped record', async () => {
  const calls = []; const local = store(); const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport(calls) });
  await adapter.exchangeOAuth({ code: 'return-code', transactionToken: 'opaque-native-transaction', pkceVerifier: 'v'.repeat(64) });
  await adapter.oauthStorage.savePending({ provider: 'google' });
  assert.ok(local.values.size > 0);
  await adapter.clearOAuthSession();
  assert.equal(local.values.size, 0);
  assert.equal(adapter.snapshot().profile.email, '');
});

test('malformed or provider-mismatched real exchange envelopes leave no retained session', async () => {
  for (const oauth of [
    { provider: 'apple', profile_required: false },
    { provider: 'google' }
  ]) {
    const calls = []; const local = store();
    const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport(calls, {}, { '/oauth/exchange': response({ user, session, oauth }) }) });
    const controller = createOAuthController({
      adapter,
      expectedReturnUrl: 'templemate://oauth/complete',
      createPkce: async () => ({ verifier: 'v'.repeat(64), challenge: 'c'.repeat(43), method: 'S256' }),
      openBrowser: async () => ({ type: 'success', url: 'templemate://oauth/complete?code=return-code' })
    });
    assert.equal((await controller.begin('google')).phase, 'failed');
    assert.equal(local.values.size, 0);
  }
});

test('real startup restoration loads every accepted collection and registration forms use the Rails identifiers', async () => {
  const calls = []; const local = store();
  const adapter = createRealAdapter({ config, store: local, transport: fixtureTransport(calls) });
  await adapter.signIn({ email: user.email, password: 'test-password' });
  const restored = createRealAdapter({ config, store: local, transport: fixtureTransport(calls) });
  const bootstrap = await restored.restoreSession();
  assert.equal(bootstrap.profile.email, user.email);
  const loaded = await restored.loadCollections();
  assert.deepEqual(loaded.dependents, [{ id: '4', dependentId: '4', name: '家屬', relationship: '家人' }]);
  for (const path of ['/dependents', '/registrations', '/events', '/services', '/galleries', '/certificates']) assert.ok(calls.some(call => call.url.includes(`${path}?`)), path);
  await restored.newRegistration({ offering: 'prayer', accountAction: 'event' });
  await restored.createRegistration({ offering: 'prayer', accountAction: 'event', registration: { quantity: 1, contact_name: '林小安' } });
  await restored.updateRegistration(9, { registration: { contact_name: '新名字' } });
  const create = calls.find(call => call.method === 'POST' && call.url.includes('/registrations?'));
  assert.deepEqual(JSON.parse(create.body), { offering: 'prayer', account_action: 'event', registration: { quantity: 1, contact_name: '林小安' } });
  const update = calls.find(call => call.method === 'PATCH' && call.url.includes('/registrations/9?'));
  assert.deepEqual(JSON.parse(update.body), { registration: { contact_name: '新名字' } });
});
