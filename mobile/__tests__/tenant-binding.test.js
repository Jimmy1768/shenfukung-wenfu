const test = require('node:test');
const assert = require('node:assert/strict');
const { tenant } = require('../app/dummy/fixtures');
const { bindFixture, beginSwitch, clearPriorTenant, initialBinding, parseConnectionLink } = require('../app/tenant/binding');
const { storageKey, storageScope } = require('../app/core/storage_scope');

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
  assert.equal(beginSwitch(bound).state, 'switching');
  assert.deepEqual(clearPriorTenant(), { session: null, cache: null, pending: null });
  const scope = storageScope({ environment: 'development', tenantId: tenant.id });
  assert.equal(storageKey(scope, 'session'), `templemate.development.${tenant.id}.session`);
  assert.notEqual(storageKey(scope, 'session'), storageKey(storageScope({ environment: 'test', tenantId: tenant.id }), 'session'));
});
