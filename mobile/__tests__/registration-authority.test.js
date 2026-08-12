const test = require('node:test');
const assert = require('node:assert/strict');
const { createInput, offeringCatalog, preparedRegistration, quantityInputValue, selectRegistrant, updateInput } = require('../app/account/registration_authority');

const snapshot = {
  profile: { id: 'account-1', name: 'Member' },
  dependents: [{ id: 'dependent-1', name: 'Family' }],
  events: [{ id: 'event-1', slug: 'blessing', title: 'Blessing', account_action: 'event', price_cents: 1200, currency: 'TWD' }],
  services: [], gatherings: []
};

test('quantity input presentation preserves an intentional empty value', () => {
  assert.equal(quantityInputValue(undefined), '1');
  assert.equal(quantityInputValue(null), '1');
  assert.equal(quantityInputValue(''), '');
  assert.equal(quantityInputValue(1), '1');
  assert.equal(quantityInputValue('1'), '1');
  assert.equal(quantityInputValue(2), '2');
  assert.equal(quantityInputValue('2'), '2');
  assert.equal(quantityInputValue(0), '0');
});

test('registration preparation owns offering, fee, and registrant choices', () => {
  const [offering] = offeringCatalog(snapshot);
  const prepared = preparedRegistration({ offering, snapshot });
  assert.equal(prepared.offering.title, 'Blessing');
  assert.equal(prepared.offering.price_cents, 1200);
  const dependent = selectRegistrant(prepared, { scope: 'dependent', id: 'dependent-1' });
  assert.deepEqual(createInput(dependent), { offering: 'blessing', accountAction: 'event', registration: { quantity: 1, registrant_scope: 'dependent', dependent_id: 'dependent-1', contact_name: 'Member' } });
  assert.deepEqual(updateInput({ ...dependent, registration: { ...dependent.registration, price_cents: 1, currency: 'USD', total_amount_cents: 1 } }), { registration: { quantity: 1, registrant_scope: 'dependent', dependent_id: 'dependent-1', contact_name: 'Member' } });
  assert.throws(() => selectRegistrant(prepared, { scope: 'dependent', id: 'foreign' }), { code: 'registrant_not_found' });
});
