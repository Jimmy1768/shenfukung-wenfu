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
  assert.equal(config.owner, 'jimmy1768');
  assert.equal(config.extra.eas.projectId, 'c7b8523a-2fad-4123-bc96-0c0c85a23dec');
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
  assert.equal(config.owner, 'jimmy1768');
  assert.equal(config.extra.eas.projectId, 'c7b8523a-2fad-4123-bc96-0c0c85a23dec');
  assert.equal(config.ios.bundleIdentifier, project.nativeIdentifiers.production.iosBundleIdentifier);
  assert.equal(config.android.package, project.nativeIdentifiers.production.androidPackage);
});

test('TestFlight and production source profiles are real, public, and isolated from development', () => {
  for (const profile of ['testflight', 'production']) {
    const config = configFor(profile);
    assert.equal(config.extra.clientMode, 'real');
    assert.equal(config.extra.apiBaseUrl, 'https://shengfukung.com.tw');
    assert.equal(config.extra.tenantSlug, 'shengfukung-wenfu');
    assert.equal(config.extra.easUpdateChannel, profile);
    assert.equal(config.updates.url, 'https://u.expo.dev/c7b8523a-2fad-4123-bc96-0c0c85a23dec');
    // Real incident, 2026-08-20: this assertion used to check
    // config.updates.runtimeVersion (nested, wrong) equal to a policy
    // object -- which meant it happily locked in the exact bug that shipped
    // a TestFlight build with no runtime version embedded at all. Pinned
    // to DojoMate-Expo's proven top-level literal-string form instead.
    assert.equal(config.runtimeVersion, versioning.appVersion);
    assert.equal(config.updates.runtimeVersion, undefined);
    assert.equal(eas.build[profile].channel, profile);
    assert.equal(eas.build[profile].distribution, 'store');
  }
  assert.equal(eas.build.development.channel, undefined);
});

test('both public configs declare QR-only camera access without Android audio recording', () => {
  for (const buildMode of ['development', 'production']) {
    const config = configFor(buildMode);
    const camera = config.plugins.find(plugin => Array.isArray(plugin) && plugin[0] === 'expo-camera');
    assert.deepEqual(camera, ['expo-camera', {
      cameraPermission: 'TempleMate uses your camera only to scan a temple QR code.',
      recordAudioAndroid: false
    }]);
  }
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
