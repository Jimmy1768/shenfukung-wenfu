// Hex is PKCE's unreserved character set and avoids a Node Buffer dependency in
// the native runtime while still retaining 256 bits of entropy.
const verifierFromBytes = bytes => Array.from(bytes).map(byte => Number(byte).toString(16).padStart(2, '0')).join('');

const validVerifier = verifier => typeof verifier === 'string' && verifier.length >= 43 && verifier.length <= 128 && /^[A-Za-z0-9\-._~]+$/.test(verifier);
const validChallenge = challenge => typeof challenge === 'string' && /^[A-Za-z0-9_-]{43}$/.test(challenge);
const base64ToBase64Url = value => {
  if (typeof value !== 'string' || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(value)) throw new Error('PKCE SHA-256 digest encoding failed.');
  const challenge = value.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  if (!validChallenge(challenge)) throw new Error('PKCE S256 challenge generation failed.');
  return challenge;
};

async function createPkce({ randomBytes, sha256 }) {
  if (typeof randomBytes !== 'function' || typeof sha256 !== 'function') throw new Error('PKCE requires injected random and SHA-256 functions.');
  const verifier = verifierFromBytes(await randomBytes(32));
  if (!validVerifier(verifier)) throw new Error('PKCE verifier generation failed.');
  const challenge = await sha256(verifier);
  if (!validChallenge(challenge)) throw new Error('PKCE S256 challenge generation failed.');
  return { verifier, challenge, method: 'S256' };
}

module.exports = { verifierFromBytes, validVerifier, validChallenge, base64ToBase64Url, createPkce };
