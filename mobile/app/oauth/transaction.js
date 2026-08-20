const providers = new Set(['google', 'apple']);
const phases = new Set(['idle', 'pending', 'browser_opened', 'returned', 'exchanging', 'authenticated', 'profile_required', 'cancelled', 'denied', 'failed', 'invalid', 'expired', 'interrupted', 'closed', 'account_resolution']);

const safeUrl = value => { try { return new URL(value); } catch (_) { return null; } };
const returnMatches = (actual, expected) => {
  const actualUrl = safeUrl(actual); const expectedUrl = safeUrl(expected);
  return Boolean(actualUrl && expectedUrl && actualUrl.protocol === expectedUrl.protocol && actualUrl.host === expectedUrl.host && actualUrl.pathname === expectedUrl.pathname);
};
const terminalBrowserResult = result => {
  if (result?.type === 'cancel') return 'cancelled';
  if (result?.type === 'dismiss' || result?.type === 'interrupted') return 'interrupted';
  return 'failed';
};
const validPending = (record, expectedReturnUrl) => record && providers.has(record.provider) && record.redirectUri === expectedReturnUrl && typeof record.transactionToken === 'string' && record.transactionToken.length > 0 && typeof record.verifier === 'string' && record.verifier.length >= 43 && Number.isFinite(record.createdAt) && Number.isFinite(record.expiresAt);

