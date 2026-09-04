const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const root = path.resolve(__dirname, '..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const { emptyFeedback, errorFeedback, feedbackForNavigation, noticeFeedback } = require('../app/ui/feedback');

test('feedback state owns errors and destination notices across navigation, reset, and locale boundaries', () => {
  assert.deepEqual(feedbackForNavigation(errorFeedback('Message is required', 'assistance'), 'privacy'), emptyFeedback());
  const forwarded = noticeFeedback('saved', 'settings');
  assert.deepEqual(feedbackForNavigation(forwarded, 'settings'), forwarded);
  assert.deepEqual(feedbackForNavigation(forwarded, 'closure'), emptyFeedback());
  assert.deepEqual(emptyFeedback(), { error: null, notice: null }, 'reset and locale changes clear all transient feedback');
});

test('refined presentation keeps both complete locales', () => {
  const source = read('app/ui/copy.js');
  for (const phrase of ['示範模式', 'Demo mode:', 'TempleMate', '連結失敗', 'Connection failed', '僅供展示', 'display only']) assert.match(source, new RegExp(phrase));
  assert.equal(source.includes('OAuth'), false);
  assert.equal(source.includes('checkout'), false);
});

test('presentation uses generated token authority and a single-line native business menu', () => {
  const theme = read('app/ui/theme.js');
  const app = read('App.js');
  const primitives = read('app/ui/primitives.js');
  assert.match(theme, /getTheme/);
  assert.match(theme, /temple-1/);
  assert.match(theme, /ops-dark/);
  assert.match(app, /accountMenu\(\)/);
  assert.match(app, /<ScrollView horizontal accessibilityRole="tablist"/);
  assert.match(app, /navigationShell: \{ flexGrow: 0, borderBottomWidth: 1 \}/);
  assert.match(app, /flexWrap: 'nowrap'/);
  assert.match(app, /navigation: \{ flexDirection: 'row', flexWrap: 'nowrap', alignItems: 'center'/);
  assert.equal(app.includes('Text numberOfLines={1} style={{ color: screen === key'), false);
  assert.match(app, /accessibilityRole="tablist"/);
  assert.match(primitives, /accessibilityRole="alert"/);
});

test('bound header places Settings beside Sign out while the unbound gate exposes Sign out only', () => {
  const app = read('App.js');
  assert.match(app, /onSettings=\{\(\) => navigate\('settings'\)\}/);
  assert.match(app, /headerUtilities.*activeTenant && <Button label=\{t\.settings\}.*<Button label=\{t\.signOut\}/);
  assert.match(app, /<Header t=\{t\} palette=\{palette\} binding=\{binding\} onSignOut=\{signOut\} \/>/);
});

test('signed-out OAuth status uses the existing locale outcome dictionaries', () => {
  const app = read('App.js');
  const copy = read('app/ui/copy.js');
  assert.match(app, /t\.oauthOutcome\[oauthState\.phase\] \|\| t\.oauthOutcome\.idle/);
  assert.equal(app.includes('t.oauthState'), false);
  assert.equal((copy.match(/\boauthOutcome:/g) || []).length, 2);
  assert.equal(copy.includes('oauthState:'), false);
});

test('tenant connection presentation uses the shared retained-tenant selector', () => {
  const app = read('App.js');
  assert.match(app, /import \{ activePresentationTenant,/);
  assert.ok((app.match(/activePresentationTenant\(binding\)/g) || []).length >= 3);
  assert.equal(app.includes("binding.state === 'bound' ? binding.tenant.name"), false);
});

// The temple is forgotten in exactly one place, reached from one control. Every
// other path that used to clear it -- sign-out, session expiry, account
// closure, OAuth, the fixture switch-temple flow -- was a bug, each found
// separately over 2026-09-04.
test('only the explicit Unbind control forgets the temple', () => {
  const app = read('App.js');
  assert.match(app, /const onUnbindTemple = async \(\) => \{/);
  assert.equal((app.match(/trustedBindingStorage\.clear\(\)/g) || []).length, 1,
    'exactly one caller may clear the stored binding');
  assert.match(app, /label=\{t\.unbindTemple\} palette=\{palette\} tone="secondary" onPress=\{onUnbindTemple\}/);
  for (const gone of ['clearReleaseBinding', 'confirmSwitch', 'requestSwitch', 'clearPriorTenant', 'fixtureConnectionLink']) {
    assert.equal(app.includes(gone), false, `${gone} belonged to the removed fixture switch flow`);
  }
});

test('Doctor stays project-local and reports unavailable metadata checks in offline mode', () => {
  const pkg = JSON.parse(read('package.json'));
  assert.equal(pkg.devDependencies['expo-doctor'], '1.20.1');
  assert.equal(pkg.scripts.doctor.includes('npx'), false);
  assert.match(pkg.scripts.doctor, /EXPO_DOCTOR_WARN_ON_NETWORK_ERRORS=1 expo-doctor/);
  assert.equal(pkg.expo.doctor.reactNativeDirectoryCheck.enabled, false);
});
