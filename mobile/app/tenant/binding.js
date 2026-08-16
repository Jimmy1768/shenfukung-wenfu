const { tenant, alternateTenant } = require('../dummy/fixtures');

const TRUSTED_ORIGINS = Object.freeze([
  { origin: tenant.origin, tenantId: tenant.id, tenant },
  { origin: alternateTenant.origin, tenantId: alternateTenant.id, tenant: alternateTenant }
]);
const path = tenant.connectionPath;
const productionConnectionPath = '/connect/templemate/v1';
const parseConnectionLink = value => {
  try {
    const url = new URL(value);
    if (url.protocol !== 'https:' || url.pathname !== path) return { ok: false, reason: 'invalid_connection_link' };
    const trust = TRUSTED_ORIGINS.find(item => item.origin === url.origin);
    if (!trust) return { ok: false, reason: 'untrusted_origin' };
    return { ok: true, origin: url.origin, tenantId: trust.tenantId, tenant: trust.tenant, token: url.searchParams.get('token') || 'fixture-token' };
  } catch (_) { return { ok: false, reason: 'invalid_connection_link' }; }
};
const initialBinding = () => ({ state: 'unbound', tenant: null, error: null });
const bindFixture = link => {
  const parsed = parseConnectionLink(link);
  return parsed.ok ? { state: 'bound', tenant: parsed.tenant, error: null, source: 'link' } : { state: 'binding_failed', tenant: null, error: parsed.reason, source: 'link' };
};
const scanFixture = value => {
  const result = bindFixture(value);
  return { ...result, source: 'qr' };
};
const beginSwitch = binding => ({ state: 'switching', tenant: binding.tenant, error: null, source: 'switch', candidate: null });
const requestSwitch = (binding, link) => {
  const parsed = parseConnectionLink(link);
  if (!parsed.ok) return { state: 'binding_failed', tenant: binding.tenant, error: parsed.reason, source: 'switch' };
  return { ...beginSwitch(binding), candidate: parsed.tenant };
};
const clearPriorTenant = prior => ({ session: null, cache: null, pending: null, clearedTenantId: prior?.id || null });
const confirmSwitch = (binding, cleanup) => {
  if (binding.state !== 'switching' || !binding.candidate) return { state: 'binding_failed', tenant: null, error: 'switch_confirmation_required', source: 'switch' };
  if (!cleanup || cleanup.clearedTenantId !== binding.tenant?.id) return { state: 'binding_failed', tenant: binding.tenant, error: 'prior_tenant_not_cleared', source: 'switch' };
  return { state: 'bound', tenant: binding.candidate, error: null, source: 'switch' };
};
const activePresentationTenant = binding => binding?.tenant || null;
const fixtureConnectionLink = target => `${target.origin}${target.connectionPath}?token=fixture-token`;
const parseProductionConnectionLink = (value, origin) => {
  try {
    const url = new URL(value);
    if (url.origin !== origin || url.protocol !== 'https:' || url.pathname !== productionConnectionPath || url.username || url.password || url.hash) return { ok: false, reason: 'invalid_connection_link' };
    const keys = [...url.searchParams.keys()];
    if (keys.some(key => key !== 'v') || (url.search && (keys.length !== 1 || url.searchParams.get('v') !== '1'))) return { ok: false, reason: 'invalid_connection_link' };
    return { ok: true, origin: url.origin };
  } catch (_) { return { ok: false, reason: 'invalid_connection_link' }; }
};
module.exports = { TRUSTED_ORIGINS, parseConnectionLink, parseProductionConnectionLink, productionConnectionPath, initialBinding, bindFixture, scanFixture, beginSwitch, requestSwitch, clearPriorTenant, confirmSwitch, activePresentationTenant, fixtureConnectionLink };
