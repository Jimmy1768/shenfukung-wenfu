const { tenant } = require('../dummy/fixtures');

const TRUSTED_ORIGINS = Object.freeze([{ origin: tenant.origin, tenantId: tenant.id }]);
const path = tenant.connectionPath;
const parseConnectionLink = value => {
  try {
    const url = new URL(value);
    if (url.protocol !== 'https:' || url.pathname !== path) return { ok: false, reason: 'invalid_connection_link' };
    const trust = TRUSTED_ORIGINS.find(item => item.origin === url.origin);
    if (!trust) return { ok: false, reason: 'untrusted_origin' };
    return { ok: true, origin: url.origin, tenantId: trust.tenantId, token: url.searchParams.get('token') || 'fixture-token' };
  } catch (_) { return { ok: false, reason: 'invalid_connection_link' }; }
};
const initialBinding = () => ({ state: 'unbound', tenant: null, error: null });
const bindFixture = link => {
  const parsed = parseConnectionLink(link);
  return parsed.ok ? { state: 'bound', tenant, error: null } : { state: 'binding_failed', tenant: null, error: parsed.reason };
};
const beginSwitch = binding => ({ state: 'switching', tenant: binding.tenant, error: null });
const clearPriorTenant = () => ({ session: null, cache: null, pending: null });
module.exports = { TRUSTED_ORIGINS, parseConnectionLink, initialBinding, bindFixture, beginSwitch, clearPriorTenant };
