const tenant = Object.freeze({
  id: 'fixture-temple-001',
  name: '竹南鎮聖福宮',
  origin: 'https://temple.example.test',
  connectionPath: '/connect/templemate'
});

const seed = Object.freeze({
  profile: { id: 'account-001', email: 'member@example.test', name: '林小安' },
  dependents: [{ id: 'dependent-001', name: '林小福', relationship: '家人' }],
  registrations: [{ id: 'registration-001', offering: '平安祈福', registrantName: '林小安', state: 'confirmed', readOnly: true }],
  events: [{ id: 'event-001', title: '祈福法會', date: '2026-09-01' }],
  services: [{ id: 'service-001', title: '線上祈福服務' }],
  gallery: [{ id: 'gallery-001', title: '春季法會紀錄' }]
});

const clone = value => JSON.parse(JSON.stringify(value));
module.exports = { tenant, seed, clone };
