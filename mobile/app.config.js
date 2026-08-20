const versioning = require('./versioning');
const project = require('./app/lib/app_constants/project');
const { nativeOAuthReturnUrl } = require('./app/oauth/config');

const isDevelopmentClient = () => {
  const value = String(process.env.BUILD_MODE || process.env.EAS_BUILD_PROFILE || 'development').toLowerCase();
  return ['development', 'dev', 'debug'].includes(value);
};

const releaseConfiguration = buildMode => {
  const environment = String(process.env.TEMPLEMATE_CLIENT_ENVIRONMENT || buildMode).toLowerCase();
  if (!['testflight', 'production'].includes(environment)) return null;
  return {
    clientMode: 'real',
    apiBaseUrl: 'https://shengfukung.com.tw',
    tenantSlug: 'shengfukung-wenfu',
    clientEnvironment: environment,
    easUpdateChannel: environment
  };
};

module.exports = () => {
  const development = isDevelopmentClient();
  const buildMode = String(process.env.BUILD_MODE || process.env.EAS_BUILD_PROFILE || 'development').toLowerCase();
  const release = releaseConfiguration(buildMode);
  const nativeIdentifiers = project.nativeIdentifiers[development ? 'development' : 'production'];

  return {
    expo: {
      name: development ? project.developmentPublicName : project.publicName,
      slug: 'templemate',
      owner: 'jimmy1768',
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
        buildNumber: versioning.iosBuildNumber,
        // TempleMate only uses the standard HTTPS/TLS encryption iOS provides
        // to talk to the Rails backend -- no proprietary/custom crypto. This
        // answers App Store Connect's export-compliance question at upload
        // time instead of prompting for it on every build.
        infoPlist: {
          ITSAppUsesNonExemptEncryption: false
        }
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
      plugins: [
        'expo-secure-store',
        'expo-dev-client',
        ['expo-camera', {
          cameraPermission: 'TempleMate uses your camera only to scan a temple QR code.',
          recordAudioAndroid: false
        }],
        'expo-updates'
      ],
      // Pinned as a literal string, not a { policy: 'appVersion' } object --
      // mirrors DojoMate-Expo's proven config/base.cjs pattern. The object-
      // policy form is schema-valid but was silently dropped by this repo's
      // build pipeline when it lived one level too deep (see git history);
      // pinning the literal value removes that whole class of failure
      // instead of trusting the policy resolves the same way every time.
      runtimeVersion: versioning.appVersion,
      updates: {
        url: 'https://u.expo.dev/c7b8523a-2fad-4123-bc96-0c0c85a23dec',
        enabled: true,
        fallbackToCacheTimeout: 0,
        requestHeaders: release?.easUpdateChannel
          ? { 'expo-channel-name': release.easUpdateChannel }
          : undefined
      },
      extra: {
        eas: {
          projectId: 'c7b8523a-2fad-4123-bc96-0c0c85a23dec'
        },
        // Dummy is network-free by default. Real mode is an intentional local/test
        // selection and is invalid without both values; neither is a secret.
        clientMode: release?.clientMode || (process.env.TEMPLEMATE_CLIENT_MODE === 'real' ? 'real' : 'dummy'),
        apiBaseUrl: release?.apiBaseUrl || process.env.TEMPLEMATE_LOCAL_API_BASE_URL || '',
        tenantSlug: release?.tenantSlug || process.env.TEMPLEMATE_LOCAL_TENANT_SLUG || '',
        clientEnvironment: release?.clientEnvironment || process.env.TEMPLEMATE_CLIENT_ENVIRONMENT || 'development',
        easUpdateChannel: release?.easUpdateChannel || 'development',
        nativeOAuthReturnUrl,
        supportedLocales: ['zh-TW', 'en'],
        supportedThemes: ['light', 'dark'],
        android16TargetSdk: 36
      }
    }
  };
};
