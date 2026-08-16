const ACCOUNT_SCREENS = Object.freeze([
  'home', 'profile', 'dependents', 'registrations', 'discover', 'settings',
  'signup', 'recovery', 'assistance', 'privacy', 'closure', 'connection'
]);

const accountMenu = () => ['home', 'profile', 'dependents', 'registrations', 'discover'];
const isAccountScreen = screen => ACCOUNT_SCREENS.includes(screen);
const isPaidFixtureReadOnly = registration => Boolean(registration?.readOnly);
const dummyMode = adapter => adapter?.kind === 'dummy' && adapter?.network === 'disabled';
const visibleTheme = dark => dark ? 'dark' : 'light';
const visibleLocale = locale => ['zh-TW', 'en'].includes(locale) ? locale : 'zh-TW';
const safeAccountScreen = screen => isAccountScreen(screen) ? screen : 'home';
const isBoundPresentation = binding => binding?.state === 'bound' || binding?.state === 'switching';
const safeBoundScreen = (screen, binding) => isBoundPresentation(binding) ? safeAccountScreen(screen) : 'home';
const mutationOutcome = async ({ action, onSuccess }) => {
  try { const value = await action(); if (onSuccess) onSuccess(value); return { ok: true, value }; }
  catch (error) { return { ok: false, error }; }
};

module.exports = { ACCOUNT_SCREENS, accountMenu, isAccountScreen, isPaidFixtureReadOnly, dummyMode, visibleTheme, visibleLocale, safeAccountScreen, safeBoundScreen, isBoundPresentation, mutationOutcome };
