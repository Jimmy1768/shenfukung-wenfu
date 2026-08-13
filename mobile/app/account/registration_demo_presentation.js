const PENDING_CASH_ARRANGEMENT = 'pending_cash_arrangement';
const COMPLETED_CASH_DEMO = 'completed_cash_demo';

function registrationDemoPresentation(registration = {}) {
  if (registration.readOnly === true && registration.demoCashFixture === true && registration.paymentState === COMPLETED_CASH_DEMO) {
    return { key: COMPLETED_CASH_DEMO, copyKey: 'completedCashDemo', readOnly: true };
  }
  return { key: PENDING_CASH_ARRANGEMENT, copyKey: 'pendingCashArrangement', readOnly: false };
}

module.exports = { COMPLETED_CASH_DEMO, PENDING_CASH_ARRANGEMENT, registrationDemoPresentation };
