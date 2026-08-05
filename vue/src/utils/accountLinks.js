const TENANT_SELECTOR_KEYS = new Set(['temple', 'temple_slug', 'slug', 'tenant', 'tenant_slug']);

function resolveAccountBaseUrl() {
  const explicit = import.meta.env.VITE_ACCOUNT_BASE_URL;
  if (explicit) {
    try {
      return new URL(explicit).origin;
    } catch (error) {
      console.warn('Invalid account base URL', explicit, error);
    }
  }
  if (import.meta.env.DEV) {
    return 'http://localhost:3001';
  }
  if (typeof window !== 'undefined' && window.location?.origin) {
    return window.location.origin;
  }
  return null;
}

function buildAccountUrl(path, params = {}) {
  const base = resolveAccountBaseUrl();
  const search = new URLSearchParams(params);
  const relativeUrl = `${path}${search.size ? `?${search.toString()}` : ''}`;
  return base ? new URL(relativeUrl, base).toString() : relativeUrl;
}

export function buildAccountLoginUrl(extraParams = {}) {
  const params = Object.fromEntries(
    Object.entries(extraParams).filter(([key]) => !TENANT_SELECTOR_KEYS.has(key))
  );
  return buildAccountUrl('/account/login', params);
}

export function buildRegistrationLink(action, offeringSlug) {
  const params = { account_action: action };
  if (offeringSlug) {
    params.offering = offeringSlug;
  }
  return buildAccountLoginUrl(params);
}
