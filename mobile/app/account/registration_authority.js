const editableFields = Object.freeze(['quantity', 'registrant_scope', 'dependent_id', 'contact_name', 'contact_phone', 'contact_email', 'household_notes', 'arrival_window', 'ceremony_notes']);

const requiredOffering = offering => offering && offering.id != null && offering.slug && offering.title && offering.account_action && Number.isInteger(offering.price_cents) && offering.currency;

function offeringCatalog(snapshot = {}) {
  return [...(snapshot.events || []), ...(snapshot.services || []), ...(snapshot.gatherings || [])]
    .filter(requiredOffering)
    .map(offering => ({ ...offering, id: String(offering.id) }));
}

function cleanRegistration(input = {}) {
  return editableFields.reduce((result, key) => {
    if (input[key] !== undefined && input[key] !== null && input[key] !== '') result[key] = input[key];
    return result;
  }, {});
}

function registrantChoices({ profile, dependents = [] }, serverChoices = []) {
  if (serverChoices.length) return serverChoices.map(choice => ({ ...choice, id: String(choice.id) }));
  return [
    { scope: 'self', id: String(profile.id), label: profile.name },
    ...dependents.map(dependent => ({ scope: 'dependent', id: String(dependent.dependentId || dependent.id), label: dependent.name }))
  ];
}

function preparedRegistration({ offering, registration = {}, registrants = [], snapshot }) {
  if (!requiredOffering(offering)) throw Object.assign(new Error('A temple offering is required.'), { code: 'offering_not_found' });
  const choices = registrantChoices(snapshot, registrants);
  const self = choices.find(choice => choice.scope === 'self');
  return {
    id: null,
    offering: { id: String(offering.id), slug: offering.slug, title: offering.title, account_action: offering.account_action, price_cents: offering.price_cents, currency: offering.currency },
    registrants: choices,
    registration: { quantity: 1, registrant_scope: self ? 'self' : registration.registrant_scope || 'self', contact_name: snapshot?.profile?.name || '', ...cleanRegistration(registration) }
  };
}

function selectRegistrant(prepared, choice) {
  if (!prepared?.registrants?.some(item => item.scope === choice.scope && String(item.id) === String(choice.id))) throw Object.assign(new Error('Registrant is unavailable.'), { code: 'registrant_not_found' });
  return {
    ...prepared,
    registration: {
      ...prepared.registration,
      registrant_scope: choice.scope,
      ...(choice.scope === 'dependent' ? { dependent_id: String(choice.id) } : { dependent_id: undefined })
    }
  };
}

function createInput(prepared) {
  if (!prepared?.offering) throw Object.assign(new Error('A prepared offering is required.'), { code: 'offering_not_found' });
  return {
    offering: prepared.offering.slug,
    accountAction: prepared.offering.account_action,
    registration: cleanRegistration(prepared.registration)
  };
}

function updateInput(prepared) {
  return { registration: cleanRegistration(prepared?.registration) };
}

module.exports = { cleanRegistration, createInput, offeringCatalog, preparedRegistration, registrantChoices, selectRegistrant, updateInput };
