const resourceNames = ['session', 'cache', 'pending'];
const keyFor = (scope, name) => `templemate.${scope.environment}.${scope.tenantId}.real-${name}`;
const sessionKey = scope => keyFor(scope, 'session');

function createScopedStorage(store, scope) {
  if (!store || typeof store.getItem !== 'function' || typeof store.setItem !== 'function' || typeof store.deleteItem !== 'function') throw new Error('A scoped local storage implementation is required.');
  return {
    async loadSession() { const raw = await store.getItem(sessionKey(scope)); return raw ? JSON.parse(raw) : null; },
    saveSession(session) { return store.setItem(sessionKey(scope), JSON.stringify(session)); },
    clearSession() { return store.deleteItem(sessionKey(scope)); },
    async clearAll() { await Promise.all(resourceNames.map(name => store.deleteItem(keyFor(scope, name)))); }
  };
}
module.exports = { createScopedStorage, sessionKey, keyFor };
