import { StatusBar } from 'expo-status-bar';
import { useEffect, useMemo, useState } from 'react';
import {
  Alert,
  AppState,
  BackHandler,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';

import { createDummyAdapter } from './app/dummy/adapter';
import { tenant } from './app/dummy/fixtures';
import { bindFixture, initialBinding } from './app/tenant/binding';

const adapter = createDummyAdapter();
const copy = {
  'zh-TW': {
    title: 'TempleMate', demo: '示範模式：資料只存在此裝置的重設範圍內。', signIn: '登入', signOut: '登出', email: '電子郵件', password: '密碼',
    name: '姓名', home: '首頁', profile: '個人資料', dependents: '家屬', registrations: '登記', discover: '探索', settings: '設定',
    reset: '重設示範資料', save: '儲存', add: '新增', remove: '刪除', update: '更新', connect: '連結宮廟', retry: '重試',
    signedOut: '請以示範帳號登入', credentials: 'member@example.test / templemate-demo', register: '建立帳號', recover: '忘記密碼',
    recoveryNotice: '此示範不會傳送郵件。', signupNotice: '帳號建立會在未來的安全帳戶服務完成後啟用。', bound: '已連結', unbound: '尚未連結',
    account: '帳戶', success: '已儲存', privacy: '隱私與協助', close: '關閉帳戶', certificates: '證明文件',
    contact: '聯絡宮廟', assistance: '需要協助', theme: '外觀', language: '語言'
  },
  en: {
    title: 'TempleMate', demo: 'Demo mode: data stays inside this device-reset scope.', signIn: 'Sign in', signOut: 'Sign out', email: 'Email', password: 'Password',
    name: 'Name', home: 'Home', profile: 'Profile', dependents: 'Dependents', registrations: 'Registrations', discover: 'Explore', settings: 'Settings',
    reset: 'Reset demo data', save: 'Save', add: 'Add', remove: 'Delete', update: 'Update', connect: 'Connect temple', retry: 'Retry',
    signedOut: 'Sign in with the demo account', credentials: 'member@example.test / templemate-demo', register: 'Create account', recover: 'Forgot password',
    recoveryNotice: 'This demo does not send email.', signupNotice: 'Account creation will be enabled by a future secure account service.', bound: 'Connected', unbound: 'Not connected',
    account: 'Account', success: 'Saved', privacy: 'Privacy & help', close: 'Close account', certificates: 'Certificates',
    contact: 'Contact temple', assistance: 'Need help', theme: 'Appearance', language: 'Language'
  }
};

const normalizeError = error => ({ message: error?.message || 'Something went wrong. Please try again.', field: error?.field || 'form' });
const FormInput = ({ label, value, onChangeText, secureTextEntry = false, autoCapitalize = 'sentences' }) => (
  <View style={styles.field}><Text style={styles.label}>{label}</Text><TextInput value={value} onChangeText={onChangeText} secureTextEntry={secureTextEntry} autoCapitalize={autoCapitalize} style={styles.input} /></View>
);
const Button = ({ label, onPress, disabled = false, secondary = false }) => (
  <Pressable accessibilityRole="button" disabled={disabled} onPress={onPress} style={[styles.button, secondary && styles.buttonSecondary, disabled && styles.buttonDisabled]}>
    <Text style={[styles.buttonText, secondary && styles.buttonSecondaryText]}>{label}</Text>
  </Pressable>
);

export default function App() {
  const [startup, setStartup] = useState('loading');
  const [authState, setAuthState] = useState('signed_out');
  const [screen, setScreen] = useState('home');
  const [locale, setLocale] = useState('zh-TW');
  const [dark, setDark] = useState(false);
  const [binding, setBinding] = useState(initialBinding());
  const [data, setData] = useState(adapter.snapshot());
  const [email, setEmail] = useState('member@example.test');
  const [password, setPassword] = useState('templemate-demo');
  const [profileName, setProfileName] = useState(data.profile.name);
  const [dependentName, setDependentName] = useState('');
  const [relationship, setRelationship] = useState('家人');
  const [editingDependentId, setEditingDependentId] = useState(null);
  const [registrationOffering, setRegistrationOffering] = useState('平安祈福');
  const [registrationName, setRegistrationName] = useState(data.profile.name);
  const [editingRegistrationId, setEditingRegistrationId] = useState(null);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState(null);
  const [notice, setNotice] = useState(null);
  const t = copy[locale];
  const colors = dark ? darkColors : lightColors;

  useEffect(() => {
    const timer = setTimeout(() => setStartup('ready'), 180);
    const resume = AppState.addEventListener('change', next => { if (next === 'active') setNotice(null); });
    const back = BackHandler.addEventListener('hardwareBackPress', () => {
      if (authState === 'authenticated' && screen !== 'home') { setScreen('home'); return true; }
      return false;
    });
    return () => { clearTimeout(timer); resume.remove(); back.remove(); };
  }, [authState, screen]);

  const run = async action => {
    if (pending) return;
    setPending(true); setError(null); setNotice(null);
    try { const next = await action(); if (next) setData(next); setNotice(t.success); }
    catch (reason) { setError(normalizeError(reason)); }
    finally { setPending(false); }
  };
  const reset = () => {
    const next = adapter.reset(); setData(next); setProfileName(next.profile.name); setRegistrationName(next.profile.name);
    setDependentName(''); setEditingDependentId(null); setEditingRegistrationId(null); setBinding(initialBinding()); setNotice(t.success); setError(null);
  };
  const signIn = () => run(async () => { const next = await adapter.signIn({ email, password }); setAuthState('authenticated'); setBinding(bindFixture(`${tenant.origin}${tenant.connectionPath}?token=fixture-token`)); return next; });
  const signOut = () => { setAuthState('signed_out'); setScreen('home'); setError(null); setNotice(null); };
  const startEditRegistration = item => { if (item.readOnly) return; setEditingRegistrationId(item.id); setRegistrationOffering(item.offering); setRegistrationName(item.registrantName); };
  const startEditDependent = item => { setEditingDependentId(item.id); setDependentName(item.name); setRelationship(item.relationship); };
  const saveRegistration = () => run(() => editingRegistrationId ? adapter.updateRegistration(editingRegistrationId, { offering: registrationOffering, registrantName: registrationName }) : adapter.createRegistration({ offering: registrationOffering, registrantName: registrationName })).then(() => setEditingRegistrationId(null));

  if (startup === 'loading') return <SafeAreaProvider><SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}><View style={styles.center}><Text style={[styles.title, { color: colors.text }]}>{t.title}</Text><Text style={{ color: colors.muted }}>Loading dummy account…</Text></View></SafeAreaView></SafeAreaProvider>;
  if (authState === 'signed_out') return <SafeAreaProvider><SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}><KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={styles.flex}><ScrollView contentContainerStyle={styles.authWrap} keyboardShouldPersistTaps="handled"><Text style={[styles.title, { color: colors.text }]}>{t.title}</Text><Text style={[styles.caption, { color: colors.muted }]}>{t.signedOut}</Text><Text style={[styles.demo, { color: colors.text }]}>{t.credentials}</Text><FormInput label={t.email} value={email} onChangeText={setEmail} autoCapitalize="none" /><FormInput label={t.password} value={password} onChangeText={setPassword} secureTextEntry autoCapitalize="none" />{error && <Text style={styles.error}>{error.message}</Text>}<Button label={pending ? '…' : t.signIn} onPress={signIn} disabled={pending} /><Button label={t.register} onPress={() => setNotice(t.signupNotice)} secondary /><Button label={t.recover} onPress={() => setNotice(t.recoveryNotice)} secondary />{notice && <Text style={styles.notice}>{notice}</Text>}<LocaleTheme t={t} locale={locale} setLocale={setLocale} dark={dark} setDark={setDark} /></ScrollView></KeyboardAvoidingView></SafeAreaView></SafeAreaProvider>;

  const saveDependent = () => run(() => editingDependentId ? adapter.updateDependent(editingDependentId, { name: dependentName, relationship }) : adapter.createDependent({ name: dependentName, relationship })).then(() => { setDependentName(''); setEditingDependentId(null); });
  const nav = [['home', t.home], ['profile', t.profile], ['dependents', t.dependents], ['registrations', t.registrations], ['discover', t.discover], ['settings', t.settings]];
  return <SafeAreaProvider><SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}><StatusBar style={dark ? 'light' : 'dark'} /><View style={styles.flex}><View style={[styles.header, { borderBottomColor: colors.border }]}><View><Text style={[styles.titleSmall, { color: colors.text }]}>{t.title}</Text><Text style={{ color: colors.muted }}>{binding.state === 'bound' ? `${t.bound} · ${binding.tenant.name}` : t.unbound}</Text></View><Button label={t.signOut} secondary onPress={signOut} /></View><ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.nav}>{nav.map(([key, label]) => <Pressable key={key} onPress={() => setScreen(key)} style={[styles.navItem, screen === key && styles.navActive]}><Text style={screen === key ? styles.navActiveText : { color: colors.muted }}>{label}</Text></Pressable>)}</ScrollView><ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled"><Text style={[styles.demo, { color: colors.text }]}>{t.demo}</Text>{error && <View style={styles.errorBox}><Text style={styles.error}>{error.message}</Text><Button label={t.retry} onPress={() => setError(null)} secondary /></View>}{notice && <Text style={styles.notice}>{notice}</Text>}{screen === 'home' && <Home t={t} data={data} binding={binding} onBind={() => setBinding(bindFixture(`${tenant.origin}${tenant.connectionPath}?token=fixture-token`))} />}{screen === 'profile' && <Section title={t.profile}><FormInput label={t.name} value={profileName} onChangeText={setProfileName} /><Button label={t.save} disabled={pending} onPress={() => run(() => adapter.updateProfile({ name: profileName }))} /></Section>}{screen === 'dependents' && <Section title={t.dependents}>{data.dependents.map(item => <Pressable key={item.id} onPress={() => startEditDependent(item)} style={styles.card}><Text style={styles.rowText}>{item.name} · {item.relationship}</Text></Pressable>)}<FormInput label={t.name} value={dependentName} onChangeText={setDependentName} /><FormInput label="關係 / Relationship" value={relationship} onChangeText={setRelationship} /><Button label={editingDependentId ? t.update : t.add} disabled={pending} onPress={saveDependent} /><Button label={t.remove} secondary disabled={!editingDependentId} onPress={() => run(() => adapter.deleteDependent(editingDependentId)).then(() => { setDependentName(''); setEditingDependentId(null); })} /></Section>}{screen === 'registrations' && <Section title={t.registrations}>{data.registrations.map(item => <Pressable key={item.id} onPress={() => startEditRegistration(item)} style={styles.card}><Text style={styles.rowText}>{item.offering} · {item.registrantName}</Text><Text style={styles.cardCaption}>{item.readOnly ? '已完成（僅供展示）' : item.state === 'draft' ? '草稿' : item.state}</Text></Pressable>)}<FormInput label="項目 / Offering" value={registrationOffering} onChangeText={setRegistrationOffering} /><FormInput label="登記人 / Registrant" value={registrationName} onChangeText={setRegistrationName} /><Button label={editingRegistrationId ? t.update : t.add} disabled={pending} onPress={saveRegistration} /></Section>}{screen === 'discover' && <Discover data={data} t={t} />}{screen === 'settings' && <Section title={t.settings}><LocaleTheme t={t} locale={locale} setLocale={setLocale} dark={dark} setDark={setDark} /><Text style={[styles.subhead, { color: colors.text }]}>{t.privacy}</Text><Button label={t.assistance} secondary onPress={() => setNotice('收到示範請求。')} /><Button label={t.contact} secondary onPress={() => setNotice('收到示範訊息。')} /><Button label={t.close} secondary onPress={() => Alert.alert(t.close, '此示範只會登出並清除本機展示狀態。', [{ text: '取消' }, { text: '繼續', onPress: signOut }])} /><Button label={t.reset} secondary onPress={reset} /></Section>}</ScrollView></View></SafeAreaView></SafeAreaProvider>;
}

