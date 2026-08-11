const { createDummyRepository } = require('./repository');

function createDummyAdapter(repository = createDummyRepository()) {
  return {
    kind: 'dummy',
    network: 'disabled',
    signIn: credentials => Promise.resolve().then(() => repository.signIn(credentials)),
    snapshot: () => repository.snapshot(),
    reset: () => repository.reset(),
    updateProfile: input => Promise.resolve().then(() => repository.updateProfile(input)),
    createDependent: input => Promise.resolve().then(() => repository.createDependent(input)),
    updateDependent: (id, input) => Promise.resolve().then(() => repository.updateDependent(id, input)),
    deleteDependent: id => Promise.resolve().then(() => repository.deleteDependent(id)),
    createRegistration: input => Promise.resolve().then(() => repository.createRegistration(input)),
    updateRegistration: (id, input) => Promise.resolve().then(() => repository.updateRegistration(id, input))
  };
}
module.exports = { createDummyAdapter };
