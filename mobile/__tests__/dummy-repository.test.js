const test = require('node:test');
const assert = require('node:assert/strict');
const { createDummyRepository } = require('../app/dummy/repository');
const { preparedRegistration } = require('../app/account/registration_authority');

test('dummy login validates and never needs a network adapter', () => {
  const repository = createDummyRepository();
  assert.throws(() => repository.signIn({ email: '', password: '' }), { field: 'email' });
  assert.equal(repository.signIn({ email: 'member@example.test', password: 'templemate-demo' }).profile.name, '林小安');
});

test('profile, dependent CRUD, offering-authoritative registration create/update, and reset are deterministic', () => {
  const repository = createDummyRepository();
  repository.updateProfile({ name: '王小美' });
  let snapshot = repository.createDependent({ name: '王小福', relationship: '子女' });
  assert.equal(snapshot.dependents.at(-1).id, 'dependent-002');
  snapshot = repository.updateDependent('dependent-002', { name: '王小寶', relationship: '家人' });
  assert.equal(snapshot.dependents.at(-1).name, '王小寶');
  snapshot = repository.deleteDependent('dependent-002');
  assert.equal(snapshot.dependents.length, 1);
  const prepared = repository.newRegistration({ offering: 'online-blessing', accountAction: 'service' });
  assert.equal(prepared.offering.title, '線上祈福服務');
  snapshot = repository.createRegistration({ offering: 'online-blessing', accountAction: 'service', registration: { quantity: 2, registrant_scope: 'self', contact_name: '王小美', price_cents: 1, currency: 'USD' } });
  const id = snapshot.registrations.at(-1).id;
  assert.equal(id, 'registration-002');
  assert.equal(snapshot.registrations.at(-1).offering.title, '線上祈福服務');
  assert.equal(snapshot.registrations.at(-1).totalAmountCents, 1200);
  snapshot = repository.updateRegistration(id, { registration: { quantity: 1, registrant_scope: 'dependent', dependent_id: 'dependent-001', contact_name: '王小美', offering: 'forged', price_cents: 1 } });
  assert.equal(snapshot.registrations.at(-1).offering.title, '線上祈福服務');
  assert.equal(snapshot.registrations.at(-1).registrantName, '林小福');
  const edit = repository.editRegistration(id);
  const rePrepared = preparedRegistration({ offering: edit.registration.offering, registration: edit.registration, registrants: edit.registrants, snapshot });
  assert.equal(rePrepared.registration.registrant_scope, 'dependent');
  assert.equal(rePrepared.registration.dependent_id, 'dependent-001');
  assert.equal(rePrepared.registration.quantity, 1);
  assert.equal(rePrepared.registration.contact_name, '王小美');
  assert.deepEqual(rePrepared.offering, { id: 'service-001', slug: 'online-blessing', title: '線上祈福服務', account_action: 'service', price_cents: 600, currency: 'TWD' });
  assert.throws(() => repository.createRegistration({ offering: 'invented', accountAction: 'event', registration: { registrant_scope: 'self' } }), { field: 'offering' });
  assert.throws(() => repository.createRegistration({ offering: 'online-blessing', accountAction: 'service', registration: { registrant_scope: 'dependent', dependent_id: 'dependent-001' } }), { field: 'registration' });
  assert.throws(() => repository.updateRegistration('registration-001', { registration: { registrant_scope: 'self' } }), { field: 'registration' });
  snapshot = repository.reset();
  assert.equal(snapshot.profile.name, '林小安');
  assert.equal(snapshot.dependents.length, 1);
  assert.equal(snapshot.registrations.length, 1);
});

test('dummy offering selection requires matching catalog identity and authoritative action without mutation', () => {
  const repository = createDummyRepository();
  const before = repository.snapshot();

  assert.throws(() => repository.newRegistration({ offering: 'service-001', accountAction: 'event' }), { field: 'offering' });
  assert.throws(() => repository.createRegistration({ offering: { id: 'service-001', slug: 'online-blessing' }, accountAction: 'event', registration: { registrant_scope: 'self' } }), { field: 'offering' });
  assert.deepEqual(repository.snapshot(), before);

  const prepared = repository.newRegistration({ offering: 'service-001', accountAction: 'service' });
  assert.equal(prepared.offering.id, 'service-001');
  assert.equal(prepared.offering.account_action, 'service');
});
