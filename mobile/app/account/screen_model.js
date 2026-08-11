const ACCOUNT_SCREENS = Object.freeze([
  'home', 'profile', 'dependents', 'registrations', 'discover', 'settings',
  'signup', 'recovery', 'assistance', 'contact', 'privacy', 'closure', 'connection'
]);

const accountMenu = () => ['home', 'profile', 'dependents', 'registrations', 'discover', 'settings'];
const isAccountScreen = screen => ACCOUNT_SCREENS.includes(screen);
const isPaidFixtureReadOnly = registration => Boolean(registration?.readOnly);
const dummyMode = adapter => adapter?.kind === 'dummy' && adapter?.network === 'disabled';
const visibleTheme = dark => dark ? 'dark' : 'light';
const visibleLocale = locale => ['zh-TW', 'en'].includes(locale) ? locale : 'zh-TW';

module.exports = { ACCOUNT_SCREENS, accountMenu, isAccountScreen, isPaidFixtureReadOnly, dummyMode, visibleTheme, visibleLocale };
