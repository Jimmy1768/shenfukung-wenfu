const nativeOAuthReturnUrl = 'templemate://oauth/complete';
const publicConfigurationMatrix = Object.freeze({
  development: Object.freeze({ clientMode: 'dummy by default; real only when explicitly selected', apiBaseUrl: 'unknown external local/test value', tenantSlug: 'unknown external local/test value', returnUrl: nativeOAuthReturnUrl, providerRegistration: 'unknown/deferred' }),
  production: Object.freeze({ clientMode: 'real requires later explicit distribution configuration', apiBaseUrl: 'unknown external value', tenantSlug: 'unknown external tenant value', returnUrl: nativeOAuthReturnUrl, providerRegistration: 'unknown/deferred' })
});
module.exports = { nativeOAuthReturnUrl, publicConfigurationMatrix };
