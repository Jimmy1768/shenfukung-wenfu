const normalizeEnvironment = value => ['development', 'test', 'production'].includes(value) ? value : 'development';
const storageScope = ({ environment, tenantId } = {}) => ({
  environment: normalizeEnvironment(environment),
  tenantId: tenantId || 'unbound'
});
const storageKey = (scope, resource) => `templemate.${scope.environment}.${scope.tenantId}.${resource}`;
module.exports = { storageScope, storageKey };