function createOAuthController({ adapter, createPkce, openBrowser, expectedReturnUrl, now = () => Date.now(), onStateChange = () => {} }) {
  if (!adapter?.oauthStorage || typeof adapter.startOAuth !== 'function' || typeof adapter.exchangeOAuth !== 'function') throw new Error('OAuth adapter is incomplete.');
  if (typeof createPkce !== 'function' || typeof openBrowser !== 'function' || !safeUrl(expectedReturnUrl)) throw new Error('OAuth runtime is incomplete.');
  let state = { phase: 'idle', provider: null, detail: null };
  let returnInFlight = null;
  const setState = (phase, provider = null, detail = null) => { if (!phases.has(phase)) throw new Error('Unknown OAuth state.'); state = { phase, provider, detail }; onStateChange({ ...state }); return state; };
  const clear = async (phase = 'idle', provider = null, detail = null) => { await adapter.oauthStorage.clearPending(); return setState(phase, provider, detail); };
  const recordFor = (provider, started, pkce) => ({ provider, redirectUri: expectedReturnUrl, transactionToken: started.transaction_token, verifier: pkce.verifier, createdAt: now(), expiresAt: now() + Number(started.expires_in) * 1000 });
  const validExchangeResult = (result, provider) => Boolean(result?.snapshot && typeof result.snapshot === 'object' && result.snapshot.profile && typeof result.snapshot.profile === 'object' && result?.oauth?.provider === provider && providers.has(result.oauth.provider) && typeof result.oauth.profile_required === 'boolean');
  const rejectExchange = async (provider, detail) => {
    // The real adapter may have received and retained a session before this
    // controller can verify the client-facing exchange envelope. Never retain
    // that session when the envelope is malformed or correlated to another provider.
    if (typeof adapter.clearOAuthSession === 'function') await adapter.clearOAuthSession();
    else if (typeof adapter.clearTenantState === 'function') await adapter.clearTenantState();
    return clear('failed', provider, detail);
  };

  async function handleReturn(url) {
    if (returnInFlight) return returnInFlight;
    const process = (async () => {
    const record = await adapter.oauthStorage.loadPending();
    if (!validPending(record, expectedReturnUrl)) return clear('invalid', null, 'unsolicited_callback');
    if (record.expiresAt <= now()) return clear('expired', record.provider, 'expired_transaction');
    if (!returnMatches(url, expectedReturnUrl)) return clear('invalid', record.provider, 'unexpected_return');
    const parsed = safeUrl(url);
    const providerError = parsed.searchParams.get('error');
    if (providerError) return clear(providerError === 'access_denied' ? 'denied' : 'failed', record.provider, providerError);
    const code = parsed.searchParams.get('code');
    if (!code) return clear('invalid', record.provider, 'missing_code');
    // Consume before exchange so an interrupted/replayed callback cannot reuse a code or verifier.
    await adapter.oauthStorage.clearPending();
    setState('returned', record.provider);
    setState('exchanging', record.provider);
    try {
      const result = await adapter.exchangeOAuth({ code, transactionToken: record.transactionToken, pkceVerifier: record.verifier });
      if (!validExchangeResult(result, record.provider)) return rejectExchange(record.provider, 'invalid_exchange_response');
      return setState(result.oauth.profile_required ? 'profile_required' : 'authenticated', record.provider);
    } catch (error) {
      // Unmatched identity: the exchange envelope is real (Rails returned a
      // resolution_token, not a session), so no session was ever applied --
      // nothing to clear. Stay pre-auth in a dedicated phase instead of
      // failing; the resolution_token is kept in memory only (state.detail),
      // never written to storage or logs, same discipline as the pending
      // PKCE record above.
      if (error?.code === 'account_resolution_required' && error?.oauth?.resolution_token) return setState('account_resolution', record.provider, error.oauth.resolution_token);
      if (typeof adapter.clearOAuthSession === 'function') await adapter.clearOAuthSession();
      else if (typeof adapter.clearTenantState === 'function') await adapter.clearTenantState();
      return clear(error?.code === 'account_closed' ? 'closed' : 'failed', record.provider, error?.code || 'exchange_failed');
    }
    })();
    returnInFlight = process;
    process.then(
      () => { if (returnInFlight === process) returnInFlight = null; },
      () => { if (returnInFlight === process) returnInFlight = null; }
    );
    return process;
  }

  // A Linking event is a recovery path only. The normal browser result is
  // exclusively handled by begin() so one return cannot be exchanged twice.
  const handleInterruptedReturn = url => state.phase === 'interrupted' ? handleReturn(url) : Promise.resolve({ ...state });

  async function begin(provider) {
    if (!providers.has(provider)) return clear('invalid', null, 'unsupported_provider');
    await adapter.oauthStorage.clearPending();
    setState('pending', provider);
    try {
      const pkce = await createPkce();
      const started = await adapter.startOAuth({ provider, pkceChallenge: pkce.challenge, pkceMethod: pkce.method });
      if (!started || started.provider !== provider || started.redirect_uri !== expectedReturnUrl || typeof started.authorization_url !== 'string' || typeof started.transaction_token !== 'string' || !Number.isFinite(Number(started.expires_in)) || Number(started.expires_in) <= 0) return clear('failed', provider, 'invalid_start_response');
      await adapter.oauthStorage.savePending(recordFor(provider, started, pkce));
      setState('browser_opened', provider);
      const browserResult = await openBrowser(started.authorization_url, expectedReturnUrl);
      if (browserResult?.type === 'success' && typeof browserResult.url === 'string') return handleReturn(browserResult.url);
      const terminal = terminalBrowserResult(browserResult);
      if (terminal === 'interrupted') return setState('interrupted', provider, 'browser_interrupted');
      return clear(terminal, provider, browserResult?.type || 'browser_failed');
    } catch (error) {
      return clear('failed', provider, error?.code || 'start_failed');
    }
  }

  // Completes an in-progress account_resolution (link to an existing account,
  // or create a new one) once Rails exposes a native consuming endpoint. On
  // failure this rejects rather than swallowing the error, matching the rest
  // of this controller's philosophy: only genuinely unexpected errors
  // propagate as rejections, but here the caller (App.js) drives its own
  // pending/error UI the same way it does for every other adapter action
  // (via the shared `run` helper), so staying in account_resolution on
  // failure and letting the caller show the reason is the right shape --
  // unlike begin()/handleReturn(), which are fire-and-forget browser flows
  // with no per-attempt form the user is actively editing.
  async function consumeResolution({ mode, email, password, name, termsAccepted }) {
    if (state.phase !== 'account_resolution') throw new Error('No account resolution is in progress.');
    if (typeof adapter.consumeOAuthResolution !== 'function') throw new Error('This adapter cannot complete account resolution.');
    const provider = state.provider; const resolutionToken = state.detail;
    const result = await adapter.consumeOAuthResolution({ mode, provider, resolutionToken, email, password, name, termsAccepted });
    if (!validExchangeResult(result, provider)) return rejectExchange(provider, 'invalid_resolution_response');
    return setState(result.oauth.profile_required ? 'profile_required' : 'authenticated', provider);
  }

  async function restore() {
    const record = await adapter.oauthStorage.loadPending();
    if (!record) return setState('idle');
    if (!validPending(record, expectedReturnUrl)) return clear('invalid', null, 'invalid_pending');
    if (record.expiresAt <= now()) return clear('expired', record.provider, 'expired_transaction');
    return setState('interrupted', record.provider, 'pending_return');
  }

  return { begin, handleReturn, handleInterruptedReturn, restore, clear, consumeResolution, snapshot: () => ({ ...state }) };
}

module.exports = { createOAuthController, returnMatches, validPending, providers };
