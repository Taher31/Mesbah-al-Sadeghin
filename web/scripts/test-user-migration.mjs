// Run with: node scripts/test-user-migration.mjs
// Exercises the actual store module in memory; does not create an app build or touch browser data.
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'

const migration = JSON.parse(readFileSync(new URL('../src/generated/anis-paragraph-migration.json', import.meta.url), 'utf8'))
const source = readFileSync(new URL('../src/lib/store.ts', import.meta.url), 'utf8')
const code = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
}).outputText

function loadStore(initial, settings) {
  const storage = new Map(initial ? [['mesbah.user', JSON.stringify(initial)]] : [])
  if (settings) storage.set('mesbah.settings', JSON.stringify(settings))
  const module = { exports: {} }
  const books = new Map([1, 2, 3, 4].map((id) => [id, { id: id === 4 ? 1 : id, work: id === 1 || id === 4 ? 'anis' : 'safineh' }]))
  const require = (name) => {
    if (name === 'preact/hooks') return {}
    if (name === './books') return { RETIRED_ANIS: 4, bookById: (id) => books.get(id) }
    if (name === './i18n') return { LANGUAGES: ['fa', 'ar', 'en'].map((id) => ({ id })), t: (s) => s }
    if (name === '../generated/anis-paragraph-migration.json') return migration
    throw new Error('Unexpected dependency: ' + name)
  }
  vm.runInNewContext(code, {
    module, exports: module.exports, require,
    localStorage: { getItem: (key) => storage.get(key) ?? null, setItem: (key, value) => storage.set(key, value) },
    window: { addEventListener() {} },
  }, { filename: 'store.ts' })
  return module.exports
}

const bookmark = (id, section, paragraph, excerpt, book = 1) => ({ id, book, section, paragraph, excerpt, note: 'note ' + id, created: id })
const original = {
  progress: [{ book: 1, section: 405, paragraph: 90, updated: 100 }],
  favorites: [{ book: 1, section: 405 }],
  visits: [{ book: 1, section: 405, count: 3, last: 100 }],
  bookmarks: [bookmark(1, 405, 90, 'unchanged passage'), bookmark(2, 14, 2, 'edited passage')],
}
const api = loadStore(original)
const migrated = api.userStore.get()
assert.equal(migrated.textRevision, migration.revision)
assert.equal(migrated.progress[0].paragraph, 88)
assert.equal(migrated.bookmarks.find((b) => b.id === 1).paragraph, 88)
assert.equal(migrated.bookmarks.find((b) => b.id === 2).paragraph, api.SECTION_LEVEL)
assert.equal(migrated.bookmarks.find((b) => b.id === 2).note, 'note 2')
assert.equal(JSON.stringify(migrated.favorites), JSON.stringify(original.favorites))
assert.equal(JSON.stringify(migrated.visits), JSON.stringify(original.visits))
assert.equal(JSON.stringify(api.sanitizeUserData(migrated)), JSON.stringify(migrated), 'sanitizing twice must not shift keys twice')

// A new bookmark at old key 90 must stay at the current edition's key 90.
api.toggleBookmark(1, 405, 90, 'new bookmark')
const exported = api.exportBackup()
const restoredApi = loadStore()
assert.equal(restoredApi.importBackup(exported), true)
assert.equal(restoredApi.userStore.get().bookmarks.some((b) => b.paragraph === 90), true)
const restored = JSON.stringify(restoredApi.userStore.get())
assert.equal(restoredApi.importBackup(exported), true)
assert.equal(JSON.stringify(restoredApi.userStore.get()), restored, 'restoring a current backup twice must be idempotent')

// Old backups use the same migration as old local storage.
const oldBackupApi = loadStore()
assert.equal(oldBackupApi.importBackup(JSON.stringify({ app: 'mesbah-al-sadeqin', format: 1, ...original })), true)
assert.equal(oldBackupApi.userStore.get().progress[0].paragraph, 88)
assert.equal(oldBackupApi.userStore.get().bookmarks.find((b) => b.id === 1).paragraph, 88)

// Retired-book and unmatched bookmarks sharing a section retain separate excerpts and notes.
const retiredApi = loadStore()
assert.equal(retiredApi.importBackup(JSON.stringify({
  app: 'mesbah-al-sadeqin', format: 1,
  bookmarks: [bookmark(10, 10, 1, 'first excerpt', 4), bookmark(11, 10, 2, 'second excerpt', 4)],
})), true)
assert.equal(retiredApi.userStore.get().bookmarks.length, 2)
assert.equal(retiredApi.userStore.get().bookmarks.every((b) => b.book === 1 && b.paragraph === api.SECTION_LEVEL), true)
const retiredBackup = retiredApi.exportBackup()
const retiredRestored = loadStore()
assert.equal(retiredRestored.importBackup(retiredBackup), true)
assert.equal(retiredRestored.userStore.get().bookmarks.length, 2)
assert.equal(retiredRestored.userStore.get().bookmarks.every((b) => b.note === 'note ' + b.id), true)

