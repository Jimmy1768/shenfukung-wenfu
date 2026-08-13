const { clone, seed } = require('./fixtures');

const required = value => typeof value === 'string' && value.trim().length > 0;
const validationError = (field, message) => ({ code: 'VALIDATION', field, message });

const catalog = state => [...(state.events || []), ...(state.services || []), ...(state.gatherings || [])];
const offeringFor = (state, input = {}) => {
  const reference = input && typeof input === 'object' ? input : { offering: input };
  const suppliedOffering = reference.offering;
  const identity = suppliedOffering && typeof suppliedOffering === 'object' ? suppliedOffering : reference;
  const id = identity.id ?? identity.offering_id;
  const slug = identity.slug ?? (typeof suppliedOffering === 'string' ? suppliedOffering : undefined);
  const action = identity.account_action ?? identity.accountAction ?? reference.account_action ?? reference.accountAction;
  if (!required(action) || (!required(id) && !required(slug))) return undefined;

  return catalog(state).find(item => (
    item.account_action === action
    && (!required(id) || String(item.id) === String(id))
    && (!required(slug) || item.slug === slug || (!required(id) && String(item.id) === String(slug)))
  ));
};
const registrantFor = (state, registration = {}) => {
  if (registration.registrant_scope !== 'dependent') return { scope: 'self', id: state.profile.id, name: state.profile.name };
  const dependent = state.dependents.find(item => String(item.id) === String(registration.dependent_id));
  return dependent && { scope: 'dependent', id: dependent.id, name: dependent.name };
};
const validQuantity = value => Number.isInteger(Number(value)) && Number(value) > 0 && Number(value) <= 10;
const duplicateFor = (state, offering, registrant, excludingId) => state.registrations.some(item => item.id !== excludingId && String(item.offering.id) === String(offering.id) && item.registrantScope === registrant.scope && String(item.dependentId || '') === String(registrant.scope === 'dependent' ? registrant.id : ''));
const editPayloadFor = registration => ({
  id: registration.id,
  offering: clone(registration.offering),
  quantity: registration.quantity,
  registrant_scope: registration.registrantScope,
  dependent_id: registration.dependentId,
  contact_name: registration.registration?.contact_name,
  contact_phone: registration.registration?.contact_phone,
  contact_email: registration.registration?.contact_email,
  household_notes: registration.registration?.household_notes,
  arrival_window: registration.registration?.arrival_window,
  ceremony_notes: registration.registration?.ceremony_notes,
  total_amount_cents: registration.totalAmountCents,
  unit_price_cents: registration.offering.price_cents,
  currency: registration.currency,
  payment_status: registration.paymentState,
  fulfillment_status: registration.state,
  demo_cash_fixture: registration.demoCashFixture,
  read_only: registration.readOnly
});

