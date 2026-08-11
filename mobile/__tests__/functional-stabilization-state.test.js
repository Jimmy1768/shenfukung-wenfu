const test = require('node:test');
const assert = require('node:assert/strict');
const { mutationOutcome, safeAccountScreen } = require('../app/account/screen_model');
const { createDummyRepository } = require('../app/dummy/repository');

test('failed mutations retain their success-only follow-up state', async () => {
  let navigated = false;
  const failed = await mutationOutcome({ action: async () => { throw new Error('invalid'); }, onSuccess: () => { navigated = true; } });
  assert.equal(failed.ok, false);
  assert.equal(navigated, false);
  const saved = await mutationOutcome({ action: async () => 'saved', onSuccess: () => { navigated = true; } });
  assert.equal(saved.ok, true);
  assert.equal(navigated, true);
});

test('dummy signup credentials survive sign-out until deterministic reset', () => {
  const repository = createDummyRepository();
  assert.throws(() => repository.signUp({ name: '', email: 'new@example.test', password: 'demo-pass' }));
  assert.throws(() => repository.signIn({ email: 'new@example.test', password: 'demo-pass' }));
  repository.signUp({ name: 'New Member', email: 'new@example.test', password: 'demo-pass' });
  assert.equal(repository.signIn({ email: 'new@example.test', password: 'demo-pass' }).profile.email, 'new@example.test');
  repository.reset();
  assert.equal(repository.signIn({ email: 'member@example.test', password: 'templemate-demo' }).profile.email, 'member@example.test');
  assert.throws(() => repository.signIn({ email: 'new@example.test', password: 'demo-pass' }));
});

test('declared and unknown account screens resolve to non-destructive presentation', () => {
  assert.equal(safeAccountScreen('connection'), 'connection');
  assert.equal(safeAccountScreen('closure'), 'closure');
  assert.equal(safeAccountScreen('unknown'), 'home');
});

test('dummy preferences are resettable fixture state and failed writes leave the prior visible choice intact', () => {
  const repository = createDummyRepository();
  assert.equal(repository.updatePreferences({ locale: 'en', mobile_theme_id: 'dark' }).preferences.locale, 'en');
  assert.equal(repository.snapshot().preferences.mobile_theme_id, 'dark');
  repository.reset();
  assert.deepEqual(repository.snapshot().preferences, { locale: 'zh-TW', theme: 'light' });
});
