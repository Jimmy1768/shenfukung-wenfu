// Hex is PKCE's unreserved character set and avoids a Node Buffer dependency in
// the native runtime while still retaining 256 bits of entropy.
const verifierFromBytes = bytes => Array.from(bytes).map(byte => Number(byte).toString(16).padStart(2, '0')).join('');

const validVerifier = verifier => typeof verifier === 'string' && verifier.length >= 43 && verifier.length <= 128 && /^[A-Za-z0-9\-._~]+$/.test(verifier);

async function createPkce({ randomBytes, sha256 }) {
  if (typeof randomBytes !== 'function' || typeof sha256 !== 'function') throw new Error('PKCE requires injected random and SHA-256 functions.');
  const verifier = verifierFromBytes(await randomBytes(32));
  if (!validVerifier(verifier)) throw new Error('PKCE verifier generation failed.');
  const challenge = await sha256(verifier);
  if (typeof challenge !== 'string' || !/^[A-Za-z0-9_-]{43}$/.test(challenge)) throw new Error('PKCE S256 challenge generation failed.');
  return { verifier, challenge, method: 'S256' };
}

module.exports = { verifierFromBytes, validVerifier, createPkce };
