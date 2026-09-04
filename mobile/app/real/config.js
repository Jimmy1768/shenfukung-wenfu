const { nativeOAuthReturnUrl } = require('../oauth/config');
const RELEASE_ENVIRONMENTS = new Set(['testflight', 'production']);
const PUBLIC_ORIGIN = 'https://shengfukung.com.tw';
const PUBLIC_TENANT = 'shengfukung-wenfu';
const safeUrl = value => { try { return new URL(String(value)); } catch (_) { return null; } };

function resolveClientConfig(extra = {}) {
  const environment = String(extra.clientEnvironment || 'development').toLowerCase();
  const release = RELEASE_ENVIRONMENTS.has(environment);
  // One mode. The dummy client is gone; every build talks to a real server,
  // a local one in development and the public origin in a release lane.
  const mode = 'real';
  const apiBaseUrl = String(extra.apiBaseUrl || extra.localApiBaseUrl || '').replace(/\/$/, '');
  const tenantSlug = String(extra.tenantSlug || extra.localTenantSlug || '').trim();
  if (mode === 'real' && (!apiBaseUrl || !tenantSlug)) {
    const error = new Error('Real mode requires an explicit API origin and tenant configuration.');
    error.code = 'REAL_CONFIG_REQUIRED';
    throw error;
  }
  if (mode === 'real') {
    const url = safeUrl(apiBaseUrl);
    const host = url?.hostname?.toLowerCase();
    const localHost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || host?.endsWith('.test');
    const publicExact = url?.origin === PUBLIC_ORIGIN && tenantSlug === PUBLIC_TENANT;
    if (!url || !['http:', 'https:'].includes(url.protocol) || url.username || url.password || url.hash || url.pathname !== '/' || url.search || !(publicExact || (!release && localHost))) {
      const error = new Error('Real mode requires an exact trusted API origin.');
      error.code = 'TRUSTED_API_REQUIRED';
      throw error;
    }
  }
  const oauthReturnUrl = String(extra.nativeOAuthReturnUrl || nativeOAuthReturnUrl);
  if (oauthReturnUrl !== nativeOAuthReturnUrl) {
    const error = new Error('Native OAuth return URL must use the configured templemate scheme.');
    error.code = 'NATIVE_OAUTH_RETURN_REQUIRED';
    throw error;
  }
  return { mode, apiBaseUrl, tenantSlug, environment, oauthReturnUrl, updateChannel: String(extra.easUpdateChannel || environment) };
}

const localTenantBinding = config => ({ state: 'bound', tenant: { id: config.tenantSlug, name: config.tenantSlug }, error: null, source: 'local-test' });

const isReleaseConfig = config => RELEASE_ENVIRONMENTS.has(config?.environment);
module.exports = { PUBLIC_ORIGIN, PUBLIC_TENANT, RELEASE_ENVIRONMENTS, resolveClientConfig, localTenantBinding, isReleaseConfig };
