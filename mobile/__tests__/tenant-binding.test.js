const test = require('node:test');
const assert = require('node:assert/strict');
const { alternateTenant, tenant } = require('../app/dummy/fixtures');
const { bindFixture, clearPriorTenant, confirmSwitch, fixtureConnectionLink, initialBinding, parseConnectionLink, requestSwitch, scanFixture } = require('../app/tenant/binding');
const { storageKey, storageScope } = require('../app/core/storage_scope');
const { createFixtureQrScanner } = require('../app/tenant/scanner');

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
});

test('QR scanner interface receives deterministic fixture payloads without a network adapter', async () => {
  const scanner = createFixtureQrScanner(fixtureConnectionLink(tenant));
  const result = await scanner.scanConnection();
  assert.equal(scanner.kind, 'native_qr_interface');
  assert.equal(result.state, 'bound');
  assert.equal(result.source, 'qr');
});
