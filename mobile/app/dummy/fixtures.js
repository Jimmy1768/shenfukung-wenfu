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
  registrations: [{ id: 'registration-001', offering: { id: 'event-001', slug: 'peace-blessing', title: '平安祈福', account_action: 'event', price_cents: 1200, currency: 'TWD' }, registrantName: '林小安', registrantScope: 'self', quantity: 1, totalAmountCents: 1200, currency: 'TWD', state: 'confirmed', readOnly: true }],
  events: [{ id: 'event-001', slug: 'peace-blessing', title: '平安祈福', account_action: 'event', price_cents: 1200, currency: 'TWD', status: 'open', date: '2026-09-01' }],
  services: [{ id: 'service-001', slug: 'online-blessing', title: '線上祈福服務', account_action: 'service', price_cents: 600, currency: 'TWD', status: 'open' }],
  gatherings: [{ id: 'gathering-001', slug: 'community-gathering', title: '社群聚會', account_action: 'gathering', price_cents: 0, currency: 'TWD', status: 'open' }],
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
