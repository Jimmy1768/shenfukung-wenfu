const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const { sourceFailures, liveOriginFailures, allowedTransport } = require('../scripts/lint-source');

test('source lint permits fetch only in the local/test real transport and rejects unsafe residue elsewhere', () => {
  // Any module that is not the permitted transport seam.
  const otherModule = path.join(path.dirname(allowedTransport), '..', 'tenant', 'scanner.js');
  assert.deepEqual(sourceFailures([{ file: otherModule, source: 'globalThis.fetch("x")' }]), [{ file: otherModule, source: 'globalThis.fetch("x")' }]);
  assert.deepEqual(sourceFailures([{ file: allowedTransport, source: 'globalThis.fetch(request.url)' }]), []);
  assert.equal(sourceFailures([{ file: otherModule, source: 'const scope = "admin"' }]).length, 1);
  // OAuth vocabulary is permitted only in the modules that own the flow.
  const oauthOwner = path.join(path.dirname(allowedTransport), 'adapter.js');
  assert.equal(sourceFailures([{ file: oauthOwner, source: 'const mode = "OAuth"' }]).length, 0);
  assert.equal(sourceFailures([{ file: path.join(path.dirname(otherModule), 'binding.js'), source: 'const mode = "OAuth"' }]).length, 1);
  assert.equal(sourceFailures([{ file: otherModule, source: 'const action = "checkout"' }]).length, 1);
  assert.equal(liveOriginFailures([{ file: otherModule, source: 'const origin = "https://example.com"' }]).length, 1);
  const realConfig = path.join(path.dirname(allowedTransport), 'config.js');
  assert.equal(liveOriginFailures([{ file: realConfig, source: 'const origin = "https://shengfukung.com.tw"' }]).length, 0);
});
