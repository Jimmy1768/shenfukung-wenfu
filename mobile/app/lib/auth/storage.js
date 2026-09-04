import * as SecureStore from 'expo-secure-store';

const memoryStore = {};
const scopedKey = (environment = 'development', tenantId = 'unbound', name) =>
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
export const scopedStorage = { setItem, getItem, deleteItem };

export { scopedKey };
