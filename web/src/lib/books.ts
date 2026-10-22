/** The two works, each shipped in two editions. Shared with the data build script. */

export type BookId = 1 | 2 | 3 | 4
export type WorkId = 'anis' | 'safineh'

export interface Work {
  id: WorkId
  title: string
  description: string
}

export interface Book {
  /** Matches the `N.book` source file; stored in user data and deep links, so it must never change. */
  id: BookId
  work: WorkId
  edition: string
  cover: string
  /** Anis editions store their text paragraph-by-paragraph in `Ntable3`; Safineh only has `table3`. */
  hasParagraphTable: boolean
  /** Body language decides the default font of the body text. */
  arabicBody: boolean
  /** In the with-translation edition each Arabic line is a short phrase paired with its meaning. */
  paired: boolean
}

export const WORKS: Work[] = [
  { id: 'anis', title: 'انیس الصادقین', description: 'رهنمودهای آن عالم ربانی در زمینهٔ ادعیه و اذکار' },
  { id: 'safineh', title: 'سفینة الصادقین', description: 'شرح احوال و زندگی‌نامهٔ آن بزرگوار' },
]

/**
 * What the search chips and edition switches list. Anis is one book (1.book): its translation is
 * shown or hidden by a setting, and 4.book (the edition without translation) only lends it paragraph
 * breaks at build time. Old links and saved data that name book 4 are read as book 1.
 */
export const BOOKS: Book[] = [
  { id: 1, work: 'anis', edition: '', cover: 'img/cover_anis_tr.jpg', hasParagraphTable: true, arabicBody: false, paired: true },
  { id: 3, work: 'safineh', edition: 'فارسی', cover: 'img/cover_safineh_fa.jpg', hasParagraphTable: false, arabicBody: false, paired: false },
  { id: 2, work: 'safineh', edition: 'عربی', cover: 'img/cover_safineh_ar.jpg', hasParagraphTable: false, arabicBody: true, paired: false },
]

/** The retired «بدون ترجمه» edition: its sections have the same ids in book 1. */
export const RETIRED_ANIS = 4

export function bookById(id: number): Book | undefined {
  return BOOKS.find((b) => b.id === (id === RETIRED_ANIS ? 1 : id))
}

export function workOf(book: Book): Work {
  return WORKS.find((w) => w.id === book.work)!
}

export function editionsOf(work: WorkId): Book[] {
  return BOOKS.filter((b) => b.work === work)
}

/** «سفینة الصادقین · فارسی», or just «انیس الصادقین» for a work with a single edition. */
export function bookLabel(book: Book): string {
  return workOf(book).title + (book.edition ? ' · ' + book.edition : '')
}

/** Paragraph kinds, as stored in the generated JSON. */
export const Kind = {
  /** First short line of a section, usually repeating its title. */
  Heading: 0,
  Body: 1,
  /** Arabic text of a supplication (Anis). */
  Arabic: 2,
  /** Persian translation following an Arabic line (Anis, with-translation edition). */
  Translation: 3,
  /** Author's explanation set apart from the supplication (marked «« in the source). */
  Note: 4,
  Footnote: 5,
  /** `[ص 31]` page reference of the printed book (Safineh); text is the page number. */
  PageMarker: 6,
} as const

export type KindCode = (typeof Kind)[keyof typeof Kind]

/**
 * [key, kind, text, starts?]; key is `tpart` for Anis, the source line number for Safineh. `starts`
 * is 1 on an Arabic phrase that begins a paragraph when the translation is hidden (Anis only).
 */
export type RawParagraph = [number, KindCode, string] | [number, KindCode, string, 1]

/** [id, level, title, hasContent (1|0), chunk index or -1] */
export type RawTocEntry = [number, number, string, 0 | 1, number]

export interface RawToc {
  e: RawTocEntry[]
  /** Chunk file names, relative to the book's data folder. */
  c: string[]
}

/** Normalized paragraph texts joined by '\n' (never produced by normalization), with their keys. */
export interface RawSearchIndex {
  s: number[]
  k: number[]
  /** Each paragraph's KindCode, one digit per paragraph. */
  y: string
  t: string
}

export interface DataManifest {
  version: string
  books: Record<string, { toc: string; search: string; sections: number }>
}
