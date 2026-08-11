const { clone, seed } = require('./fixtures');

const required = value => typeof value === 'string' && value.trim().length > 0;
const validationError = (field, message) => ({ code: 'VALIDATION', field, message });

function createDummyRepository(initial = seed) {
  let state = clone(initial);
  let nextDependentNumber = state.dependents.length + 1;
  let nextRegistrationNumber = state.registrations.length + 1;
  const snapshot = () => clone(state);
  return {
    snapshot,
    reset() {
      state = clone(initial);
      nextDependentNumber = state.dependents.length + 1;
      nextRegistrationNumber = state.registrations.length + 1;
      return snapshot();
    },
    signIn({ email, password }) {
      if (!required(email)) throw validationError('email', '請輸入電子郵件');
      if (!required(password)) throw validationError('password', '請輸入密碼');
      if (email.trim().toLowerCase() !== initial.profile.email || password !== 'templemate-demo') throw validationError('form', '示範帳號或密碼不正確');
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
    createRegistration({ offering, registrantName }) {
      if (!required(offering)) throw validationError('offering', '請選擇項目');
      if (!required(registrantName)) throw validationError('registrantName', '請選擇登記人');
      const id = `registration-${String(nextRegistrationNumber++).padStart(3, '0')}`;
      state.registrations.push({ id, offering: offering.trim(), registrantName: registrantName.trim(), state: 'draft', readOnly: false });
      return snapshot();
    },
    updateRegistration(id, { offering, registrantName }) {
      const registration = state.registrations.find(item => item.id === id);
      if (!registration) throw validationError('registration', '找不到登記資料');
      if (registration.readOnly) throw validationError('registration', '此示範已完成項目僅供閱讀');
      if (!required(offering) || !required(registrantName)) throw validationError('registration', '請完成登記資料');
      registration.offering = offering.trim(); registration.registrantName = registrantName.trim();
      return snapshot();
    }
  };
}

module.exports = { createDummyRepository };
