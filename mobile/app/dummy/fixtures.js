const tenant = Object.freeze({
  id: 'fixture-temple-001',
  name: '竹南鎮聖福宮',
  origin: 'https://temple.example.test',
  connectionPath: '/connect/templemate'
});

const alternateTenant = Object.freeze({
  id: 'fixture-temple-002',
  name: '示範宮廟二號',
  origin: 'https://second-temple.example.test',
  connectionPath: '/connect/templemate'
});

const seed = Object.freeze({
  profile: { id: 'account-001', email: 'member@example.test', name: '林小安' },
  dependents: [{ id: 'dependent-001', name: '林小福', relationship: '家人' }],
  registrations: [{ id: 'registration-001', offering: { id: 'service-001', slug: 'incense-donation', title: '香油捐獻', account_action: 'service', price_cents: 5000, currency: 'TWD' }, registrantName: '林小安', registrantScope: 'self', quantity: 1, totalAmountCents: 5000, currency: 'TWD', state: 'completed_cash_demo', paymentState: 'completed_cash_demo', demoCashFixture: true, readOnly: true }],
  events: [],
  services: [
    { id: 'service-001', slug: 'incense-donation', title: '香油捐獻', account_action: 'service', price_cents: 5000, currency: 'TWD', status: 'open' },
    { id: 'service-002', slug: 'lamp-service', title: '點燈作業', account_action: 'service', price_cents: 5000, currency: 'TWD', status: 'open' },
    { id: 'service-003', slug: 'ghost-festival-table', title: '普渡供桌', account_action: 'service', price_cents: 5000, currency: 'TWD', status: 'open' },
    { id: 'service-004', slug: 'liberation-ritual', title: '拔薦', account_action: 'service', price_cents: 5000, currency: 'TWD', status: 'open' }
  ],
  gatherings: [],
  gallery: [{ id: 'gallery-001', title: '春季法會紀錄' }],
  certificates: [{ id: 'certificate-001', certificateNumber: 'DEMO-001', offering: { title: '平安祈福' }, issuedAt: '2026-08-01' }],
  preferences: { locale: 'zh-TW', theme: 'light' }
});

const clone = value => JSON.parse(JSON.stringify(value));
const nativeOAuthReturnUrl = 'templemate://oauth/complete';
const oauthJourneys = Object.freeze({
  success: Object.freeze({ type: 'success' }), profile_required: Object.freeze({ type: 'profile_required' }), cancellation: Object.freeze({ type: 'cancel' }),
  denial: Object.freeze({ type: 'denied' }), failure: Object.freeze({ type: 'failure' }), interruption: Object.freeze({ type: 'interrupted' })
});
module.exports = { tenant, alternateTenant, seed, clone, nativeOAuthReturnUrl, oauthJourneys };
