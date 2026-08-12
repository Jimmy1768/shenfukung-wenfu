import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import * as Crypto from 'expo-crypto';
import { base64ToBase64Url, verifierFromBytes } from './pkce';

export function createExpoOAuthRuntime(expectedReturnUrl) {
  const redirectUri = AuthSession.makeRedirectUri({ scheme: 'templemate', path: 'oauth/complete', isTripleSlashed: false });
  if (redirectUri !== expectedReturnUrl) throw new Error('Configured OAuth return URL does not match the native scheme.');
  return {
    createPkce: async () => {
      const verifier = verifierFromBytes(await Crypto.getRandomBytesAsync(32));
      const digest = await Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, verifier, { encoding: Crypto.CryptoEncoding.BASE64 });
      const challenge = base64ToBase64Url(digest);
      return { verifier, challenge, method: 'S256' };
    },
    openBrowser: (authorizationUrl, returnUrl) => WebBrowser.openAuthSessionAsync(authorizationUrl, returnUrl)
  };
}
