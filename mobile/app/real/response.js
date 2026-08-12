const messageFor = code => ({
  validation_failed: 'Please review the highlighted fields.', invalid_credentials: 'Email or password is incorrect.',
  session_invalid: 'Your session is no longer valid.', session_replayed: 'Your session was replayed and has been cleared.',
  session_revoked: 'Your session has been revoked.', account_closed: 'This account is closed.',
  tenant_not_found: 'The selected temple was not found.', tenant_required: 'A temple is required.',
  not_found: 'The requested record was not found.', registration_intake_frozen: 'Registration is currently unavailable.',
  registration_not_editable: 'This registration can no longer be edited.', invalid_preferences: 'Preferences are invalid.'
}[code] || 'The request could not be completed.');

function nativeError(status, body = {}) {
  const code = body.code || body.error || (status === 401 ? 'session_invalid' : status === 404 ? 'not_found' : 'request_failed');
  const error = new Error(messageFor(code));
  error.code = code;
  error.status = status;
  error.details = body.details || null;
  return error;
}

const nameFor = user => user?.native_name || user?.english_name || user?.email || '';
const mapDependent = item => ({ id: String(item.id), dependentId: item.dependent_id ? String(item.dependent_id) : String(item.id), name: item.native_name || item.english_name || '', relationship: item.relationship_label || '' });
const mapRegistration = item => {
  const offering = item.offering || {};
  const lifecycle = item.lifecycle || item.fulfillment_status || item.status || 'pending';
  return {
    id: String(item.id), offering: { id: offering.id ? String(offering.id) : '', slug: offering.slug || '', title: offering.title || '', account_action: offering.account_action || '', price_cents: offering.price_cents ?? item.unit_price_cents ?? 0, currency: offering.currency || item.currency || '' }, registrantName: item.registrant_name || '', registrantScope: item.registrant_scope || 'self', dependentId: item.dependent_id ? String(item.dependent_id) : null, quantity: item.quantity || 1, totalAmountCents: item.total_amount_cents ?? 0,
    state: lifecycle, lifecycle, paymentState: item.payment_state || item.payment_status || null,
    readOnly: ['completed', 'fulfilled', 'cancelled'].includes(lifecycle)
  };
};
function snapshotFromBootstrap(payload = {}) {
  const user = payload.user || {};
  return {
    profile: { id: user.id ? String(user.id) : '', email: user.email || '', name: nameFor(user), user },
    dependents: (payload.dependents || []).map(mapDependent),
    registrations: (payload.registrations || []).map(mapRegistration),
    certificates: payload.certificates || [], events: payload.events || [], services: payload.services || [], gatherings: payload.gatherings || [], gallery: payload.galleries || [],
    preferences: payload.preferences || {}, temple: payload.temple || null
  };
}
const collectionFrom = (payload, name) => payload?.[name] || [];
module.exports = { nativeError, snapshotFromBootstrap, mapDependent, mapRegistration, nameFor, collectionFrom };
