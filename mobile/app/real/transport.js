// The only network seam in the client. It is injected into the real adapter and
// receives a configuration that has already been restricted to local/test.
async function localTestTransport(request) {
  const response = await globalThis.fetch(request.url, { method: request.method, headers: request.headers, body: request.body });
  let body = {};
  try { body = await response.json(); } catch (_) {}
  return { ok: response.ok, status: response.status, body };
}
module.exports = { localTestTransport };
