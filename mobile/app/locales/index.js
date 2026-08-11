export const supportedLocales = Object.freeze(['zh-TW', 'en']);
export const defaultLocale = 'zh-TW';

export const normalizeLocale = value => supportedLocales.includes(value) ? value : defaultLocale;