// These two real old keys both fall back to section level and have identical text.
const repeatedApi = loadStore()
const repeatedBackup = JSON.stringify({
  app: 'mesbah-al-sadeqin', format: 1,
  bookmarks: [bookmark(30, 212, 133, 'و سه مرتبه می‌گویی:'), bookmark(31, 212, 136, 'و سه مرتبه می‌گویی:')],
})
assert.equal(repeatedApi.importBackup(repeatedBackup), true)
assert.equal(repeatedApi.userStore.get().bookmarks.length, 2)
assert.equal(repeatedApi.userStore.get().bookmarks.every((b) => b.paragraph === api.SECTION_LEVEL && b.note === 'note ' + b.id), true)
assert.equal(repeatedApi.importBackup(repeatedBackup), true)
assert.equal(repeatedApi.userStore.get().bookmarks.length, 2, 'repeat import preserves both distinct notes without duplicating them')
const repeatedRestored = loadStore()
assert.equal(repeatedRestored.importBackup(repeatedApi.exportBackup()), true)
assert.equal(repeatedRestored.userStore.get().bookmarks.length, 2)

const unchanged = api.sanitizeUserData({ bookmarks: [bookmark(20, 405, 90, 'Safineh', 2)] })
assert.equal(unchanged.bookmarks[0].paragraph, 90)
const removedProgress = api.sanitizeUserData({ progress: [{ book: 1, section: 14, paragraph: 2, updated: 1 }] })
assert.equal(removedProgress.progress[0].paragraph, 1)

// The former standalone Semi Bold choice becomes Naskh Qurani with the bold switch on.
for (const arabicBold of [false, true, undefined]) {
  const settings = api.sanitizeSettings({ arabicFont: 'naskh93', arabicBold })
  assert.equal(settings.arabicFont, 'naskh')
  assert.equal(settings.arabicBold, true)
  assert.equal(JSON.stringify(api.sanitizeSettings(settings)), JSON.stringify(settings))
}
for (const arabicBold of [false, true]) {
  assert.equal(api.sanitizeSettings({ arabicFont: 'naskh', arabicBold }).arabicBold, arabicBold)
}
assert.equal(api.ARABIC_FONTS.filter((f) => f.id === 'naskh').length, 1)
assert.equal(api.ARABIC_FONTS.some((f) => f.id === 'naskh93'), false)
const oldFontBackupApi = loadStore()
assert.equal(oldFontBackupApi.importBackup(JSON.stringify({
  app: 'mesbah-al-sadeqin', format: 1, settings: { arabicFont: 'naskh93', arabicBold: false },
})), true)
assert.equal(oldFontBackupApi.settingsStore.get().arabicFont, 'naskh')
assert.equal(oldFontBackupApi.settingsStore.get().arabicBold, true)
oldFontBackupApi.setSetting('arabicBold', false)
const normalFontBackupApi = loadStore()
assert.equal(normalFontBackupApi.importBackup(oldFontBackupApi.exportBackup()), true)
assert.equal(normalFontBackupApi.settingsStore.get().arabicFont, 'naskh')
assert.equal(normalFontBackupApi.settingsStore.get().arabicBold, false)
console.log('PASS: paragraph migration, old/current backups, repeated restore, note preservation and unaffected books')
console.log('PASS: merged Naskh font choice, legacy settings, normal/bold toggle and backup restoration')

// Translation colors survive reloads/backups, while old settings keep a neutral default.
assert.equal(api.sanitizeSettings({ arabicSize: 31 }).translationColor, 'neutral')
assert.equal(api.sanitizeSettings({ translationColor: 'invalid' }).translationColor, 'neutral')
for (const { id } of api.translationColors()) {
  const colorApi = loadStore(undefined, { translationColor: id, arabicSize: 31 })
  assert.equal(colorApi.settingsStore.get().translationColor, id)
  assert.equal(colorApi.settingsStore.get().arabicSize, 31)
  colorApi.setSetting('translationColor', id)
  const colorBackupApi = loadStore()
  assert.equal(colorBackupApi.importBackup(colorApi.exportBackup()), true)
  assert.equal(colorBackupApi.settingsStore.get().translationColor, id)
  colorBackupApi.setSetting('language', 'en')
  colorBackupApi.resetTextSettings()
  assert.equal(colorBackupApi.settingsStore.get().translationColor, 'neutral')
  assert.equal(colorBackupApi.settingsStore.get().language, 'en')
}
console.log('PASS: all translation colors, saved settings, old defaults, backup restoration and text reset')
