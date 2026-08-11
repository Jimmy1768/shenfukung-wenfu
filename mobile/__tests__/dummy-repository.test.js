const test = require('node:test');
const assert = require('node:assert/strict');
const { createDummyRepository } = require('../app/dummy/repository');

test('dummy login validates and never needs a network adapter', () => {
  const repository = createDummyRepository();
  assert.throws(() => repository.signIn({ email: '', password: '' }), { field: 'email' });
  assert.equal(repository.signIn({ email: 'member@example.test', password: 'templemate-demo' }).profile.name, '林小安');
});

test('profile, dependent CRUD, registration create/update, and reset are deterministic', () => {
  const repository = createDummyRepository();
  repository.updateProfile({ name: '王小美' });
  let snapshot = repository.createDependent({ name: '王小福', relationship: '子女' });
  assert.equal(snapshot.dependents.at(-1).id, 'dependent-002');
  snapshot = repository.updateDependent('dependent-002', { name: '王小寶', relationship: '家人' });
  assert.equal(snapshot.dependents.at(-1).name, '王小寶');
  snapshot = repository.deleteDependent('dependent-002');
  assert.equal(snapshot.dependents.length, 1);
  snapshot = repository.createRegistration({ offering: '超薦法會', registrantName: '王小美' });
  const id = snapshot.registrations.at(-1).id;
  assert.equal(id, 'registration-002');
  snapshot = repository.updateRegistration(id, { offering: '祈福法會', registrantName: '王小美' });
  assert.equal(snapshot.registrations.at(-1).offering, '祈福法會');
  assert.throws(() => repository.updateRegistration('registration-001', { offering: 'x', registrantName: 'y' }), { field: 'registration' });
  snapshot = repository.reset();
  assert.equal(snapshot.profile.name, '林小安');
  assert.equal(snapshot.dependents.length, 1);
  assert.equal(snapshot.registrations.length, 1);
});
