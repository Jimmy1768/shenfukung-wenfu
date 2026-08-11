import { getTheme } from '../../theme/tokens';

export const paletteFor = dark => {
  const { tokens } = getTheme(dark ? 'ops-dark' : 'temple-1');
  return { ...tokens, background: tokens.surface, card: tokens.surfaceRaised, inset: tokens.surfaceMuted, onPrimary: tokens.primaryForeground, statusBar: dark ? 'light' : 'dark' };
};
