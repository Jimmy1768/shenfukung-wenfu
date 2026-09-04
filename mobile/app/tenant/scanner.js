const { parseProductionConnectionLink } = require('./binding');

// One path. The link must come from the configured origin, and the temple it
// names must be the configured tenant -- checked against the server, not taken
// from the QR code's own claim.
const scanCameraPayload = async ({ payload, config, transport }) => {
  const parsed = parseProductionConnectionLink(payload, config?.apiBaseUrl);
  if (!parsed.ok) return { state: 'binding_failed', tenant: null, error: parsed.reason, source: 'qr' };
  try {
    const response = await transport({ method: 'GET', url: `${config.apiBaseUrl}/api/v1/temple`, headers: { Accept: 'application/json' } });
    const temple = response?.body?.temple || response?.body;
    if (!response?.ok || !temple || String(temple.slug || '').trim() !== config.tenantSlug || !String(temple.name || '').trim()) return { state: 'binding_failed', tenant: null, error: 'temple_validation_failed', source: 'qr' };
    return { state: 'bound', tenant: { id: temple.slug, name: temple.name }, error: null, source: 'qr' };
  } catch (_) { return { state: 'binding_failed', tenant: null, error: 'temple_validation_failed', source: 'qr' }; }
};

module.exports = { scanCameraPayload };
