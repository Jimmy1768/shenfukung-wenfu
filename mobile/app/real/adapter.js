const { storageScope } = require('../core/storage_scope');
const { createScopedStorage } = require('./storage');
const { nativeError, snapshotFromBootstrap, mapDependent, mapRegistration, nameFor, collectionFrom } = require('./response');

const nativePath = '/api/v1/account/native';
const query = (path, tenantSlug) => `${path}${path.includes('?') ? '&' : '?'}temple_slug=${encodeURIComponent(tenantSlug)}`;
const jsonHeaders = token => ({ Accept: 'application/json', 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) });
const registrationFields = input => Object.fromEntries(Object.entries(input || {}).filter(([key, value]) => ['quantity', 'registrant_scope', 'dependent_id', 'contact_name', 'contact_phone', 'contact_email', 'household_notes', 'arrival_window', 'ceremony_notes'].includes(key) && value !== undefined && value !== null && value !== ''));

function createRealAdapter({ config, store, transport, bindingStorage, device = { device_id: 'local-test-client', platform: 'expo' } }) {
  if (!config?.apiBaseUrl || !config?.tenantSlug) throw Object.assign(new Error('Real mode requires explicit trusted configuration.'), { code: 'REAL_CONFIG_REQUIRED' });
  if (typeof transport !== 'function') throw new Error('A trusted transport is required for real mode.');
  const scoped = createScopedStorage(store, storageScope({ environment: config.environment, tenantId: config.tenantSlug }));
  let session = null; let state = snapshotFromBootstrap();
  const clearRetainedState = async () => { await scoped.clearAll(); if (typeof bindingStorage?.clear === 'function') await bindingStorage.clear(); };
  const request = async (method, path, body, authenticated = true) => {
    const result = await transport({ method, url: `${config.apiBaseUrl}${query(`${nativePath}${path}`, config.tenantSlug)}`, headers: jsonHeaders(authenticated ? session?.access_token : null), body: body === undefined ? undefined : JSON.stringify(body) });
    const payload = result?.body || {};
    if (!result?.ok) { const error = nativeError(result?.status || 0, payload); if (['session_invalid', 'session_replayed', 'session_revoked', 'account_closed'].includes(error.code)) await clearRetainedState(); throw error; }
    return payload;
  };
  const applySession = async next => { session = next; await scoped.saveSession(next); };
  const loadBootstrap = async () => { const payload = await request('GET', '/bootstrap'); state = { ...state, ...snapshotFromBootstrap(payload) }; return state; };
  const authenticate = async (path, body) => { const payload = await request('POST', path, { ...body, device }, false); await applySession(payload.session); state = { ...state, ...snapshotFromBootstrap(payload) }; return loadBootstrap(); };
  const updateState = (key, value) => { state = { ...state, [key]: value }; return state; };
  return {
    kind: 'real', network: config.environment === 'test' ? 'local-test' : config.environment, mode: 'real', snapshot: () => state,
    oauthStorage: { loadPending: () => scoped.loadPending(), savePending: pending => scoped.savePending(pending), clearPending: () => scoped.clearPending() },
    async startOAuth({ provider, pkceChallenge, pkceMethod }) {
      const payload = await request('POST', '/oauth/start', { oauth: { provider, pkce_challenge: pkceChallenge, pkce_method: pkceMethod } }, false);
      return payload.oauth;
    },
    async exchangeOAuth({ code, transactionToken, pkceVerifier }) {
      const payload = await request('POST', '/oauth/exchange', { oauth: { code, transaction_token: transactionToken, pkce_verifier: pkceVerifier }, device }, false);
      await applySession(payload.session);
      state = { ...state, ...snapshotFromBootstrap(payload) };
      await loadBootstrap();
      return { snapshot: state, oauth: payload.oauth };
    },
    async clearOAuthSession() { session = null; state = snapshotFromBootstrap(); await clearRetainedState(); },
    signUp: input => authenticate('/signup', { signup: { email: input.email, password: input.password, password_confirmation: input.passwordConfirmation || input.password } }),
    signIn: input => authenticate('/login', { session: input }),
    recoverPassword: input => request('POST', '/password/recovery', input, false),
    resetPassword: input => authenticate('/password/reset', input),
    async restoreSession() { session = await scoped.loadSession(); if (!session) return null; try { return await loadBootstrap(); } catch (error) { await clearRetainedState(); throw error; } },
    async refresh() { if (!session?.refresh_token) return null; const payload = await request('POST', '/refresh', { refresh_token: session.refresh_token }, false); await applySession(payload.session); return session; },
    async logout() { try { if (session) await request('DELETE', '/logout', { refresh_token: session.refresh_token }); } finally { session = null; await clearRetainedState(); } },
    async clearTenantState() { session = null; state = snapshotFromBootstrap(); await clearRetainedState(); },
    async updateProfile(input) { const profile = input.name ? { native_name: input.name } : input; const payload = await request('PATCH', '/profile', { profile }); state.profile = { id: String(payload.user.id), email: payload.user.email, name: nameFor(payload.user), user: payload.user }; return state; },
    addPassword: input => request('POST', '/profile/password', { password: input }),
    async listDependents() { const payload = await request('GET', '/dependents'); return updateState('dependents', payload.dependents.map(mapDependent)); },
    showDependent: id => request('GET', `/dependents/${id}`),
    async createDependent(input) { const dependent = input.name ? { native_name: input.name, relationship_label: input.relationship } : input; const payload = await request('POST', '/dependents', { dependent }); return updateState('dependents', [...state.dependents, mapDependent(payload.dependent)]); },
    async updateDependent(id, input) { const dependent = input.name ? { native_name: input.name, relationship_label: input.relationship } : input; const payload = await request('PATCH', `/dependents/${id}`, { dependent }); return updateState('dependents', state.dependents.map(item => item.id === String(id) ? mapDependent(payload.dependent) : item)); },
    async deleteDependent(id) { await request('DELETE', `/dependents/${id}`); return updateState('dependents', state.dependents.filter(item => item.id !== String(id))); },
    async listRegistrations() { const payload = await request('GET', '/registrations'); return updateState('registrations', payload.registrations.map(mapRegistration)); },
    showRegistration: id => request('GET', `/registrations/${id}`), newRegistration: input => request('GET', `/registrations/new?offering=${encodeURIComponent(input.offering)}&account_action=${encodeURIComponent(input.accountAction || '')}`),
    async createRegistration(input) { const payload = await request('POST', '/registrations', { offering: input.offering, account_action: input.accountAction, registration: registrationFields(input.registration) }); return updateState('registrations', [mapRegistration(payload.registration), ...state.registrations]); },
    editRegistration: id => request('GET', `/registrations/${id}/edit`),
    async updateRegistration(id, input) { const payload = await request('PATCH', `/registrations/${id}`, { registration: registrationFields(input.registration) }); return updateState('registrations', state.registrations.map(item => item.id === String(id) ? mapRegistration(payload.registration) : item)); },
    async events() { const payload = await request('GET', '/events'); state = { ...state, events: collectionFrom(payload, 'events'), gatherings: collectionFrom(payload, 'gatherings') }; return state; },
    async services() { const payload = await request('GET', '/services'); return updateState('services', collectionFrom(payload, 'services')); },
    async galleries() { const payload = await request('GET', '/galleries'); return updateState('gallery', collectionFrom(payload, 'galleries')); },
    gallery: id => request('GET', `/galleries/${id}`),
    async certificates() { const payload = await request('GET', '/certificates'); return updateState('certificates', collectionFrom(payload, 'certificates')); },
    async loadCollections() {
      await Promise.all([this.listDependents(), this.listRegistrations(), this.events(), this.services(), this.galleries(), this.certificates()]);
      return state;
    },
    async submitAssistance(input) {
      const payload = await request('POST', '/assistance', { assistance: { channel: 'profile', message: input.message } });
      return { outcome: payload.duplicate === true ? 'duplicate' : 'created' };
    },
    preferences: () => request('GET', '/preferences'),
    async updatePreferences(input) { const payload = await request('PATCH', '/preferences', { preferences: input }); return updateState('preferences', payload.preferences || input); },
    privacy: () => request('GET', '/privacy'),
    requestPrivacy: input => request('POST', `/privacy/${input.kind === 'export' ? 'data_export' : 'data_deletion'}`),
    async closeAccount() { await request('POST', '/privacy/close'); session = null; await clearRetainedState(); }
  };
}
module.exports = { createRealAdapter };
