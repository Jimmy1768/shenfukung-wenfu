const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const { sourceFailures, liveOriginFailures, allowedTransport } = require('../scripts/lint-source');

test('source lint permits fetch only in the local/test real transport and rejects unsafe residue elsewhere', () => {
  const dummy = path.join(path.dirname(allowedTransport), '..', 'dummy', 'adapter.js');
  assert.deepEqual(sourceFailures([{ file: dummy, source: 'globalThis.fetch("x")' }]), [{ file: dummy, source: 'globalThis.fetch("x")' }]);
  assert.deepEqual(sourceFailures([{ file: allowedTransport, source: 'globalThis.fetch(request.url)' }]), []);
  assert.equal(sourceFailures([{ file: dummy, source: 'const scope = "admin"' }]).length, 1);
  assert.equal(sourceFailures([{ file: dummy, source: 'const mode = "OAuth"' }]).length, 1);
  assert.equal(sourceFailures([{ file: dummy, source: 'const action = "checkout"' }]).length, 1);
  assert.equal(liveOriginFailures([{ file: dummy, source: 'const origin = "https://example.com"' }]).length, 1);
});
