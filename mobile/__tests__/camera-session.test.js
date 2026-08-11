const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { createCameraSession, permissionState } = require('../app/tenant/camera_session');
const { fixtureConnectionLink } = require('../app/tenant/binding');
const { tenant } = require('../app/dummy/fixtures');
const { scanCameraPayload } = require('../app/tenant/scanner');

test('camera permission states keep preview closed until a user-initiated granted state', () => {
  assert.equal(permissionState(null), 'loading');
  assert.equal(permissionState({ granted: true }), 'ready');
  assert.equal(permissionState({ granted: false, canAskAgain: true }), 'denied');
  assert.equal(permissionState({ granted: false, canAskAgain: false }), 'blocked');
});

test('camera session accepts only the first QR callback and can be cancelled or retried', async () => {
  let calls = 0;
  const session = createCameraSession({ scanPayload: async payload => {
    calls += 1;
    return scanCameraPayload({ mode: 'dummy', payload });
  } });
  assert.equal(session.snapshot().state, 'closed');
  assert.equal(session.open({ granted: true }).state, 'ready');
  const first = session.receive(fixtureConnectionLink(tenant));
  const duplicate = session.receive('https://untrusted.example.test/connect/templemate');
  assert.equal((await duplicate).state, 'validating');
  assert.equal((await first).state, 'success');
  assert.equal(calls, 1);
  assert.equal(session.close().state, 'closed');
  assert.equal(session.open({ granted: true }).state, 'ready');
});

test('invalid or untrusted camera payload never becomes a binding', async () => {
  const session = createCameraSession({ scanPayload: payload => scanCameraPayload({ mode: 'dummy', payload }) });
  session.open({ granted: true });
  const result = await session.receive('https://untrusted.example.test/connect/templemate');
  assert.equal(result.state, 'invalid');
  assert.equal(result.result.state, 'binding_failed');
  assert.equal(result.result.error, 'untrusted_origin');
});

test('camera surface is a rear-only QR preview with no audio or real binding path', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'app', 'tenant', 'camera_surface.js'), 'utf8');
  assert.match(source, /CameraView/);
  assert.match(source, /useCameraPermissions/);
  assert.match(source, /facing="back"/);
  assert.match(source, /barcodeTypes: \['qr'\]/);
  assert.doesNotMatch(source, /recordAudio|audio|microphone|fetch|real/iu);
});
