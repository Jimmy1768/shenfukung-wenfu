const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const root = path.resolve(__dirname, '..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

test('refined presentation keeps both complete locales and explicit dummy disclosure', () => {
  const source = read('app/ui/copy.js');
  for (const phrase of ['示範模式', 'Demo mode:', 'TempleMate', '連結失敗', 'Connection failed', '僅供展示', 'display only']) assert.match(source, new RegExp(phrase));
  assert.equal(source.includes('OAuth'), false);
  assert.equal(source.includes('checkout'), false);
});

test('presentation uses generated token authority and a wrapped native account menu', () => {
  const theme = read('app/ui/theme.js');
  const app = read('App.js');
  const primitives = read('app/ui/primitives.js');
  assert.match(theme, /getTheme/);
  assert.match(theme, /temple-1/);
  assert.match(theme, /ops-dark/);
  assert.match(app, /flexWrap: 'wrap'/);
  assert.equal(app.includes('<ScrollView horizontal'), false);
  assert.match(app, /accessibilityRole="tablist"/);
  assert.match(primitives, /accessibilityRole="alert"/);
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
  assert.equal((app.match(/activePresentationTenant\(binding\)/g) || []).length, 3);
  assert.equal(app.includes("binding.state === 'bound' ? binding.tenant.name"), false);
  assert.match(app, /binding\.state === 'switching'.*t\.confirmSwitch/);
  const confirmationOnlyCleanup = app.match(/onPress=\{async \(\) => \{ const ok = await run\(async \(\) => \{ await oauthController\.clear\('idle'\); return adapter\.clearTenantState\(\); \}\); if \(ok\) setBinding\(confirmSwitch\(binding, clearPriorTenant\(binding\.tenant\)\)\); \}\}/g) || [];
  assert.equal(confirmationOnlyCleanup.length, 1);
});

test('Doctor stays project-local and reports unavailable metadata checks in offline mode', () => {
  const pkg = JSON.parse(read('package.json'));
  assert.equal(pkg.devDependencies['expo-doctor'], '1.20.1');
  assert.equal(pkg.scripts.doctor.includes('npx'), false);
  assert.match(pkg.scripts.doctor, /EXPO_DOCTOR_WARN_ON_NETWORK_ERRORS=1 expo-doctor/);
  assert.equal(pkg.expo.doctor.reactNativeDirectoryCheck.enabled, false);
});
