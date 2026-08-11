const knownEnvironments = Object.freeze(['development', 'test', 'production']);

const resolveEnvironmentKey = explicit => {
  const candidate = String(explicit || process.env.APP_ENV || process.env.BUILD_MODE || 'development').trim().toLowerCase();
  return knownEnvironments.includes(candidate) ? candidate : 'development';
};

const buildStorageScope = ({ environment, tenantId }) => ({
  environment: resolveEnvironmentKey(environment),
  tenantId: tenantId || 'unbound'
});

module.exports = { knownEnvironments, resolveEnvironmentKey, buildStorageScope };
