const test = require('node:test');
const assert = require('node:assert/strict');
const { mutationOutcome, safeAccountScreen } = require('../app/account/screen_model');

test('failed mutations retain their success-only follow-up state', async () => {
  let navigated = false;
  const failed = await mutationOutcome({ action: async () => { throw new Error('invalid'); }, onSuccess: () => { navigated = true; } });
  assert.equal(failed.ok, false);
  assert.equal(navigated, false);
  const saved = await mutationOutcome({ action: async () => 'saved', onSuccess: () => { navigated = true; } });
  assert.equal(saved.ok, true);
  assert.equal(navigated, true);
});

test('declared and unknown account screens resolve to non-destructive presentation', () => {
  assert.equal(safeAccountScreen('connection'), 'connection');
  assert.equal(safeAccountScreen('closure'), 'closure');
  assert.equal(safeAccountScreen('unknown'), 'home');
});

