const { execFileSync } = require('node:child_process');

const lanes = Object.freeze({ testflight: 'testflight', production: 'production' });

// Mirrors DojoMate-Expo's proven scripts/publish-ota.mjs LANE_CONFIG.env
// pattern: the publish invocation sets its own lane env explicitly rather
// than trusting whatever the calling shell happens to have set. This is
// the actual fix for a real incident (2026-08-20) -- a publish run without
// an explicit BUILD_MODE silently fell back to app.config.js's development
// default, publishing a dev-identity bundle (wrong bundleIdentifier, name,
// icon) under the testflight channel. Keep this in sync with the matching
// `build:*` profile's `env` block in eas.json; a guardrail check enforces
// that (scripts/check-ota-lane-guardrails.js).
const LANE_ENV = Object.freeze({
  testflight: Object.freeze({
    BUILD_MODE: 'testflight',
    EAS_BUILD_PROFILE: 'testflight',
    TEMPLEMATE_CLIENT_ENVIRONMENT: 'testflight'
  }),
  production: Object.freeze({
    BUILD_MODE: 'production',
    EAS_BUILD_PROFILE: 'production',
    TEMPLEMATE_CLIENT_ENVIRONMENT: 'production'
  })
});

function verify({ lane, message, productionScope, environment, dirty = false, sourceCommit, runtimeVersion = '1.0.0', releaseReceipt = false }) {
  if (!lanes[lane] || !String(message || '').trim()) throw new Error('A known lane and nonblank message are required.');
  if (lane === 'production' && productionScope !== 'production') throw new Error('Production publication requires the explicit production scope token.');
  if (!['testflight', 'production'].includes(environment) || dirty || !sourceCommit || !releaseReceipt) throw new Error('Release source attribution, clean state, and receipt are required.');
  return { lane, branch: lanes[lane], runtimeVersion, sourceCommit, message: String(message).trim() };
}

function main(argv = process.argv.slice(2), invoke = execFileSync) {
  const [lane, message, scope] = argv;
  const sourceCommit = process.env.TEMPLEMATE_SOURCE_COMMIT;
  const environment = process.env.TEMPLEMATE_CLIENT_ENVIRONMENT;
  const dirty = process.env.TEMPLEMATE_DIRTY === '1';
  const releaseReceipt = process.env.TEMPLEMATE_RELEASE_RECEIPT === 'accepted';
  const checked = verify({ lane, message, productionScope: scope, environment, dirty, sourceCommit, releaseReceipt });
  console.log(JSON.stringify(checked));

  const laneEnv = LANE_ENV[checked.lane];
  invoke('/opt/homebrew/bin/eas', ['update', '--branch', checked.branch, '--message', checked.message], {
    stdio: 'inherit',
    env: { ...process.env, ...laneEnv }
  });
}

if (require.main === module) main();
module.exports = { verify, main, lanes, LANE_ENV };
