export function unsupportedRealAdapter() {
  const error = new Error('The TempleMate development client is using deterministic dummy data. A real adapter is not installed.');
  error.code = 'REAL_ADAPTER_UNAVAILABLE';
  return error;
}

export async function authenticateWithJwt() {
  throw unsupportedRealAdapter();
}

export async function refreshJwtSession() {
  throw unsupportedRealAdapter();
}

export async function revokeJwtSession() {
  return undefined;
}
