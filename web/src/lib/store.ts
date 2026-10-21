import { useEffect, useState } from 'preact/hooks'
import { RETIRED_ANIS, bookById, type BookId, type WorkId } from './books'

/** A value with listeners; the whole app's state is a handful of these. */
export class Store<T> {
  private value: T
  private listeners = new Set<() => void>()

  constructor(initial: T) {
    this.value = initial
  }

  get(): T {
    return this.value
  }

  set(next: T) {
    if (next === this.value) return
    this.value = next
    this.listeners.forEach((l) => l())
  }

  update(fn: (value: T) => T) {
    this.set(fn(this.value))
  }

  subscribe(listener: () => void): () => void {
    this.listeners.add(listener)
    return () => this.listeners.delete(listener)
  }
}

export function useStore<T>(store: Store<T>): T {
  const [, setTick] = useState(0)
  useEffect(() => store.subscribe(() => setTick((n) => n + 1)), [store])
  return store.get()
}

/** localStorage can throw (private mode, blocked storage); the app then simply doesn't persist. */
function readJson(key: string): unknown {
  try {
    const raw = localStorage.getItem(key)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function writeJson(key: string, value: unknown) {
  try {
    localStorage.setItem(key, JSON.stringify(value))
  } catch {
    // Storage full or unavailable: keep working in memory.
  }
}

function persisted<T>(key: string, load: (raw: unknown) => T): Store<T> {
  const store = new Store<T>(load(readJson(key)))
  store.subscribe(() => writeJson(key, store.get()))
  // Another tab of the app changed it.
  window.addEventListener('storage', (e) => {
    if (e.key === key) store.set(load(readJson(key)))
  })
  return store
}

// ---------------------------------------------------------------- settings

export type ThemeMode = 'system' | 'light' | 'sepia' | 'dark'
export type PersianFont = 'vazirmatn' | 'nazanin' | 'lotus' | 'mitra' | 'zar'
export type ArabicFont = 'naskh' | 'uthman' | 'badr'

export const THEMES: { id: ThemeMode; label: string }[] = [
  { id: 'system', label: 'خودکار' },
  { id: 'light', label: 'روشن' },
  { id: 'sepia', label: 'کاغذی' },
  { id: 'dark', label: 'شب' },
]

export const PERSIAN_FONTS: { id: PersianFont; label: string; family: string }[] = [
  { id: 'vazirmatn', label: 'وزیرمتن', family: 'Vazirmatn' },
  { id: 'nazanin', label: 'نازنین', family: 'Nazanin' },
  { id: 'lotus', label: 'لوتوس', family: 'Lotus' },
  { id: 'mitra', label: 'میترا', family: 'Mitra' },
  { id: 'zar', label: 'زر', family: 'Zar' },
]

export const ARABIC_FONTS: { id: ArabicFont; label: string; family: string }[] = [
  { id: 'naskh', label: 'نسخ قرآنی', family: 'NaskhQurani' },
  { id: 'uthman', label: 'عثمان طه', family: 'UthmanTaha' },
  { id: 'badr', label: 'بدر', family: 'Badr' },
]

export interface Settings {
  theme: ThemeMode
  persianFont: PersianFont
  arabicFont: ArabicFont
  textSize: number
  arabicSize: number
  lineHeight: number
  justify: boolean
  keepScreenOn: boolean
  /** Anis: phrase-by-phrase with the Persian translation, or flowing Arabic paragraphs without it. */
  showTranslation: boolean
  safinehEdition: BookId
}

export const DEFAULT_SETTINGS: Settings = {
  theme: 'system',
  persianFont: 'vazirmatn',
  arabicFont: 'naskh',
  textSize: 18,
  arabicSize: 23,
  lineHeight: 1.9,
  justify: true,
  keepScreenOn: true,
  showTranslation: true,
  safinehEdition: 3,
}

export const RANGES = {
  textSize: [14, 30],
  arabicSize: [16, 36],
  lineHeight: [1.4, 2.6],
} as const

function clamp(v: unknown, [lo, hi]: readonly [number, number], fallback: number): number {
  return typeof v === 'number' && Number.isFinite(v) ? Math.min(hi, Math.max(lo, v)) : fallback
}

function oneOf<T extends string>(v: unknown, allowed: readonly { id: T }[], fallback: T): T {
  return allowed.some((a) => a.id === v) ? (v as T) : fallback
}

function editionOr(v: unknown, work: WorkId, fallback: BookId): BookId {
  const book = typeof v === 'number' ? bookById(v) : undefined
  return book && book.work === work ? book.id : fallback
}

/** Accepts anything (old, partial, hand-edited) and returns valid settings. */
export function sanitizeSettings(raw: unknown): Settings {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>
  const d = DEFAULT_SETTINGS
  return {
    theme: oneOf(r.theme, THEMES, d.theme),
    persianFont: oneOf(r.persianFont, PERSIAN_FONTS, d.persianFont),
    arabicFont: oneOf(r.arabicFont, ARABIC_FONTS, d.arabicFont),
    textSize: clamp(r.textSize, RANGES.textSize, d.textSize),
    arabicSize: clamp(r.arabicSize, RANGES.arabicSize, d.arabicSize),
    lineHeight: clamp(r.lineHeight, RANGES.lineHeight, d.lineHeight),
    justify: typeof r.justify === 'boolean' ? r.justify : d.justify,
    keepScreenOn: typeof r.keepScreenOn === 'boolean' ? r.keepScreenOn : d.keepScreenOn,
    // Someone who used the retired «بدون ترجمه» edition keeps reading without the translation.
    showTranslation: r.anisEdition === RETIRED_ANIS ? false : typeof r.showTranslation === 'boolean' ? r.showTranslation : d.showTranslation,
    safinehEdition: editionOr(r.safinehEdition, 'safineh', d.safinehEdition),
  }
}

export const settingsStore = persisted('mesbah.settings', sanitizeSettings)

export function setSetting<K extends keyof Settings>(key: K, value: Settings[K]) {
  settingsStore.update((s) => ({ ...s, [key]: value }))
}

export function editionOf(settings: Settings, work: WorkId): BookId {
  return work === 'anis' ? 1 : settings.safinehEdition
}

/** Restores text appearance only; theme and chosen editions are left alone. */
export function resetTextSettings() {
  const d = DEFAULT_SETTINGS
  settingsStore.update((s) => ({
    ...s,
    persianFont: d.persianFont,
    arabicFont: d.arabicFont,
    textSize: d.textSize,
    arabicSize: d.arabicSize,
    lineHeight: d.lineHeight,
    justify: d.justify,
  }))
}

// ---------------------------------------------------------------- user data

export interface Progress {
  book: BookId
  section: number
  paragraph: number
  updated: number
}

/** A section the reader pinned for quick access — e.g. the supplications of a daily routine. */
export interface Favorite {
  book: BookId
  section: number
}

/** How often a section has been opened; feeds the «پرکاربرد» shelf. */
export interface Visit {
  book: BookId
  section: number
  count: number
  last: number
}

export interface Bookmark {
  id: number
  book: BookId
  section: number
  /** SECTION_LEVEL when the whole section is bookmarked rather than one paragraph. */
  paragraph: number
  excerpt: string
  note: string | null
  created: number
}

export const SECTION_LEVEL = -1
const MAX_EXCERPT = 400

export interface UserData {
  /** One per book, most recent first. */
  progress: Progress[]
  /** In the reader's own order. */
  favorites: Favorite[]
  visits: Visit[]
  /** Newest first. */
  bookmarks: Bookmark[]
}

const isInt = (v: unknown): v is number => typeof v === 'number' && Number.isInteger(v)
const isBook = (v: unknown): boolean => isInt(v) && bookById(v) !== undefined
/** Data saved under the retired Anis edition (4) belongs to book 1; its sections have the same ids. */
const asBook = (v: unknown): BookId => bookById(v as number)!.id
const fromRetired = (v: unknown) => v === RETIRED_ANIS
const list = (v: unknown): Record<string, unknown>[] =>
  Array.isArray(v) ? v.filter((x) => x && typeof x === 'object') : []

export function sanitizeUserData(raw: unknown): UserData {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>
  // Paragraph keys of the retired edition don't exist in book 1, so its positions and bookmarks
  // fall back to the start of their section.
  const progress = list(r.progress)
    .filter((p) => isBook(p.book) && isInt(p.section) && isInt(p.paragraph))
    .map((p) => ({ book: asBook(p.book), section: p.section as number, paragraph: fromRetired(p.book) ? 0 : (p.paragraph as number), updated: Number(p.updated) || 0 }))
  const favorites = list(r.favorites)
    .filter((f) => isBook(f.book) && isInt(f.section))
    .map((f) => ({ book: asBook(f.book), section: f.section as number }))
  const visits = list(r.visits)
    .filter((v) => isBook(v.book) && isInt(v.section) && isInt(v.count))
    .map((v) => ({ book: asBook(v.book), section: v.section as number, count: v.count as number, last: Number(v.last) || 0 }))
  const bookmarks = list(r.bookmarks)
    .filter((b) => isBook(b.book) && isInt(b.section) && isInt(b.paragraph))
    .map((b, i) => ({
      id: isInt(b.id) ? b.id : Date.now() + i,
      book: asBook(b.book),
      section: b.section as number,
      paragraph: fromRetired(b.book) ? SECTION_LEVEL : (b.paragraph as number),
      excerpt: typeof b.excerpt === 'string' ? b.excerpt.slice(0, MAX_EXCERPT) : '',
      note: typeof b.note === 'string' && b.note.trim() ? b.note : null,
      created: Number(b.created) || 0,
    }))
  const visitTotals = new Map<string, Visit>()
  for (const v of visits) {
    const k = `${v.book}:${v.section}`
    const cur = visitTotals.get(k)
    visitTotals.set(k, cur ? { ...cur, count: cur.count + v.count, last: Math.max(cur.last, v.last) } : v)
  }
  return {
    progress: dedupe(progress.sort((a, b) => b.updated - a.updated), (p) => `${p.book}`),
    favorites: dedupe(favorites, (f) => `${f.book}:${f.section}`),
    visits: [...visitTotals.values()],
    // Section-level bookmarks (from the retired edition) may share a section; their excerpts differ.
    bookmarks: dedupe(bookmarks, (b) => `${b.book}:${b.section}:${b.paragraph}` + (b.paragraph === SECTION_LEVEL ? `:${b.excerpt}` : '')).sort(
      (a, b) => b.created - a.created,
    ),
  }
}

function dedupe<T>(items: T[], key: (t: T) => string): T[] {
  const seen = new Set<string>()
  return items.filter((t) => {
    const k = key(t)
    if (seen.has(k)) return false
    seen.add(k)
    return true
  })
}

export const userStore = persisted('mesbah.user', sanitizeUserData)

const same = (a: { book: number; section: number }, book: number, section: number) => a.book === book && a.section === section

export function isFavorite(data: UserData, book: number, section: number): boolean {
  return data.favorites.some((f) => same(f, book, section))
}

/** @returns true when the section is now a favourite. */
export function toggleFavorite(book: BookId, section: number): boolean {
  const adding = !isFavorite(userStore.get(), book, section)
  userStore.update((d) => ({
    ...d,
    favorites: adding ? [...d.favorites, { book, section }] : d.favorites.filter((f) => !same(f, book, section)),
  }))
  return adding
}

export function moveFavorite(from: number, to: number) {
  userStore.update((d) => {
    if (to < 0 || to >= d.favorites.length) return d
    const favorites = [...d.favorites]
    favorites.splice(to, 0, ...favorites.splice(from, 1))
    return { ...d, favorites }
  })
}

/** Re-adds at the old position after an undo. */
export function restoreFavorite(fav: Favorite, index: number) {
  userStore.update((d) => {
    const favorites = d.favorites.filter((f) => !same(f, fav.book, fav.section))
    favorites.splice(Math.min(index, favorites.length), 0, fav)
    return { ...d, favorites }
  })
}

/** Counts an opening of a section; called once per section per reader visit. */
export function recordVisit(book: BookId, section: number) {
  const now = Date.now()
  userStore.update((d) => {
    const existing = d.visits.find((v) => same(v, book, section))
    const visits = existing
      ? d.visits.map((v) => (v === existing ? { ...v, count: v.count + 1, last: now } : v))
      : [...d.visits, { book, section, count: 1, last: now }]
    return { ...d, visits }
  })
}

/** Most-opened sections first; one-off visits are left out so the shelf shows real habits. */
export function frequentVisits(data: UserData): Visit[] {
  return data.visits
    .filter((v) => v.count >= 2)
    .sort((a, b) => b.count - a.count || b.last - a.last)
    .slice(0, 12)
}

export function clearVisits() {
  userStore.update((d) => ({ ...d, visits: [] }))
}

export function saveProgress(book: BookId, section: number, paragraph: number) {
  userStore.update((d) => {
    const current = d.progress.find((p) => p.book === book)
    if (current && current.section === section && current.paragraph === paragraph && d.progress[0] === current) return d
    return { ...d, progress: [{ book, section, paragraph, updated: Date.now() }, ...d.progress.filter((p) => p.book !== book)] }
  })
}

export function progressFor(data: UserData, book: number): Progress | undefined {
  return data.progress.find((p) => p.book === book)
}

export function findBookmark(data: UserData, book: number, section: number, paragraph: number): Bookmark | undefined {
  return data.bookmarks.find((b) => same(b, book, section) && b.paragraph === paragraph)
}

/** Bookmarks on any of the paragraphs `from`…`to` (a paragraph the reader joined from several). */
export function bookmarksIn(data: UserData, book: number, section: number, from: number, to: number): Bookmark[] {
  return data.bookmarks.filter((b) => same(b, book, section) && b.paragraph >= from && b.paragraph <= to)
}

/** @returns true when the paragraph is now bookmarked. */
export function toggleBookmark(book: BookId, section: number, paragraph: number, excerpt: string): boolean {
  const existing = findBookmark(userStore.get(), book, section, paragraph)
  if (existing) {
    removeBookmark(existing.id)
    return false
  }
  const bookmark: Bookmark = { id: Date.now(), book, section, paragraph, excerpt: excerpt.slice(0, MAX_EXCERPT), note: null, created: Date.now() }
  userStore.update((d) => ({ ...d, bookmarks: [bookmark, ...d.bookmarks] }))
  return true
}

export function removeBookmark(id: number) {
  userStore.update((d) => ({ ...d, bookmarks: d.bookmarks.filter((b) => b.id !== id) }))
}

/** Puts back a bookmark exactly as it was, for undo. */
export function restoreBookmark(bookmark: Bookmark) {
  userStore.update((d) => ({
    ...d,
    bookmarks: [...d.bookmarks.filter((b) => b.id !== bookmark.id), bookmark].sort((a, b) => b.created - a.created),
  }))
}

export function updateNote(id: number, note: string) {
  userStore.update((d) => ({
    ...d,
    bookmarks: d.bookmarks.map((b) => (b.id === id ? { ...b, note: note.trim() ? note : null } : b)),
  }))
}

// ---------------------------------------------------------------- backup file

const BACKUP_APP = 'mesbah-al-sadeqin'

export function exportBackup(): string {
  return JSON.stringify(
    { app: BACKUP_APP, format: 1, exported: new Date().toISOString(), settings: settingsStore.get(), ...userStore.get() },
    null,
    1,
  )
}

/**
 * Merges a backup into what is already here, so restoring on a phone that has its own data loses
 * nothing: favourites and bookmarks are added if missing, the newer reading position wins, visit
 * counts keep the larger value. Settings are taken from the file.
 * @returns false when the file is not a backup of this app.
 */
export function importBackup(text: string): boolean {
  let raw: Record<string, unknown>
  try {
    raw = JSON.parse(text)
  } catch {
    return false
  }
  if (!raw || typeof raw !== 'object' || raw.app !== BACKUP_APP) return false
  const incoming = sanitizeUserData(raw)
  const mine = userStore.get()
  const newer = new Map<number, Progress>()
  for (const p of [...mine.progress, ...incoming.progress]) {
    const cur = newer.get(p.book)
    if (!cur || p.updated > cur.updated) newer.set(p.book, p)
  }
  const visits = new Map<string, Visit>()
  for (const v of [...mine.visits, ...incoming.visits]) {
    const k = `${v.book}:${v.section}`
    const cur = visits.get(k)
    visits.set(k, cur ? { ...cur, count: Math.max(cur.count, v.count), last: Math.max(cur.last, v.last) } : v)
  }
  const bookmarks = [...mine.bookmarks]
  for (const b of incoming.bookmarks) {
    const cur = bookmarks.findIndex((x) => same(x, b.book, b.section) && x.paragraph === b.paragraph)
    if (cur < 0) bookmarks.push(bookmarks.some((x) => x.id === b.id) ? { ...b, id: Date.now() + bookmarks.length } : b)
    else if (!bookmarks[cur].note && b.note) bookmarks[cur] = { ...bookmarks[cur], note: b.note }
  }
  userStore.set(
    sanitizeUserData({
      progress: [...newer.values()],
      favorites: [...mine.favorites, ...incoming.favorites],
      visits: [...visits.values()],
      bookmarks,
    }),
  )
  if (raw.settings) settingsStore.set(sanitizeSettings(raw.settings))
  return true
}
