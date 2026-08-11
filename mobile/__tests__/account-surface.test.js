const test = require('node:test');
const assert = require('node:assert/strict');
const { createDummyAdapter } = require('../app/dummy/adapter');
const { accountMenu, dummyMode, isAccountScreen, isPaidFixtureReadOnly, visibleLocale, visibleTheme } = require('../app/account/screen_model');

test('account-only screen model exposes every dummy flow and no non-account mode', () => {
  for (const screen of ['home', 'profile', 'dependents', 'registrations', 'discover', 'settings', 'signup', 'recovery', 'assistance', 'contact', 'privacy', 'closure', 'connection']) assert.equal(isAccountScreen(screen), true);
  assert.deepEqual(accountMenu(), ['home', 'profile', 'dependents', 'registrations', 'discover', 'settings']);
  assert.equal(isAccountScreen('admin'), false);
  assert.equal(dummyMode(createDummyAdapter()), true);
  assert.equal(isPaidFixtureReadOnly({ readOnly: true }), true);
  assert.equal(isPaidFixtureReadOnly({ readOnly: false }), false);
});

test('locale and theme foundations are deterministic', () => {
  assert.equal(visibleLocale('zh-TW'), 'zh-TW');
  assert.equal(visibleLocale('en'), 'en');
  assert.equal(visibleLocale('unsupported'), 'zh-TW');
  assert.equal(visibleTheme(false), 'light');
  assert.equal(visibleTheme(true), 'dark');
});

test('dummy-only account support, privacy, closure and reset states are interactive', async () => {
  const adapter = createDummyAdapter();
  let state = await adapter.signUp({ name: '示範會員', email: 'new@example.test', password: 'demo-pass' });
  assert.equal(state.signup.completed, true);
  state = await adapter.recoverPassword({ email: 'new@example.test' });
  assert.equal(state.recovery.requested, true);
  state = await adapter.submitAssistance({ message: '需要協助' });
  assert.equal(state.assistance.message, '需要協助');
  state = await adapter.contactTemple({ message: '請聯絡我' });
  assert.equal(state.contact.submitted, true);
  state = await adapter.requestPrivacy({ kind: 'export' });
  assert.equal(state.privacyRequest.kind, 'export');
  await assert.rejects(adapter.closeAccount({ confirmation: 'NO' }));
  state = await adapter.closeAccount({ confirmation: 'CLOSE' });
  assert.equal(state.closed, true);
  assert.equal(adapter.reset().closed, undefined);
});
