const test = require('node:test');
const assert = require('node:assert/strict');
const versioning = require('../versioning');
const eas = require('../eas.json');
const project = require('../app/lib/app_constants/project');

const configFor = buildMode => {
  const previous = process.env.BUILD_MODE;
  process.env.BUILD_MODE = buildMode;
  try {
    return require('../app.config.js')().expo;
  } finally {
    if (previous === undefined) delete process.env.BUILD_MODE;
    else process.env.BUILD_MODE = previous;
  }
};

test('development config uses TempleMate identity and preserves local version authority', () => {
  const config = configFor('development');
  assert.equal(project.name, 'komainu');
  assert.equal(config.name, project.developmentPublicName);
  assert.equal(config.version, '1.0.0');
  assert.equal(versioning.iosBuildNumber, '1');
  assert.equal(versioning.androidVersionCode, 1);
  assert.equal(config.android.compileSdkVersion, 36);
  assert.equal(config.android.targetSdkVersion, 36);
  assert.deepEqual(config.ios.bundleIdentifier, project.nativeIdentifiers.development.iosBundleIdentifier);
  assert.deepEqual(config.android.package, project.nativeIdentifiers.development.androidPackage);
  assert.equal(eas.build.development.developmentClient, true);
  assert.equal(eas.build.development.android.buildType, 'apk');
  assert.equal(JSON.stringify(eas).includes('autoIncrement'), false);
});

test('production config uses the public TempleMate native identifiers', () => {
  const config = configFor('production');
  assert.equal(config.name, project.publicName);
  assert.equal(config.ios.bundleIdentifier, project.nativeIdentifiers.production.iosBundleIdentifier);
  assert.equal(config.android.package, project.nativeIdentifiers.production.androidPackage);
});

test('project native identifiers contain only the komainu production and development pair', () => {
  assert.deepEqual(project.nativeIdentifiers, {
    production: {
      iosBundleIdentifier: 'com.jimmy1768.komainu',
      androidPackage: 'com.jimmy1768.komainu'
    },
    development: {
      iosBundleIdentifier: 'com.jimmy1768.komainu.dev',
      androidPackage: 'com.jimmy1768.komainu.dev'
    }
  });
});
