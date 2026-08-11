const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const config = require(path.join(root, 'app.config.js'))().expo;
const versioning = require(path.join(root, 'versioning.js'));
const pkg = require(path.join(root, 'package.json'));
const eas = require(path.join(root, 'eas.json'));

const fail = (message) => {
  console.error(`native-client verification failed: ${message}`);
  process.exitCode = 1;
};

if (!/^\d+\.\d+\.\d+$/.test(versioning.appVersion)) fail('version must be major.minor.patch');
if (pkg.version !== versioning.appVersion || config.version !== versioning.appVersion) fail('package/config version differs from versioning.js');
if (versioning.iosBuildNumber !== '1' || versioning.androidVersionCode !== 1) fail('initial build values must remain 1');
if (config.name !== 'TempleMate (Dev)') fail('development launcher must be TempleMate (Dev)');
if (config.android.compileSdkVersion !== 36 || config.android.targetSdkVersion !== 36) fail('Android compile/target SDK must be 36');
if (!eas.build?.development?.developmentClient || eas.build.development.android?.buildType !== 'apk') fail('only the development APK profile is permitted');
if (JSON.stringify(eas).match(/app-bundle|production-aab|autoIncrement/i)) fail('release or auto-increment configuration is forbidden');
if (!fs.existsSync(path.join(root, 'assets', 'dev-icon.png')) || !fs.existsSync(path.join(root, 'assets', 'dev-adaptive-icon.png'))) fail('development artwork is missing');
if (process.exitCode) process.exit(process.exitCode);
console.log('native-client verification passed: TempleMate (Dev), 1.0.0, SDK 36, build values preserved.');
