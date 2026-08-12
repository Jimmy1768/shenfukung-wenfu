const test = require('node:test');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { base64ToBase64Url, validChallenge, verifierFromBytes } = require('../app/oauth/pkce');

const mobileRoot = path.resolve(__dirname, '..');
const runtimeSource = fs.readFileSync(path.join(mobileRoot, 'app/oauth/runtime.js'), 'utf8');
const cryptoTypes = fs.readFileSync(path.join(mobileRoot, 'node_modules/expo-crypto/build/Crypto.types.js'), 'utf8');

test('Expo SDK 54 only exposes standard Base64 and the runtime converts its SHA-256 digest to strict S256 Base64URL', () => {
  assert.match(cryptoTypes, /CryptoEncoding\["BASE64"\] = "base64"/);
  assert.doesNotMatch(cryptoTypes, /BASE64URL/);
  assert.match(runtimeSource, /Crypto\.CryptoEncoding\.BASE64/);
  assert.doesNotMatch(runtimeSource, /Crypto\.CryptoEncoding\.BASE64URL/);
  assert.match(runtimeSource, /base64ToBase64Url\(digest\)/);

  const verifier = verifierFromBytes(Uint8Array.from({ length: 32 }, (_, index) => index));
  const digest = createHash('sha256').update(verifier).digest('base64');
  const challenge = base64ToBase64Url(digest);
  assert.equal(challenge, createHash('sha256').update(verifier).digest('base64url'));
  assert.equal(validChallenge(challenge), true);
  assert.throws(() => base64ToBase64Url('not-a-standard-base64url_digest'), /PKCE SHA-256 digest encoding failed/);
});
