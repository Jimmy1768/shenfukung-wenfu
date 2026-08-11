import * as SecureStore from 'expo-secure-store';

const memoryStore = {};
const scopedKey = (environment = 'dummy', tenantId = 'unbound', name) =>
  `templemate.${environment}.${tenantId}.${name}`;

const setItem = async (key, value) => {
  if (!value) return deleteItem(key);
  try {
    await SecureStore.setItemAsync(key, value);
  } catch (_) {
    memoryStore[key] = value;
  }
};
const getItem = async key => {
  try {
    const value = await SecureStore.getItemAsync(key);
    if (value !== null && value !== undefined) return value;
  } catch (_) {}
  return memoryStore[key] ?? null;
};
const deleteItem = async key => {
  try { await SecureStore.deleteItemAsync(key); } catch (_) { delete memoryStore[key]; }
};

export async function persistDummySession({ environment, tenantId, session }) {
  return setItem(scopedKey(environment, tenantId, 'dummy-session'), JSON.stringify(session));
}
export async function loadDummySession({ environment, tenantId }) {
  const raw = await getItem(scopedKey(environment, tenantId, 'dummy-session'));
  return raw ? JSON.parse(raw) : null;
}
export async function clearDummySession({ environment, tenantId }) {
  return deleteItem(scopedKey(environment, tenantId, 'dummy-session'));
}
export { scopedKey };
