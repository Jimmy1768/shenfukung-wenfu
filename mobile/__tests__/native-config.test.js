const test = require('node:test');
const assert = require('node:assert/strict');
const config = require('../app.config.js')().expo;
const versioning = require('../versioning');
const eas = require('../eas.json');

test('development config uses TempleMate identity and preserves local version authority', () => {
  assert.equal(config.name, 'TempleMate (Dev)');
  assert.equal(config.version, '1.0.0');
  assert.equal(versioning.iosBuildNumber, '1');
  assert.equal(versioning.androidVersionCode, 1);
  assert.equal(config.android.compileSdkVersion, 36);
  assert.equal(config.android.targetSdkVersion, 36);
  assert.equal(eas.build.development.developmentClient, true);
  assert.equal(eas.build.development.android.buildType, 'apk');
  assert.equal(JSON.stringify(eas).includes('autoIncrement'), false);
});
