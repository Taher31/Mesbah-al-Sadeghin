/**
 * Turns the scrambled `N.book` files into the web app's JSON data.
 *
 *   node scripts/build-data.ts [--src <folder with 1.book … 4.book>]
 *
 * Each `.book` is a SQLite database with every byte XOR-ed with 0xFF. The parsing mirrors the
 * Android app's `BookRepository.kt`: table of contents from `table2`, paragraphs from `Ntable3`
 * (Anis) or newline-split `table3` (Safineh). Output, per book, in `public/data/<id>/`:
 *   toc.<hash>.json     table of contents + which chunk holds each section
 *   c<n>.<hash>.json    sections, ~100 KB per chunk so the reader never loads a whole book
 *   search.<hash>.json  normalized text of every paragraph, precomputed for search
 * and `src/generated/data-manifest.json`, which the app bundles to find the hashed files.
 * Content hashes in the names mean a data update can never be served stale from a cache.
 */
import { createHash } from 'node:crypto'
import { existsSync, mkdirSync, readFileSync, rmSync, unlinkSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { DatabaseSync } from 'node:sqlite'
import { BOOKS, Kind } from '../src/lib/books.ts'
import type { Book, DataManifest, KindCode, RawParagraph, RawSearchIndex, RawToc, RawTocEntry } from '../src/lib/books.ts'
import { normalize } from '../src/lib/normalize.ts'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const srcArg = process.argv.indexOf('--src')
const srcDir = srcArg > 0 ? resolve(process.argv[srcArg + 1]) : resolve(root, '..', 'Files')
const outDir = join(root, 'public', 'data')
const manifestFile = join(root, 'src', 'generated', 'data-manifest.json')

const CHUNK_BYTES = 100_000
const pageMarker = /^\[ص\s*([0-9۰-۹]+)\s*]$/
const footnote = /^\(\s*[0-9۰-۹]+\s*\)/

const hash = (s: string) => createHash('sha256').update(s).digest('hex').slice(0, 10)

function openBook(book: Book): { db: DatabaseSync; close: () => void } {
  const file = join(srcDir, `${book.id}.book`)
  if (!existsSync(file)) throw new Error(`Missing ${file}`)
  const bytes = readFileSync(file)
  for (let i = 0; i < bytes.length; i++) bytes[i] ^= 0xff
  const tmp = join(tmpdir(), `mesbah-${process.pid}-${book.id}.db`)
  writeFileSync(tmp, bytes)
  const db = new DatabaseSync(tmp, { readOnly: true })
  return {
    db,
    close: () => {
      db.close()
      unlinkSync(tmp)
    },
  }
}

interface TocRow {
  id: number
  level: number
  title: string
  hasContent: boolean
}

function readToc(db: DatabaseSync): TocRow[] {
  return db
    .prepare('SELECT tindex, tlevel, ttext, ttitle FROM table2 ORDER BY tindex')
    .all()
    .map((r: any) => ({
      id: Number(r.tindex),
      level: Number(r.tlevel),
      title: String(r.ttitle ?? '').trim(),
      hasContent: Number(r.ttext) === 1,
    }))
}

function paragraphsFromNtable3(db: DatabaseSync, sectionId: number): RawParagraph[] {
  const result: RawParagraph[] = []
  const rows = db.prepare('SELECT tpart, tType, ttext FROM Ntable3 WHERE tindex = ? ORDER BY tpart').all(sectionId)
  for (const r of rows as any[]) {
    const raw = String(r.ttext ?? '').trim()
    if (!raw) continue
    let kind: KindCode
    switch (Number(r.tType)) {
      case 1: kind = Kind.Arabic; break
      case 2: kind = Kind.Translation; break
      case 3: kind = Kind.Note; break
      case 4: kind = Kind.Footnote; break
      default: kind = result.length === 0 && raw.length < 90 ? Kind.Heading : Kind.Body
    }
    const text = kind === Kind.Note ? raw.replace(/^«+/, '').replace(/»+$/, '').trim() : raw
    result.push([Number(r.tpart), kind, text])
  }
  return result
}

function paragraphsFromTable3(text: string, title: string): RawParagraph[] {
  const normalizedTitle = normalize(title)
  const result: RawParagraph[] = []
  text.split('\n').forEach((rawLine, line) => {
    const raw = rawLine.trim()
    if (!raw) return
    const page = pageMarker.exec(raw)
    if (page) result.push([line, Kind.PageMarker, page[1]])
    else if (footnote.test(raw)) result.push([line, Kind.Footnote, raw])
    else if (result.every((p) => p[1] === Kind.PageMarker) && normalize(raw) === normalizedTitle) result.push([line, Kind.Heading, raw])
    else result.push([line, Kind.Body, raw])
  })
  return result
}

function buildBook(book: Book, manifest: DataManifest) {
  const { db, close } = openBook(book)
  try {
    const toc = readToc(db)
    const titles = new Map(toc.map((e) => [e.id, e.title]))
    const dir = join(outDir, String(book.id))
    mkdirSync(dir, { recursive: true })

    const search: RawSearchIndex = { s: [], k: [], t: '' }
    const searchTexts: string[] = []
    const addSearch = (section: number, key: number, text: string) => {
      const norm = normalize(text)
      if (!norm.trim()) return
      search.s.push(section)
      search.k.push(key)
      searchTexts.push(norm)
    }

    // Sections in reading order, each with its paragraphs.
    const sections = new Map<number, RawParagraph[]>()
    if (book.hasParagraphTable) {
      for (const e of toc) if (e.hasContent) sections.set(e.id, paragraphsFromNtable3(db, e.id))
      for (const r of db.prepare('SELECT tindex, tpart, ttext FROM Ntable3 ORDER BY tindex, tpart').all() as any[]) {
        addSearch(Number(r.tindex), Number(r.tpart), String(r.ttext ?? ''))
      }
    } else {
      const texts = new Map<number, string>()
      for (const r of db.prepare('SELECT tindex, ttext FROM table3 ORDER BY tindex').all() as any[]) {
        texts.set(Number(r.tindex), String(r.ttext ?? ''))
      }
      for (const e of toc) if (e.hasContent) sections.set(e.id, paragraphsFromTable3(texts.get(e.id) ?? '', e.title))
      for (const [id, text] of texts) text.split('\n').forEach((line, i) => addSearch(id, i, line))
    }
    search.t = searchTexts.join('\n')

    // Pack consecutive sections into chunks of roughly CHUNK_BYTES.
    const chunkOf = new Map<number, number>()
    const chunkFiles: string[] = []
    let current: Record<string, RawParagraph[]> = {}
    let size = 0
    const flush = () => {
      if (size === 0) return
      const json = JSON.stringify(current)
      const name = `c${chunkFiles.length}.${hash(json)}.json`
      writeFileSync(join(dir, name), json)
      chunkFiles.push(name)
      current = {}
      size = 0
    }
    for (const [id, paragraphs] of sections) {
      const bytes = Buffer.byteLength(JSON.stringify(paragraphs))
      if (size > 0 && size + bytes > CHUNK_BYTES) flush()
      current[id] = paragraphs
      chunkOf.set(id, chunkFiles.length)
      size += bytes
    }
    flush()

    const rawToc: RawToc = {
      e: toc.map((e): RawTocEntry => [e.id, e.level, e.title, e.hasContent ? 1 : 0, chunkOf.get(e.id) ?? -1]),
      c: chunkFiles,
    }
    const tocJson = JSON.stringify(rawToc)
    const tocName = `toc.${hash(tocJson)}.json`
    writeFileSync(join(dir, tocName), tocJson)

    const searchJson = JSON.stringify(search)
    const searchName = `search.${hash(searchJson)}.json`
    writeFileSync(join(dir, searchName), searchJson)

    manifest.books[book.id] = { toc: `data/${book.id}/${tocName}`, search: `data/${book.id}/${searchName}`, sections: sections.size }
    const empty = [...sections.values()].filter((p) => p.length === 0).length
    console.log(
      `book ${book.id}: ${toc.length} toc entries, ${sections.size} sections (${empty} empty), ` +
        `${chunkFiles.length} chunks, ${search.s.length} searchable paragraphs` +
        (titles.size !== toc.length ? ' — WARNING: duplicate tindex in table2' : ''),
    )
  } finally {
    close()
  }
}

rmSync(outDir, { recursive: true, force: true })
mkdirSync(outDir, { recursive: true })
const manifest: DataManifest = { version: '', books: {} }
for (const book of BOOKS) buildBook(book, manifest)
manifest.version = hash(JSON.stringify(manifest.books))
mkdirSync(dirname(manifestFile), { recursive: true })
writeFileSync(manifestFile, JSON.stringify(manifest, null, 2) + '\n')
console.log(`data version ${manifest.version} → ${outDir}`)
