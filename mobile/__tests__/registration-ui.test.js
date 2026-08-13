const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

test('registration UI starts from Discover and never renders editable offering or money authority', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'App.js'), 'utf8');
  assert.match(source, /offeringCatalog\(data\)/);
  assert.match(source, /adapter\.newRegistration\(\{ offering: offering\.slug, accountAction: offering\.account_action \}\)/);
  assert.match(source, /formatMoney\(offering\.price_cents, offering\.currency\)/);
  assert.match(source, /registrationDemoPresentation/);
  assert.doesNotMatch(source, /FormInput label=\{t\.offering/);
  assert.doesNotMatch(source, /FormInput label=\{t\.offeringSlug/);
  assert.doesNotMatch(source, /onChangeText=\{[^}]*price_cents/);
  assert.doesNotMatch(source, /onChangeText=\{[^}]*currency/);
  assert.doesNotMatch(source, /onChangeText=\{[^}]*registrantName/);
});
