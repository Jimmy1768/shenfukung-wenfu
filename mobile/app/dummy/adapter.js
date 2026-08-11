const { createDummyRepository } = require('./repository');

function createDummyAdapter(repository = createDummyRepository()) {
  return {
    kind: 'dummy',
    network: 'disabled',
    mode: 'dummy',
    signIn: credentials => Promise.resolve().then(() => repository.signIn(credentials)),
    signUp: input => Promise.resolve().then(() => repository.signUp(input)),
    recoverPassword: input => Promise.resolve().then(() => repository.recoverPassword(input)),
    snapshot: () => repository.snapshot(),
    reset: () => repository.reset(),
    async restoreSession() { return null; },
    async clearTenantState() { return repository.snapshot(); },
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
    closeAccount: input => Promise.resolve().then(() => repository.closeAccount(input)),
    preferences: async () => repository.snapshot().preferences || {},
    updatePreferences: input => Promise.resolve().then(() => repository.updatePreferences(input))
  };
}
module.exports = { createDummyAdapter };
