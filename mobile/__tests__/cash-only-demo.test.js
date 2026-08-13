const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { seed } = require('../app/dummy/fixtures');
const { createDummyRepository } = require('../app/dummy/repository');
const { registrationDemoPresentation } = require('../app/account/registration_demo_presentation');

const approvedSlugs = ['incense-donation', 'lamp-service', 'ghost-festival-table', 'liberation-ritual'];

test('dummy Shengfukung catalog is exactly the four TWD 50 temple offerings', () => {
  const catalog = [...seed.events, ...seed.services, ...seed.gatherings];
  assert.deepEqual(catalog.map(item => item.slug), approvedSlugs);
  assert.ok(catalog.every(item => item.account_action === 'service' && item.price_cents === 5000 && item.currency === 'TWD'));
  assert.equal(JSON.stringify(catalog).match(/peace-opera-household|ritual-bucket-ceremony/), null);

  const source = fs.readFileSync(path.join(__dirname, '..', 'App.js'), 'utf8');
  assert.match(source, /NT\$\$\{\(Number\(amount \|\| 0\) \/ 100\)/);
});

test('dummy registration presentation has no payment action and completed cash is demo-only read-only', () => {
  assert.deepEqual(registrationDemoPresentation({}), { key: 'pending_cash_arrangement', copyKey: 'pendingCashArrangement', readOnly: false });
  assert.deepEqual(registrationDemoPresentation(seed.registrations[0]), { key: 'completed_cash_demo', copyKey: 'completedCashDemo', readOnly: true });
  assert.equal(seed.registrations[0].demoCashFixture, true);
  assert.equal(seed.registrations[0].readOnly, true);

  const source = fs.readFileSync(path.join(__dirname, '..', 'App.js'), 'utf8');
  assert.match(source, /registrationDemoPresentation/);
  assert.doesNotMatch(source, /checkout|payment provider|ECPay|Stripe|cash receipt|settlement/i);

  const copy = fs.readFileSync(path.join(__dirname, '..', 'app', 'ui', 'copy.js'), 'utf8');
  assert.match(copy, /線上付款目前無法使用；請與宮廟安排現金付款。/);
  assert.match(copy, /Online payment is unavailable\. Arrange cash payment with the temple\./);
  assert.match(copy, /示範資料，僅供展示，不能修改/);
  assert.match(copy, /demo data; display only and cannot be edited/);
});

test('dummy pending registrations are atomic and reset restores only the cash fixture', () => {
  const repository = createDummyRepository();
  const before = repository.snapshot();
  assert.throws(() => repository.createRegistration({ offering: 'invented', accountAction: 'service', registration: { registrant_scope: 'self' } }), { field: 'offering' });
  assert.deepEqual(repository.snapshot(), before);

  const self = repository.createRegistration({ offering: 'lamp-service', accountAction: 'service', registration: { quantity: 2, registrant_scope: 'self', contact_name: '林小安' } });
  const created = self.registrations.at(-1);
  assert.equal(created.paymentState, 'pending_cash_arrangement');
  assert.equal(created.totalAmountCents, 10000);
  assert.equal(created.readOnly, false);

  const dependent = repository.createRegistration({ offering: 'ghost-festival-table', accountAction: 'service', registration: { quantity: 1, registrant_scope: 'dependent', dependent_id: 'dependent-001' } });
  assert.equal(dependent.registrations.at(-1).registrantName, '林小福');
  assert.equal(dependent.registrations.at(-1).totalAmountCents, 5000);

  const reset = repository.reset();
  assert.equal(reset.dependents.length, 1);
  assert.deepEqual(reset.registrations, seed.registrations);
  assert.deepEqual([...reset.events, ...reset.services, ...reset.gatherings].map(item => item.slug), approvedSlugs);
});
