const nativeIdentifiers = Object.freeze({
  production: Object.freeze({
    iosBundleIdentifier: 'com.jimmy1768.komainu',
    androidPackage: 'com.jimmy1768.komainu'
  }),
  development: Object.freeze({
    iosBundleIdentifier: 'com.jimmy1768.komainu.dev',
    androidPackage: 'com.jimmy1768.komainu.dev'
  })
});

const project = Object.freeze({
  name: 'komainu',
  publicName: 'TempleMate',
  developmentPublicName: 'TempleMate (Dev)',
  slug: 'templemate',
  expoSlug: 'templemate',
  scheme: 'templemate',
  nativeIdentifiers
});

module.exports = project;
module.exports.project = project;
module.exports.default = project;
