const { scanFixture, parseProductionConnectionLink } = require('./binding');

const createQrScanner = ({ readPayload }) => ({
  kind: 'native_qr_interface',
  async scanConnection() {
    const payload = await readPayload();
    return scanFixture(payload);
  }
});

const createFixtureQrScanner = payload => createQrScanner({ readPayload: () => payload });

const scanCameraPayload = async ({ mode, payload, config, transport }) => {
  if (mode !== 'real') return createFixtureQrScanner(payload).scanConnection();
  const parsed = parseProductionConnectionLink(payload, config?.apiBaseUrl);
  if (!parsed.ok) return { state: 'binding_failed', tenant: null, error: parsed.reason, source: 'qr' };
  try {
    const response = await transport({ method: 'GET', url: `${config.apiBaseUrl}/api/v1/temple`, headers: { Accept: 'application/json' } });
    const temple = response?.body?.temple || response?.body;
    if (!response?.ok || !temple || String(temple.slug || '').trim() !== config.tenantSlug || !String(temple.name || '').trim()) return { state: 'binding_failed', tenant: null, error: 'temple_validation_failed', source: 'qr' };
    return { state: 'bound', tenant: { id: temple.slug, name: temple.name }, error: null, source: 'qr' };
  } catch (_) { return { state: 'binding_failed', tenant: null, error: 'temple_validation_failed', source: 'qr' }; }
};

module.exports = { createQrScanner, createFixtureQrScanner, scanCameraPayload };
