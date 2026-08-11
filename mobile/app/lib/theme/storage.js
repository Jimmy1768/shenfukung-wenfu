import * as SecureStore from 'expo-secure-store';

const memoryStore = {};
const keyFor = (environment = 'dummy', tenantId = 'unbound') => `templemate.${environment}.${tenantId}.theme`;
const get = async key => {
  try { return (await SecureStore.getItemAsync(key)) ?? memoryStore[key] ?? null; } catch (_) { return memoryStore[key] ?? null; }
};
const set = async (key, value) => {
  try { await SecureStore.setItemAsync(key, value); } catch (_) { memoryStore[key] = value; }
};

export async function loadThemePreference(scope) { return get(keyFor(scope?.environment, scope?.tenantId)); }
export async function persistThemePreference(themeId, scope) { return set(keyFor(scope?.environment, scope?.tenantId), themeId); }
export async function clearThemePreference(scope) { return set(keyFor(scope?.environment, scope?.tenantId), ''); }
