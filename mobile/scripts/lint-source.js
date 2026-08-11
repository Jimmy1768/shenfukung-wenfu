const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..', 'app');
const forbidden = /fetch\(|Stripe|ECPay|checkout|OAuth|golden-template|\.admin\b/i;
const files = [];
const walk = dir => fs.readdirSync(dir, { withFileTypes: true }).forEach(entry => {
  const target = path.join(dir, entry.name);
  if (entry.isDirectory()) walk(target);
  else if (entry.name.endsWith('.js')) files.push(target);
});
walk(root);
const failures = files.filter(file => forbidden.test(fs.readFileSync(file, 'utf8')));
const liveOriginFailures = files.filter(file => {
  const relative = path.relative(root, file);
  if (relative === path.join('dummy', 'fixtures.js') || relative === path.join('tenant', 'binding.js')) return false;
  return /https?:\/\//i.test(fs.readFileSync(file, 'utf8'));
});
failures.push(...liveOriginFailures);
if (failures.length) {
  console.error(`forbidden dummy-client residue in: ${failures.map(file => path.relative(root, file)).join(', ')}`);
  process.exit(1);
}
console.log(`source lint passed for ${files.length} mobile app modules.`);
