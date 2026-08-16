const test = require('node:test');
const assert = require('node:assert/strict');
const { verify } = require('../scripts/verify-ota-lane');

test('OTA lanes are explicit, receipt-gated, and production needs a scope token without invoking EAS', () => {
  assert.deepEqual(verify({ lane: 'testflight', message: 'TestFlight source receipt', environment: 'testflight', sourceCommit: 'abc123', runtimeVersion: '1.0.0', releaseReceipt: true }), { lane: 'testflight', branch: 'testflight', runtimeVersion: '1.0.0', sourceCommit: 'abc123', message: 'TestFlight source receipt' });
  assert.throws(() => verify({ lane: 'production', message: 'release', environment: 'production', sourceCommit: 'abc123', releaseReceipt: true }), /scope token/);
  assert.throws(() => verify({ lane: 'testflight', message: '', environment: 'testflight', sourceCommit: 'abc123', releaseReceipt: true }), /nonblank/);
  assert.throws(() => verify({ lane: 'testflight', message: 'x', environment: 'dummy', sourceCommit: 'abc123', releaseReceipt: true }), /attribution/);
});
