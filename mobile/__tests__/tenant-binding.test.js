const test = require('node:test');
const assert = require('node:assert/strict');
const { alternateTenant, tenant } = require('../app/dummy/fixtures');
const { activePresentationTenant, bindFixture, clearPriorTenant, confirmSwitch, fixtureConnectionLink, initialBinding, parseConnectionLink, requestSwitch, scanFixture } = require('../app/tenant/binding');
const { storageKey, storageScope } = require('../app/core/storage_scope');
const { createFixtureQrScanner, scanCameraPayload } = require('../app/tenant/scanner');

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

test('camera payload binding is executable only for a deterministic dummy fixture', async () => {
  const dummy = await scanCameraPayload({ mode: 'dummy', payload: fixtureConnectionLink(tenant) });
  assert.equal(dummy.state, 'bound');
  assert.equal(dummy.source, 'qr');
  const real = await scanCameraPayload({ mode: 'real', payload: fixtureConnectionLink(tenant) });
  assert.deepEqual(real, { state: 'binding_failed', tenant: null, error: 'real_camera_binding_deferred', source: 'qr' });
});
