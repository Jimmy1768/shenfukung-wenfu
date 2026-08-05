const API_ROOT = '/api/v1/temple';

function buildUrl(path = '') {
  return `${API_ROOT}${path}`;
}

async function request(path) {
  const response = await fetch(buildUrl(path));
  if (!response.ok) {
    throw new Error(`Temple API request failed (${response.status})`);
  }
  return response.json();
}

async function requestJson(path, options = {}) {
  const response = await fetch(buildUrl(path), {
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {})
    },
    body: options.body ? JSON.stringify(options.body) : undefined
  });

  let payload = null;
  try {
    payload = await response.json();
  } catch (_error) {
    payload = null;
  }

  if (!response.ok) {
    const message = payload?.error || `Temple API request failed (${response.status})`;
    const error = new Error(message);
    error.status = response.status;
    error.payload = payload;
    throw error;
  }

  return payload;
}

export function fetchTempleProfile() {
  return request();
}

export function fetchTempleNews(options = {}) {
  const limit = Number(options.limit || 10);
  const safeLimit = Number.isFinite(limit) ? limit : 10;
  return request(`/news?limit=${safeLimit}`);
}

export function fetchTempleArchive() {
  return request('/archive');
}

export function fetchTempleEvents(options = {}) {
  const limit = Number(options.limit || 20);
  const safeLimit = Number.isFinite(limit) ? limit : 20;
  const status = options.status || 'upcoming';
  const query = new URLSearchParams({
    limit: String(safeLimit),
    status
  });
  return request(`/events?${query.toString()}`);
}

export function fetchTempleGatherings() {
  return request('/gatherings');
}

export function fetchTempleEvent(eventSlug) {
  return request(`/events/${encodeURIComponent(eventSlug)}`);
}

export function fetchTempleServices(options = {}) {
  const limit = Number(options.limit || 50);
  const safeLimit = Number.isFinite(limit) ? limit : 50;
  return request(`/services?limit=${safeLimit}`);
}

export function fetchTempleService(serviceSlug) {
  return request(`/services/${encodeURIComponent(serviceSlug)}`);
}

export function submitTempleContactRequest(payload) {
  return requestJson('/contact_temple_requests', {
    method: 'POST',
    body: payload
  });
}
