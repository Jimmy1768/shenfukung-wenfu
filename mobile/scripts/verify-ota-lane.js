const { execFileSync } = require('node:child_process');
const lanes = Object.freeze({ testflight: 'testflight', production: 'production' });
function verify({ lane, message, productionScope, environment, dirty = false, sourceCommit, runtimeVersion = '1.0.0', releaseReceipt = false }) {
  if (!lanes[lane] || !String(message || '').trim()) throw new Error('A known lane and nonblank message are required.');
  if (lane === 'production' && productionScope !== 'production') throw new Error('Production publication requires the explicit production scope token.');
  if (!['testflight', 'production'].includes(environment) || dirty || !sourceCommit || !releaseReceipt) throw new Error('Release source attribution, clean state, and receipt are required.');
  return { lane, branch: lanes[lane], runtimeVersion, sourceCommit, message: String(message).trim() };
}
function main(argv = process.argv.slice(2), invoke = execFileSync) {
  const [lane, message, scope] = argv; const sourceCommit = process.env.TEMPLEMATE_SOURCE_COMMIT; const environment = process.env.TEMPLEMATE_CLIENT_ENVIRONMENT;
  const dirty = process.env.TEMPLEMATE_DIRTY === '1'; const releaseReceipt = process.env.TEMPLEMATE_RELEASE_RECEIPT === 'accepted';
  const checked = verify({ lane, message, productionScope: scope, environment, dirty, sourceCommit, releaseReceipt });
  console.log(JSON.stringify(checked));
  invoke('/opt/homebrew/bin/eas', ['update', '--branch', checked.branch, '--message', checked.message], { stdio: 'inherit' });
}
if (require.main === module) main();
module.exports = { verify, main, lanes };
