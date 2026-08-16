const { storageKey, storageScope } = require('../core/storage_scope');
const { isReleaseConfig } = require('../real/config');

const trustedBindingKey = config => storageKey(storageScope({ environment: config?.environment, tenantId: config?.tenantSlug }), 'trusted-binding');

const normalizedBinding = (binding, config) => {
  if (!isReleaseConfig(config) || binding?.state !== 'bound' || binding?.source !== 'qr') return null;
  const id = String(binding.tenant?.id || '').trim();
  const name = String(binding.tenant?.name || '').trim();
  if (!id || !name || id !== config.tenantSlug) return null;
  return { state: 'bound', tenant: { id, name }, error: null, source: 'qr' };
};

function createTrustedBindingStorage({ store, config }) {
  const key = trustedBindingKey(config);
  return {
    async load() {
      if (!isReleaseConfig(config)) return null;
      const raw = await store.getItem(key);
      if (!raw) return null;
      try {
        const binding = normalizedBinding(JSON.parse(raw), config);
        if (binding) return binding;
      } catch (_) {}
      await store.deleteItem(key);
      return null;
    },
    async save(binding) {
      const trusted = normalizedBinding(binding, config);
      if (!trusted) throw new Error('Trusted release binding is required.');
      await store.setItem(key, JSON.stringify(trusted));
      return trusted;
    },
    clear() { return store.deleteItem(key); }
  };
}

module.exports = { createTrustedBindingStorage, normalizedBinding, trustedBindingKey };
