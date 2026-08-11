const versioning = require('./versioning');
const project = require('./app/lib/app_constants/project');

const isDevelopmentClient = () => {
  const value = String(process.env.BUILD_MODE || process.env.EAS_BUILD_PROFILE || 'development').toLowerCase();
  return ['development', 'dev', 'debug'].includes(value);
};

module.exports = () => {
  const development = isDevelopmentClient();
  const nativeIdentifiers = project.nativeIdentifiers[development ? 'development' : 'production'];

  return {
    expo: {
      name: development ? project.developmentPublicName : project.publicName,
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
        bundleIdentifier: nativeIdentifiers.iosBundleIdentifier,
        buildNumber: versioning.iosBuildNumber
      },
      android: {
        package: nativeIdentifiers.androidPackage,
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
        // Dummy is network-free by default. Real mode is an intentional local/test
        // selection and is invalid without both values; neither is a secret.
        clientMode: process.env.TEMPLEMATE_CLIENT_MODE === 'real' ? 'real' : 'dummy',
        localApiBaseUrl: process.env.TEMPLEMATE_LOCAL_API_BASE_URL || '',
        localTenantSlug: process.env.TEMPLEMATE_LOCAL_TENANT_SLUG || '',
        clientEnvironment: process.env.TEMPLEMATE_CLIENT_ENVIRONMENT || 'development',
        supportedLocales: ['zh-TW', 'en'],
        supportedThemes: ['light', 'dark'],
        android16TargetSdk: 36
      }
    }
  };
};
