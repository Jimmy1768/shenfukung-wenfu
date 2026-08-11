const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const versioning = require(path.join(root, 'versioning.js'));
const pkg = require(path.join(root, 'package.json'));
const eas = require(path.join(root, 'eas.json'));
const project = require(path.join(root, 'app', 'lib', 'app_constants', 'project.js'));
const { nativeOAuthReturnUrl, publicConfigurationMatrix } = require(path.join(root, 'app', 'oauth', 'config.js'));

const configFor = buildMode => {
  const previous = process.env.BUILD_MODE;
  process.env.BUILD_MODE = buildMode;
  try {
    return require(path.join(root, 'app.config.js'))().expo;
  } finally {
    if (previous === undefined) delete process.env.BUILD_MODE;
    else process.env.BUILD_MODE = previous;
  }
};

const sourceFiles = directory => fs.readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
  const entryPath = path.join(directory, entry.name);
  if (entry.isDirectory()) return ['node_modules', 'android', 'ios'].includes(entry.name) ? [] : sourceFiles(entryPath);
  return /\.(?:js|jsx)$/.test(entry.name) ? [entryPath] : [];
});

const rejectedNativeIdentifiers = [
  'tw.com.templemate.dev',
  'com.sourcegridlabs.',
  'com.jimmy1768.tenant',
  'com.jimmy1768.admin'
];
const activeSourcePaths = [path.join(root, 'app.config.js'), path.join(root, 'app')];
const activeSourceHasRejectedIdentifier = activeSourcePaths
  .flatMap(entryPath => fs.statSync(entryPath).isDirectory() ? sourceFiles(entryPath) : [entryPath])
  .some(file => rejectedNativeIdentifiers.some(identifier => fs.readFileSync(file, 'utf8').includes(identifier)));
const developmentConfig = configFor('development');
const productionConfig = configFor('production');

const fail = (message) => {
  console.error(`native-client verification failed: ${message}`);
  process.exitCode = 1;
};

if (!/^\d+\.\d+\.\d+$/.test(versioning.appVersion)) fail('version must be major.minor.patch');
if (pkg.version !== versioning.appVersion || developmentConfig.version !== versioning.appVersion || productionConfig.version !== versioning.appVersion) fail('package/config version differs from versioning.js');
if (versioning.iosBuildNumber !== '1' || versioning.androidVersionCode !== 1) fail('initial build values must remain 1');
if (project.name !== 'komainu') fail('internal project name must be komainu');
if (developmentConfig.name !== project.developmentPublicName) fail('development launcher must be TempleMate (Dev)');
if (developmentConfig.ios.bundleIdentifier !== project.nativeIdentifiers.development.iosBundleIdentifier || developmentConfig.android.package !== project.nativeIdentifiers.development.androidPackage) fail('development config must use the public development identifiers');
if (productionConfig.name !== project.publicName) fail('production launcher must be TempleMate');
if (productionConfig.ios.bundleIdentifier !== project.nativeIdentifiers.production.iosBundleIdentifier || productionConfig.android.package !== project.nativeIdentifiers.production.androidPackage) fail('production config must use the public production identifiers');
if (developmentConfig.android.compileSdkVersion !== 36 || developmentConfig.android.targetSdkVersion !== 36 || productionConfig.android.compileSdkVersion !== 36 || productionConfig.android.targetSdkVersion !== 36) fail('Android compile/target SDK must be 36');
if (developmentConfig.extra.nativeOAuthReturnUrl !== nativeOAuthReturnUrl || productionConfig.extra.nativeOAuthReturnUrl !== nativeOAuthReturnUrl || nativeOAuthReturnUrl !== 'templemate://oauth/complete') fail('OAuth return must use the accepted TempleMate scheme');
if (pkg.dependencies['expo-auth-session'] !== '~7.0.11' || pkg.dependencies['expo-web-browser'] !== '~15.0.11' || pkg.dependencies['expo-crypto'] !== '~15.0.9') fail('SDK 54 OAuth package versions differ from the accepted Expo compatibility set');
if (pkg.dependencies['expo-camera'] !== '~17.0.10') fail('SDK 54 QR camera package version differs from the accepted Expo compatibility set');
for (const config of [developmentConfig, productionConfig]) {
  const cameraPlugin = config.plugins?.find(plugin => Array.isArray(plugin) && plugin[0] === 'expo-camera');
  if (!cameraPlugin || cameraPlugin[1]?.recordAudioAndroid !== false || !/TempleMate.*camera.*QR/i.test(cameraPlugin[1]?.cameraPermission || '')) fail('QR camera config must declare a TempleMate purpose and disable Android audio recording');
}
if (!publicConfigurationMatrix.development || !publicConfigurationMatrix.production || JSON.stringify(publicConfigurationMatrix).match(/secret|client[_-]?id|token/i)) fail('OAuth configuration matrix must remain public and nonsecret');
if (!eas.build?.development?.developmentClient || eas.build.development.android?.buildType !== 'apk') fail('only the development APK profile is permitted');
if (JSON.stringify(eas).match(/app-bundle|production-aab|autoIncrement/i)) fail('release or auto-increment configuration is forbidden');
if (!fs.existsSync(path.join(root, 'assets', 'dev-icon.png')) || !fs.existsSync(path.join(root, 'assets', 'dev-adaptive-icon.png'))) fail('development artwork is missing');
if (activeSourceHasRejectedIdentifier) fail('rejected tenant, admin, country, or SourceGrid identifier remains in active mobile source');
if (process.exitCode) process.exit(process.exitCode);
console.log('native-client verification passed: TempleMate production/development identities, 1.0.0, SDK 36, build values, and OAuth public configuration preserved.');
