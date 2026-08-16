const test = require('node:test');
const assert = require('node:assert/strict');
const { alternateTenant, tenant } = require('../app/dummy/fixtures');
const { activePresentationTenant, bindFixture, clearPriorTenant, confirmSwitch, fixtureConnectionLink, initialBinding, parseConnectionLink, parseProductionConnectionLink, requestSwitch, scanFixture } = require('../app/tenant/binding');
const { storageKey, storageScope } = require('../app/core/storage_scope');
const { createFixtureQrScanner, scanCameraPayload } = require('../app/tenant/scanner');
const { createTrustedBindingStorage, trustedBindingKey } = require('../app/tenant/storage');

test('tenant parser accepts only deterministic trusted fixture links', () => {
  const link = `${tenant.origin}${tenant.connectionPath}?token=fixture-token`;
  assert.equal(parseConnectionLink(link).ok, true);
  assert.deepEqual(parseConnectionLink('https://other.example.test/connect/templemate'), { ok: false, reason: 'untrusted_origin' });
  assert.deepEqual(parseConnectionLink('http://temple.example.test/connect/templemate'), { ok: false, reason: 'invalid_connection_link' });
});

test('binding state and tenant-scoped cleanup are explicit', () => {
  const initial = initialBinding();
  assert.equal(initial.state, 'unbound');
  const bound = bindFixture(`${tenant.origin}${tenant.connectionPath}`);
  assert.equal(bound.state, 'bound');
  const switching = requestSwitch(bound, fixtureConnectionLink(alternateTenant));
  assert.equal(switching.state, 'switching');
  assert.equal(switching.candidate.id, alternateTenant.id);
  assert.deepEqual(confirmSwitch(switching, clearPriorTenant(bound.tenant)), { state: 'bound', tenant: alternateTenant, error: null, source: 'switch' });
  assert.equal(confirmSwitch(switching, null).error, 'prior_tenant_not_cleared');
  assert.equal(scanFixture(fixtureConnectionLink(tenant)).source, 'qr');
  const scope = storageScope({ environment: 'development', tenantId: tenant.id });
  assert.equal(storageKey(scope, 'session'), `templemate.development.${tenant.id}.session`);
  assert.notEqual(storageKey(scope, 'session'), storageKey(storageScope({ environment: 'test', tenantId: tenant.id }), 'session'));
  assert.equal(storageKey(storageScope({ environment: 'testflight', tenantId: tenant.id }), 'session'), `templemate.testflight.${tenant.id}.session`);
});

test('active presentation retains only the prior bound tenant until confirmation', () => {
  const bound = bindFixture(fixtureConnectionLink(tenant));
  const switching = requestSwitch(bound, fixtureConnectionLink(alternateTenant));
  const retainedFailure = confirmSwitch(switching, null);
  assert.equal(activePresentationTenant(bound), tenant);
  assert.equal(activePresentationTenant(switching), tenant);
  assert.equal(activePresentationTenant(retainedFailure), tenant);
  assert.equal(activePresentationTenant(initialBinding()), null);
  assert.equal(activePresentationTenant(bindFixture('https://other.example.test/connect/templemate')), null);
  assert.notEqual(activePresentationTenant(switching), alternateTenant);
  assert.deepEqual(confirmSwitch(switching, clearPriorTenant(bound.tenant)), { state: 'bound', tenant: alternateTenant, error: null, source: 'switch' });
});

test('QR scanner interface receives deterministic fixture payloads without a network adapter', async () => {
  const scanner = createFixtureQrScanner(fixtureConnectionLink(tenant));
  const result = await scanner.scanConnection();
  assert.equal(scanner.kind, 'native_qr_interface');
  assert.equal(result.state, 'bound');
  assert.equal(result.source, 'qr');
});

test('camera payload binding keeps fixtures and validates only the exact production temple contract', async () => {
  const dummy = await scanCameraPayload({ mode: 'dummy', payload: fixtureConnectionLink(tenant) });
  assert.equal(dummy.state, 'bound');
  assert.equal(dummy.source, 'qr');
  assert.equal(parseProductionConnectionLink('https://shengfukung.com.tw/connect/templemate/v1?v=1', 'https://shengfukung.com.tw').ok, true);
  assert.equal(parseProductionConnectionLink('https://shengfukung.com.tw/connect/templemate/v1?token=x', 'https://shengfukung.com.tw').ok, false);
  const real = await scanCameraPayload({ mode: 'real', payload: 'https://shengfukung.com.tw/connect/templemate/v1?v=1', config: { apiBaseUrl: 'https://shengfukung.com.tw', tenantSlug: 'shengfukung-wenfu' }, transport: async () => ({ ok: true, body: { temple: { slug: 'shengfukung-wenfu', name: '聖福宮' } } }) });
  assert.deepEqual(real, { state: 'bound', tenant: { id: 'shengfukung-wenfu', name: '聖福宮' }, error: null, source: 'qr' });
});

test('release bindings persist only server-derived trusted data in the exact environment and tenant scope', async () => {
  const values = new Map();
  const store = { getItem: async key => values.get(key) || null, setItem: async (key, value) => values.set(key, value), deleteItem: async key => values.delete(key) };
  const config = { mode: 'real', environment: 'testflight', tenantSlug: 'shengfukung-wenfu' };
  const bindings = createTrustedBindingStorage({ store, config });
  const binding = { state: 'bound', tenant: { id: 'shengfukung-wenfu', name: '聖福宮' }, error: null, source: 'qr' };
  await bindings.save(binding);
  assert.deepEqual(await bindings.load(), binding);
  const key = trustedBindingKey(config);
  assert.equal(key, 'templemate.testflight.shengfukung-wenfu.trusted-binding');
  assert.equal(values.get(key).includes('connect/templemate'), false);
  values.set(key, JSON.stringify({ ...binding, tenant: { id: 'other-temple', name: 'Other' } }));
  assert.equal(await bindings.load(), null);
  assert.equal(values.has(key), false);
  await assert.rejects(bindings.save({ ...binding, source: 'link' }));
  await bindings.save(binding); await bindings.clear();
  assert.equal(await bindings.load(), null);
});
