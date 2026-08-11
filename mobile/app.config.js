const versioning = require('./versioning');

const isDevelopmentClient = () => {
  const value = String(process.env.BUILD_MODE || process.env.EAS_BUILD_PROFILE || 'development').toLowerCase();
  return ['development', 'dev', 'debug'].includes(value);
};

module.exports = () => {
  const development = isDevelopmentClient();

  return {
    expo: {
      name: development ? 'TempleMate (Dev)' : 'TempleMate',
      slug: 'templemate',
      version: versioning.appVersion,
      scheme: 'templemate',
      orientation: 'portrait',
      icon: development ? './assets/dev-icon.png' : './assets/icon.png',
      userInterfaceStyle: 'automatic',
      newArchEnabled: true,
      splash: {
        image: './assets/splash-icon.png',
        resizeMode: 'contain',
        backgroundColor: '#ffffff'
      },
      ios: {
        supportsTablet: true,
        bundleIdentifier: 'tw.com.templemate.dev',
        buildNumber: versioning.iosBuildNumber
      },
      android: {
        package: 'tw.com.templemate.dev',
        versionCode: versioning.androidVersionCode,
        compileSdkVersion: 36,
        targetSdkVersion: 36,
        adaptiveIcon: {
          foregroundImage: development ? './assets/dev-adaptive-icon.png' : './assets/adaptive-icon.png',
          backgroundColor: '#ffffff'
        },
        edgeToEdgeEnabled: true
      },
      plugins: ['expo-secure-store', 'expo-dev-client'],
      extra: {
        clientMode: 'dummy',
        supportedLocales: ['zh-TW', 'en'],
        supportedThemes: ['light', 'dark'],
        android16TargetSdk: 36
      }
    }
  };
};
