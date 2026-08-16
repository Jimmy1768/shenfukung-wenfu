const fs = require('node:fs'); const path = require('node:path');
const root = path.resolve(__dirname, '..'); const eas = require(path.join(root, 'eas.json'));
for (const lane of ['testflight', 'production']) {
  const profile = eas.build?.[lane];
  if (!profile || profile.channel !== lane || profile.distribution !== 'store' || profile.env?.TEMPLEMATE_CLIENT_MODE !== 'real' || profile.env?.TEMPLEMATE_PUBLIC_API_ORIGIN !== 'https://shengfukung.com.tw' || profile.env?.TEMPLEMATE_PUBLIC_TENANT_SLUG !== 'shengfukung-wenfu') throw new Error(`Invalid ${lane} release interface.`);
}
const source = fs.readFileSync(path.join(__dirname, 'verify-ota-lane.js'), 'utf8');
if (!source.includes("productionScope !== 'production'") || !source.includes("lanes[lane]")) throw new Error('OTA guardrail is incomplete.');
console.log('release interface verification passed');
