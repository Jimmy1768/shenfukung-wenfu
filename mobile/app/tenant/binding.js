// The temple a device is bound to. Everything fixture-shaped that used to live
// here -- fixture tenants, link parsing against example.test origins, the
// switch-temple dance -- went with the dummy client. A real device binds by
// scanning the temple's QR code, and that is the only way it binds.
const productionConnectionPath = '/connect/templemate/v1';

const initialBinding = () => ({ state: 'unbound', tenant: null, error: null });
const activePresentationTenant = binding => binding?.tenant || null;

const parseProductionConnectionLink = (value, origin) => {
  try {
    const url = new URL(value);
    if (url.origin !== origin || url.protocol !== 'https:' || url.pathname !== productionConnectionPath || url.username || url.password || url.hash) return { ok: false, reason: 'invalid_connection_link' };
    const keys = [...url.searchParams.keys()];
    if (keys.some(key => key !== 'v') || (url.search && (keys.length !== 1 || url.searchParams.get('v') !== '1'))) return { ok: false, reason: 'invalid_connection_link' };
    return { ok: true, origin: url.origin };
  } catch (_) { return { ok: false, reason: 'invalid_connection_link' }; }
};

module.exports = { productionConnectionPath, initialBinding, activePresentationTenant, parseProductionConnectionLink };
