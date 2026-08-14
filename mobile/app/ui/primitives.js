import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

export function Button({ label, onPress, palette, disabled = false, tone = 'primary', accessibilityLabel }) {
  const secondary = tone === 'secondary'; const danger = tone === 'danger'; const backgroundColor = secondary ? palette.inset : danger ? palette.danger : palette.primary; const color = secondary ? palette.text : palette.onPrimary;
  return <Pressable accessibilityRole="button" accessibilityLabel={accessibilityLabel || label} disabled={disabled} onPress={onPress} style={[styles.button, { backgroundColor, borderColor: secondary ? palette.border : backgroundColor }, disabled && styles.disabled]}><Text style={[styles.buttonText, { color }]}>{label}</Text></Pressable>;
}

export function FormInput({ label, value, onChangeText, palette, secureTextEntry = false, autoCapitalize = 'sentences', accessibilityLabel, maxLength }) {
  return <View style={styles.field}><Text style={[styles.label, { color: palette.text }]}>{label}</Text><TextInput accessibilityLabel={accessibilityLabel || label} value={value} onChangeText={onChangeText} secureTextEntry={secureTextEntry} autoCapitalize={autoCapitalize} maxLength={maxLength} placeholderTextColor={palette.textMuted} style={[styles.input, { color: palette.text, borderColor: palette.border, backgroundColor: palette.card }]} /></View>;
}

export function Section({ title, palette, children, accessibilityLabel }) { return <View accessibilityLabel={accessibilityLabel || title} style={[styles.section, { backgroundColor: palette.card, borderColor: palette.border }]}><Text style={[styles.sectionTitle, { color: palette.text }]}>{title}</Text>{children}</View>; }
export function Notice({ children, palette, tone = 'success' }) { const color = tone === 'error' ? palette.danger : tone === 'info' ? palette.accent : palette.success; return <View accessibilityRole="alert" style={[styles.notice, { borderColor: color, backgroundColor: palette.inset }]}><Text style={[styles.noticeText, { color }]}>{children}</Text></View>; }

const styles = StyleSheet.create({ button: { minHeight: 48, paddingHorizontal: 16, borderRadius: 12, borderWidth: 1, alignItems: 'center', justifyContent: 'center' }, buttonText: { fontWeight: '800', fontSize: 15, textAlign: 'center' }, disabled: { opacity: 0.48 }, field: { gap: 7 }, label: { fontWeight: '700', fontSize: 14 }, input: { minHeight: 50, paddingHorizontal: 14, borderWidth: 1, borderRadius: 12, fontSize: 16 }, section: { padding: 16, gap: 12, borderWidth: 1, borderRadius: 16 }, sectionTitle: { fontWeight: '800', fontSize: 19 }, notice: { padding: 12, borderLeftWidth: 4, borderRadius: 10 }, noticeText: { fontWeight: '700', lineHeight: 20 } });
