const test = require('node:test');
const assert = require('node:assert/strict');
const { activePresentationTenant, initialBinding, parseProductionConnectionLink } = require('../app/tenant/binding');
const { storageKey, storageScope } = require('../app/core/storage_scope');
const { scanCameraPayload } = require('../app/tenant/scanner');
const { createTrustedBindingStorage, trustedBindingKey } = require('../app/tenant/storage');

const origin = 'https://shengfukung.com.tw';
const config = { mode: 'real', environment: 'testflight', apiBaseUrl: origin, tenantSlug: 'shengfukung-wenfu' };
const templeTransport = async () => ({ ok: true, body: { temple: { slug: config.tenantSlug, name: '聖福宮' } } });

test('a connection link is accepted only in its exact production form', () => {
  assert.equal(parseProductionConnectionLink(`${origin}/connect/templemate/v1?v=1`, origin).ok, true);
  assert.equal(parseProductionConnectionLink(`${origin}/connect/templemate/v1`, origin).ok, true);
  assert.equal(parseProductionConnectionLink(`${origin}/connect/templemate/v1?token=x`, origin).ok, false);
  assert.equal(parseProductionConnectionLink(`http://shengfukung.com.tw/connect/templemate/v1`, origin).ok, false);
  assert.equal(parseProductionConnectionLink('https://other.example.test/connect/templemate/v1', origin).ok, false);
});

test('binding state is unbound until a scan produces one', () => {
  assert.equal(initialBinding().state, 'unbound');
  assert.equal(activePresentationTenant(initialBinding()), null);
  assert.deepEqual(activePresentationTenant({ tenant: { id: 'x', name: 'y' } }), { id: 'x', name: 'y' });
  const scope = storageScope({ environment: 'testflight', tenantId: config.tenantSlug });
  assert.equal(storageKey(scope, 'session'), `templemate.testflight.${config.tenantSlug}.session`);
  assert.notEqual(storageKey(scope, 'session'), storageKey(storageScope({ environment: 'development', tenantId: config.tenantSlug }), 'session'));
});

test('a scan binds only when the server confirms the configured temple', async () => {
  assert.deepEqual(
    await scanCameraPayload({ payload: `${origin}/connect/templemate/v1?v=1`, config, transport: templeTransport }),
    { state: 'bound', tenant: { id: config.tenantSlug, name: '聖福宮' }, error: null, source: 'qr' }
  );

  const wrongOrigin = await scanCameraPayload({ payload: 'https://other.example.test/connect/templemate/v1', config, transport: templeTransport });
  assert.equal(wrongOrigin.state, 'binding_failed');

  // The QR code's claim about which temple it is never wins; the server does.
  const wrongTemple = await scanCameraPayload({ payload: `${origin}/connect/templemate/v1`, config, transport: async () => ({ ok: true, body: { temple: { slug: 'somewhere-else', name: 'Other' } } }) });
  assert.equal(wrongTemple.state, 'binding_failed');
  assert.equal(wrongTemple.error, 'temple_validation_failed');
});

test('release bindings persist only server-derived trusted data in the exact environment and tenant scope', async () => {
  const values = new Map();
  const store = { getItem: async key => values.get(key) || null, setItem: async (key, value) => values.set(key, value), deleteItem: async key => values.delete(key) };
  const bindings = createTrustedBindingStorage({ store, config });
  const binding = { state: 'bound', tenant: { id: config.tenantSlug, name: '聖福宮' }, error: null, source: 'qr' };

  await bindings.save(binding);
  assert.deepEqual(await bindings.load(), binding);

  const key = trustedBindingKey(config);
  assert.equal(key, 'templemate.testflight.shengfukung-wenfu.trusted-binding');
  assert.equal(values.get(key).includes('connect/templemate'), false, 'the link itself is never stored');

  values.set(key, JSON.stringify({ ...binding, tenant: { id: 'other-temple', name: 'Other' } }));
  assert.equal(await bindings.load(), null, 'a binding naming another temple is discarded');
  assert.equal(values.has(key), false);

  await assert.rejects(bindings.save({ ...binding, source: 'link' }), 'only a QR scan may bind');

  // clear() is the only thing that forgets a temple, and it is reached solely
  // from the explicit Unbind control in Settings.
  await bindings.save(binding);
  await bindings.clear();
  assert.equal(await bindings.load(), null);
});