function Home({ t, data, binding, onBind }) { return <><Section title={t.account}><Text style={styles.body}>Hello, {data.profile.name}</Text><Text style={styles.body}>{data.registrations.length} {t.registrations} · {data.dependents.length} {t.dependents}</Text></Section><Section title={t.connect}><Text style={styles.body}>{binding.state === 'bound' ? binding.tenant.name : t.unbound}</Text>{binding.state !== 'bound' && <Button label={t.connect} onPress={onBind} />}</Section><Section title={t.certificates}><Text style={styles.body}>平安祈福參與證明（示範）</Text></Section></> }
function Discover({ data, t }) { return <><Section title="Events">{data.events.map(item => <Text key={item.id} style={styles.body}>{item.title} · {item.date}</Text>)}</Section><Section title="Services">{data.services.map(item => <Text key={item.id} style={styles.body}>{item.title}</Text>)}</Section><Section title="Gallery">{data.gallery.map(item => <Text key={item.id} style={styles.body}>{item.title}</Text>)}</Section></> }
function Section({ title, children }) { return <View style={styles.section}><Text style={styles.sectionTitle}>{title}</Text>{children}</View>; }
function LocaleTheme({ t, locale, setLocale, dark, setDark }) { return <View style={styles.preferences}><Text style={styles.label}>{t.language}</Text><View style={styles.row}><Button label="繁中" secondary onPress={() => setLocale('zh-TW')} /><Button label="English" secondary onPress={() => setLocale('en')} /></View><Text style={styles.label}>{t.theme}</Text><Button label={dark ? 'Light' : 'Dark'} secondary onPress={() => setDark(value => !value)} /></View>; }
const lightColors = { background: '#fbf8f4', text: '#251c17', muted: '#6b625b', border: '#ded6cb' };
const darkColors = { background: '#191715', text: '#f8f2ea', muted: '#cbbfb4', border: '#473e37' };
const styles = StyleSheet.create({ flex: { flex: 1 }, safe: { flex: 1 }, center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 8 }, authWrap: { padding: 24, gap: 12 }, header: { paddingHorizontal: 18, paddingTop: 10, paddingBottom: 12, borderBottomWidth: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }, title: { fontSize: 32, fontWeight: '800' }, titleSmall: { fontSize: 21, fontWeight: '800' }, caption: { fontSize: 14 }, demo: { fontSize: 13, fontWeight: '600', padding: 10, backgroundColor: '#efe9df', borderRadius: 8 }, nav: { gap: 8, paddingHorizontal: 14, paddingVertical: 10 }, navItem: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 16 }, navActive: { backgroundColor: '#8c2e1f' }, navActiveText: { color: '#fff', fontWeight: '700' }, content: { padding: 18, gap: 14 }, section: { padding: 16, gap: 10, backgroundColor: '#fff', borderRadius: 14, borderWidth: 1, borderColor: '#e3dbd1' }, sectionTitle: { color: '#62261d', fontSize: 19, fontWeight: '800' }, subhead: { fontSize: 16, fontWeight: '800', marginTop: 8 }, body: { color: '#312722', fontSize: 16, lineHeight: 23 }, field: { gap: 5 }, label: { color: '#493c35', fontWeight: '700' }, input: { minHeight: 46, paddingHorizontal: 12, borderWidth: 1, borderColor: '#cfc3b7', borderRadius: 8, backgroundColor: '#fff', color: '#241b16' }, button: { minHeight: 42, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 14, borderRadius: 8, backgroundColor: '#8c2e1f' }, buttonText: { color: '#fff', fontWeight: '800' }, buttonSecondary: { backgroundColor: '#f3ede6', borderWidth: 1, borderColor: '#d9cdc0' }, buttonSecondaryText: { color: '#51352c' }, buttonDisabled: { opacity: 0.5 }, row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: 8, paddingVertical: 4 }, rowText: { color: '#312722', fontSize: 16, flex: 1 }, card: { padding: 12, borderRadius: 8, backgroundColor: '#f7f1e9', gap: 4 }, cardCaption: { color: '#6b625b' }, error: { color: '#a71313', fontWeight: '700' }, errorBox: { gap: 8, padding: 12, borderRadius: 8, backgroundColor: '#ffe9e7' }, notice: { color: '#196a3a', fontWeight: '700', padding: 10, backgroundColor: '#e7f7eb', borderRadius: 8 }, preferences: { gap: 8 } });