function createDummyRepository(initial = seed) {
  let state = clone(initial);
  let credentials = { email: initial.profile.email, password: 'templemate-demo' };
  let nextDependentNumber = state.dependents.length + 1;
  let nextRegistrationNumber = state.registrations.length + 1;
  const snapshot = () => clone(state);
  return {
    snapshot,
    reset() {
      state = clone(initial);
      credentials = { email: initial.profile.email, password: 'templemate-demo' };
      nextDependentNumber = state.dependents.length + 1;
      nextRegistrationNumber = state.registrations.length + 1;
      return snapshot();
    },
    signIn({ email, password }) {
      if (!required(email)) throw validationError('email', '請輸入電子郵件');
      if (!required(password)) throw validationError('password', '請輸入密碼');
      if (email.trim().toLowerCase() !== credentials.email || password !== credentials.password) throw validationError('form', '示範帳號或密碼不正確');
      return snapshot();
    },
    signUp({ name, email, password }) {
      if (!required(name)) throw validationError('name', '請輸入姓名');
      if (!required(email)) throw validationError('email', '請輸入電子郵件');
      if (!required(password) || password.length < 8) throw validationError('password', '密碼至少需要 8 個字元');
      state.profile.name = name.trim();
      state.profile.email = email.trim().toLowerCase();
      credentials = { email: state.profile.email, password };
      state.signup = { completed: true, email: state.profile.email };
      return snapshot();
    },
    recoverPassword({ email }) {
      if (!required(email)) throw validationError('email', '請輸入電子郵件');
      state.recovery = { requested: true, email: email.trim().toLowerCase() };
      return snapshot();
    },
    updatePreferences(input) {
      state.preferences = { ...(state.preferences || {}), ...input };
      return snapshot();
    },
    updateProfile({ name }) {
      if (!required(name)) throw validationError('name', '請輸入姓名');
      state.profile.name = name.trim(); return snapshot();
    },
    createDependent({ name, relationship }) {
      if (!required(name)) throw validationError('dependentName', '請輸入家屬姓名');
      const id = `dependent-${String(nextDependentNumber++).padStart(3, '0')}`;
      state.dependents.push({ id, name: name.trim(), relationship: required(relationship) ? relationship.trim() : '家人' });
      return snapshot();
    },
    updateDependent(id, { name, relationship }) {
      const dependent = state.dependents.find(item => item.id === id);
      if (!dependent) throw validationError('dependent', '找不到家屬');
      if (!required(name)) throw validationError('dependentName', '請輸入家屬姓名');
      dependent.name = name.trim(); dependent.relationship = required(relationship) ? relationship.trim() : dependent.relationship;
      return snapshot();
    },
    deleteDependent(id) { state.dependents = state.dependents.filter(item => item.id !== id); return snapshot(); },
    newRegistration({ offering, accountAction }) {
      const selected = offeringFor(state, { offering, account_action: accountAction });
      if (!selected) throw validationError('offering', '找不到宮廟項目');
      return { offering: clone(selected), registration: { quantity: 1, registrant_scope: 'self', contact_name: state.profile.name }, registrants: [{ scope: 'self', id: state.profile.id, label: state.profile.name }, ...state.dependents.map(item => ({ scope: 'dependent', id: item.id, label: item.name }))] };
    },
    createRegistration({ offering, accountAction, registration = {} }) {
      const selected = offeringFor(state, { offering, account_action: accountAction });
      const registrant = registrantFor(state, registration);
      if (!selected) throw validationError('offering', '請選擇宮廟項目');
      if (!registrant) throw validationError('registrant', '請選擇登記人');
      if (!validQuantity(registration.quantity || 1)) throw validationError('quantity', '請確認數量');
      if (duplicateFor(state, selected, registrant)) throw validationError('registration', '此登記人已選擇這個項目');
      const id = `registration-${String(nextRegistrationNumber++).padStart(3, '0')}`;
      const quantity = Number(registration.quantity || 1);
      state.registrations.push({ id, offering: clone(selected), registrantName: registrant.name, registrantScope: registrant.scope, dependentId: registrant.scope === 'dependent' ? registrant.id : null, quantity, totalAmountCents: selected.price_cents * quantity, currency: selected.currency, state: 'pending_cash_arrangement', paymentState: 'pending_cash_arrangement', demoCashFixture: false, readOnly: false, registration: { ...registration, registrant_scope: registrant.scope, dependent_id: registrant.scope === 'dependent' ? registrant.id : undefined } });
      return snapshot();
    },
    editRegistration(id) {
      const registration = state.registrations.find(item => item.id === id);
      if (!registration) throw validationError('registration', '找不到登記資料');
      if (registration.readOnly) throw validationError('registration', '此示範已完成項目僅供閱讀');
      return { registration: editPayloadFor(registration), registrants: [{ scope: 'self', id: state.profile.id, label: state.profile.name }, ...state.dependents.map(item => ({ scope: 'dependent', id: item.id, label: item.name }))] };
    },
    updateRegistration(id, { registration: input = {} }) {
      const registration = state.registrations.find(item => item.id === id);
      if (!registration) throw validationError('registration', '找不到登記資料');
      if (registration.readOnly) throw validationError('registration', '此示範已完成項目僅供閱讀');
      const registrant = registrantFor(state, input);
      if (!registrant) throw validationError('registrant', '請選擇登記人');
      if (!validQuantity(input.quantity || registration.quantity || 1)) throw validationError('quantity', '請確認數量');
      if (duplicateFor(state, registration.offering, registrant, id)) throw validationError('registration', '此登記人已選擇這個項目');
      const quantity = Number(input.quantity || registration.quantity || 1);
      registration.registrantName = registrant.name; registration.registrantScope = registrant.scope; registration.dependentId = registrant.scope === 'dependent' ? registrant.id : null; registration.quantity = quantity; registration.totalAmountCents = registration.offering.price_cents * quantity; registration.registration = { ...registration.registration, ...input, registrant_scope: registrant.scope, dependent_id: registrant.scope === 'dependent' ? registrant.id : undefined };
      return snapshot();
    },
    submitAssistance({ message }) {
      if (!required(message)) throw validationError('message', '請說明需要的協助');
      state.assistance = { submitted: true, message: message.trim() };
      return snapshot();
    },
    contactTemple({ message }) {
      if (!required(message)) throw validationError('message', '請輸入訊息');
      state.contact = { submitted: true, message: message.trim() };
      return snapshot();
    },
    requestPrivacy({ kind }) {
      if (!['export', 'deletion'].includes(kind)) throw validationError('privacy', '請選擇隱私請求');
      state.privacyRequest = { submitted: true, kind };
      return snapshot();
    },
    closeAccount({ confirmation }) {
      if (confirmation !== 'CLOSE') throw validationError('confirmation', '請輸入 CLOSE 以確認');
      state.closed = true;
      return snapshot();
    }
  };
}

module.exports = { createDummyRepository };
