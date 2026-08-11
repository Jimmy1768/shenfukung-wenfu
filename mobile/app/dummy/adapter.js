const { createDummyRepository } = require('./repository');
const { nativeOAuthReturnUrl, oauthJourneys } = require('./fixtures');

function createDummyAdapter(repository = createDummyRepository(), { oauthJourney = 'success' } = {}) {
  let journey = oauthJourney;
  let pending = null;
  const oauthStorage = {
    savePending: async record => { pending = { ...record }; }, loadPending: async () => pending && { ...pending }, clearPending: async () => { pending = null; }
  };
  const currentJourney = () => oauthJourneys[journey] || oauthJourneys.failure;
  return {
    kind: 'dummy',
    network: 'disabled',
    mode: 'dummy',
    signIn: credentials => Promise.resolve().then(() => repository.signIn(credentials)),
    signUp: input => Promise.resolve().then(() => repository.signUp(input)),
    recoverPassword: input => Promise.resolve().then(() => repository.recoverPassword(input)),
    snapshot: () => repository.snapshot(),
    reset: () => { pending = null; journey = 'success'; return repository.reset(); },
    async restoreSession() { return null; },
    async clearTenantState() { pending = null; return repository.snapshot(); },
    async listDependents() { return repository.snapshot(); },
    async listRegistrations() { return repository.snapshot(); },
    async loadCollections() { return repository.snapshot(); },
    updateProfile: input => Promise.resolve().then(() => repository.updateProfile(input)),
    createDependent: input => Promise.resolve().then(() => repository.createDependent(input)),
    updateDependent: (id, input) => Promise.resolve().then(() => repository.updateDependent(id, input)),
    deleteDependent: id => Promise.resolve().then(() => repository.deleteDependent(id)),
    createRegistration: input => Promise.resolve().then(() => repository.createRegistration(input)),
    updateRegistration: (id, input) => Promise.resolve().then(() => repository.updateRegistration(id, input)),
    submitAssistance: input => Promise.resolve().then(() => repository.submitAssistance(input)),
    contactTemple: input => Promise.resolve().then(() => repository.contactTemple(input)),
    requestPrivacy: input => Promise.resolve().then(() => repository.requestPrivacy(input)),
    closeAccount: input => Promise.resolve().then(() => { pending = null; return repository.closeAccount(input); }),
    preferences: async () => repository.snapshot().preferences || {},
    updatePreferences: input => Promise.resolve().then(() => repository.updatePreferences(input)),
    oauthStorage,
    setOAuthJourney: value => { if (!oauthJourneys[value]) throw new Error('Unknown dummy OAuth journey.'); journey = value; },
    getOAuthJourney: () => journey,
    async startOAuth({ provider, pkceChallenge, pkceMethod }) {
      if (!['google', 'apple'].includes(provider) || !pkceChallenge || pkceMethod !== 'S256') throw Object.assign(new Error('Invalid dummy OAuth start.'), { code: 'invalid_pkce' });
      return { authorization_url: `templemate-fixture://auth/${provider}/${journey}`, redirect_uri: nativeOAuthReturnUrl, transaction_token: `fixture-${provider}-${journey}`, provider, expires_in: 120 };
    },
    async openOAuthBrowser(_authorizationUrl, returnUrl) {
      const outcome = currentJourney(); const provider = pending?.provider || 'google';
      if (outcome.type === 'cancel') return { type: 'cancel' };
      if (outcome.type === 'interrupted') return { type: 'interrupted' };
      if (outcome.type === 'denied') return { type: 'success', url: `${returnUrl}?error=access_denied` };
      if (outcome.type === 'failure') return { type: 'success', url: `${returnUrl}?error=fixture_failure` };
      return { type: 'success', url: `${returnUrl}?code=fixture-${provider}-${outcome.type}` };
    },
    async exchangeOAuth({ code, transactionToken }) {
      const outcome = currentJourney();
      const provider = /^fixture-(google|apple)-/.exec(transactionToken || '')?.[1];
      if (!provider || !code.startsWith(`fixture-${provider}-`)) throw Object.assign(new Error('Dummy OAuth grant is invalid.'), { code: 'invalid_oauth_grant' });
      if (outcome.type === 'failure') throw Object.assign(new Error('Dummy OAuth exchange failed.'), { code: 'oauth_exchange_failed' });
      const snapshot = repository.snapshot();
      if (outcome.type === 'profile_required') snapshot.profile.name = '';
      return { snapshot, oauth: { provider, profile_required: outcome.type === 'profile_required' } };
    }
  };
}
module.exports = { createDummyAdapter };
