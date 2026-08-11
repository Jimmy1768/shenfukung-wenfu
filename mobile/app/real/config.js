const LOCAL_MODES = new Set(['dummy', 'real']);
const { nativeOAuthReturnUrl } = require('../oauth/config');

function resolveClientConfig(extra = {}) {
  const mode = LOCAL_MODES.has(extra.clientMode) ? extra.clientMode : 'dummy';
  const apiBaseUrl = String(extra.localApiBaseUrl || '').replace(/\/$/, '');
  const tenantSlug = String(extra.localTenantSlug || '').trim();
  if (mode === 'real' && (!apiBaseUrl || !tenantSlug)) {
    const error = new Error('Real mode requires explicit localApiBaseUrl and localTenantSlug configuration.');
    error.code = 'REAL_CONFIG_REQUIRED';
    throw error;
  }
  if (mode === 'real') {
    let url;
    try { url = new URL(apiBaseUrl); } catch (_) { url = null; }
    const host = url?.hostname?.toLowerCase();
    const localHost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || host?.endsWith('.test');
    if (!url || !['http:', 'https:'].includes(url.protocol) || !localHost) {
      const error = new Error('Real mode accepts only an explicit localhost, loopback, or .test API origin.');
      error.code = 'LOCAL_API_REQUIRED';
      throw error;
    }
  }
  const oauthReturnUrl = String(extra.nativeOAuthReturnUrl || nativeOAuthReturnUrl);
  if (oauthReturnUrl !== nativeOAuthReturnUrl) {
    const error = new Error('Native OAuth return URL must use the configured templemate scheme.');
    error.code = 'NATIVE_OAUTH_RETURN_REQUIRED';
    throw error;
  }
  return { mode, apiBaseUrl, tenantSlug, environment: String(extra.clientEnvironment || 'development'), oauthReturnUrl };
}

const localTenantBinding = config => ({ state: 'bound', tenant: { id: config.tenantSlug, name: config.tenantSlug }, error: null, source: 'local-test' });

module.exports = { resolveClientConfig, localTenantBinding };
