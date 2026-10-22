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
 *
 * Anis is published as one book: 1.book (Arabic phrase by phrase, each with its translation). 4.book,
 * the same text without translation, is not shipped; its editor's paragraph breaks are carried over
 * onto 1.book's phrases so that hiding the translation shows flowing paragraphs instead of a column
 * of fragments (see `paragraphStarts`).
 */
import { createHash } from 'node:crypto'
import { existsSync, mkdirSync, readFileSync, rmSync, unlinkSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { DatabaseSync } from 'node:sqlite'
import { BOOKS, Kind } from '../src/lib/books.ts'
import type { Book, DataManifest, KindCode, RawParagraph, RawSearchIndex, RawToc, RawTocEntry } from '../src/lib/books.ts'
import { normalize, normalizeWithMap } from '../src/lib/normalize.ts'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const srcArg = process.argv.indexOf('--src')
const srcDir = srcArg > 0 ? resolve(process.argv[srcArg + 1]) : resolve(root, '..', 'Files')
const outDir = join(root, 'public', 'data')
const manifestFile = join(root, 'src', 'generated', 'data-manifest.json')

const CHUNK_BYTES = 100_000
const pageMarker = /^\[ص\s*([0-9۰-۹]+)\s*]$/
const footnote = /^\(\s*[0-9۰-۹]+\s*\)/

const hash = (s: string) => createHash('sha256').update(s).digest('hex').slice(0, 10)

/** The books type numbers in Latin digits; the app shows Persian ones everywhere. Search folds both alike. */
const persianDigits = (s: string) => s.replace(/[0-9]/g, (d) => '۰۱۲۳۴۵۶۷۸۹'[d.charCodeAt(0) - 48])

function openBook(id: number): { db: DatabaseSync; close: () => void } {
  const file = join(srcDir, `${id}.book`)
  if (!existsSync(file)) throw new Error(`Missing ${file}`)
  const bytes = readFileSync(file)
  for (let i = 0; i < bytes.length; i++) bytes[i] ^= 0xff
  const tmp = join(tmpdir(), `mesbah-${process.pid}-${id}.db`)
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
    // Notes keep their «« »»: the book marks the author's own advice with them (as its preface
    // says), and copied or shared text should still show whose words they are.
    result.push([Number(r.tpart), kind, raw])
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

/** The Anis edition without translation; read only for its paragraph breaks. */
const ANIS_PARAGRAPHS_SOURCE = 4

/** Folded Arabic letters only: what both Anis editions share despite edits to vowels, punctuation and spacing. */
const letters = (s: string) => normalize(s).replace(/[^\u0621-\u064A\u066E-\u06D3\u06FA-\u06FF]/g, '')

/**
 * Keys of the Arabic phrases (book 1) that begin a paragraph when the translation is hidden.
 *
 * Every run of consecutive phrases begins one. Inside a run, each paragraph break of the edition
 * without translation is found in book 1 by the 12 letters on either side of it (searching forward
 * only, so repeated prayers map in order) and moved to the nearest phrase boundary: phrases are
 * never split and no text is changed. Where the surroundings differ between the editions (e.g.
 * instructions the other one prints inside the Arabic), shorter or one-sided contexts are tried,
 * guarded against jumping to a later repetition; failing that, the break is skipped.
 */
export function paragraphStarts(withTranslation: RawParagraph[], without: RawParagraph[]) {
  const starts = new Set<number>()
  const phrases: { key: number; end: number }[] = []
  let k1 = ''
  let previousArabic = false
  for (const [key, kind, text] of withTranslation) {
    if (kind === Kind.Translation) continue
    if (kind === Kind.Arabic) {
      if (!previousArabic) starts.add(key)
      k1 += letters(text)
      phrases.push({ key, end: k1.length })
    }
    previousArabic = kind === Kind.Arabic
  }
  let k4 = ''
  const breaks: number[] = []
  for (const [, kind, text] of without) {
    if (kind !== Kind.Arabic) continue
    if (k4.length) breaks.push(k4.length)
    k4 += letters(text)
  }
  const W = 12
  let from = 0
  let fromB = 0
  let mapped = 0
  const lost: string[] = []
  for (const b of breaks) {
    const before = k4.slice(Math.max(0, b - W), b)
    const after = k4.slice(b, b + W)
    // A one-sided match may land on a later repetition of a short invocation (e.g. «یا ارحم
    // الراحمین»), which would push every following break out of reach. So one side alone is used
    // only if it is unique ahead, or if it lies within reach of the previous break.
    const reach = Math.round((b - fromB) * 1.3) + 40
    const side = (context: string) => {
      if (context.length < W) return -1
      const i = k1.indexOf(context, from)
      if (i < 0) return -1
      return k1.indexOf(context, i + 1) < 0 || i - from <= reach ? i : -1
    }
    let at = -1
    let i = k1.indexOf(before + after, from)
    if (i >= 0) at = i + before.length
    else if ((i = k1.indexOf(before.slice(-8) + after.slice(0, 8), from)) >= 0 && i - from <= reach) at = i + 8
    else if ((i = side(before)) >= 0) at = i + before.length
    else if ((i = side(after)) >= 0) at = i
    if (at < 0) {
      lost.push(before + ' | ' + after)
      continue
    }
    mapped++
    from = at
    fromB = b
    let best = -1
    let distance = Infinity
    for (let j = 0; j < phrases.length - 1; j++) {
      const d = Math.abs(phrases[j].end - at)
      if (d < distance) {
        distance = d
        best = j
      }
    }
    if (best >= 0) starts.add(phrases[best + 1].key)
  }
  return { starts, mapped, lost }
}

/**
 * Content of 1.book that is wrong or missing, completed from 4.book. 1.book itself is left as it is:
 * each fix checks that its problem is still there and reports, instead of applying, once the book
 * has been corrected at the source. Every other difference between the editions is wording (or
 * instructions laid out differently) and is kept as 1.book has it; see BOOK-CHANGES.md.
 */
function correctAnis(sections: Map<number, RawParagraph[]>, without: DatabaseSync): string[] {
  const log: string[] = []
  const fromWithout = (id: number) => paragraphsFromNtable3(without, id)

  // «حرز یمانی» (368): parts 460–477 repeat 442–459 (pasted twice, the copy starting with a stray
  // «@»), standing where 4.book continues «… وَ لٰا تَنْفَدُ خَزائِنُكَ مَواهِبُكَ الْمُتَّسِعَةُ …
  // وَ عَمَلاً صالِحًا». The copy is replaced by that passage, as 9 phrases without translation.
  {
    const list = sections.get(368) ?? []
    const at = new Map(list.map((p) => [p[0], p]))
    const isCopy = Array.from({ length: 18 }, (_, k) => [at.get(442 + k), at.get(460 + k)]).every(
      ([a, b]) => a && b && a[1] === b[1] && a[2] === b[2].replace(/^@/, ''),
    )
    if (!isCopy) log.push('368: the repeated block is gone from 1.book; correction not needed')
    else {
      const source = new Map(fromWithout(368).map((p) => [p[0], p[2]]))
      const cut = (text: string, needle: string, after: boolean) => {
        const { folded, map } = normalizeWithMap(text)
        const i = folded.indexOf(needle)
        if (i < 0) throw new Error(`368: «${needle}» not found in ${ANIS_PARAGRAPHS_SOURCE}.book`)
        return after ? map[i + needle.length - 1] + 1 : map[i]
      }
      const p21 = source.get(21) ?? ''
      const p22 = source.get(22) ?? ''
      const a = p21.slice(cut(p21, 'خزاینک', true)).replace(/^[ً-ْٰ\s]+/, '').trim().split('، ')
      const c = p22.slice(0, cut(p22, 'و عینا باکیه', false)).trim().replace(/،$/, '').split('، ')
      if (a.length !== 4 || c.length !== 10) throw new Error('368: the passage in 4.book has changed; review the correction')
      const lines = [
        a[0] + '،', a[1] + '،', a[2] + '،', a[3],
        c[0] + '،', c.slice(1, 3).join('، ') + '،', c.slice(3, 5).join('، ') + '،', c.slice(5, 7).join('، ') + '،', c.slice(7).join('، ') + '،',
      ]
      // 4.book has no translation; these were written for this edition (approved by the publisher,
      // listed in BOOK-CHANGES.md). The line after them in 1.book already translates «وَ عَمَلاً صالِحًا».
      const translations = [
        'بخشش‌های گسترده‌ات،',
        'و عطاهای برتر و زیبا و شکوهمندت در جود بزرگت اثری نمی‌گذارد،',
        'و از سختیِ تنگدستی نمی‌هراسی تا [از بخشش] باز ایستی،',
        'و بیمِ نداری به تو نمی‌رسد تا فیضِ فضلت از جودت بکاهد.',
        'خدایا، دلی خاشع و فروتن و زاری‌کننده روزی‌ام کن،',
        'و بدنی شکیبا، و زبانی یادکننده و ستایشگر،',
        'و یقینی راستین، و روزی‌ای گسترده،',
        'و دانشی سودمند، و فرزندی شایسته،',
        'و عمری دراز، و همسری شایسته،',
      ]
      const added = lines.flatMap((text, i): RawParagraph[] => [
        [460 + 2 * i, Kind.Arabic, text],
        [461 + 2 * i, Kind.Translation, translations[i]],
      ])
      const start = list.findIndex((p) => p[0] === 460)
      const end = list.findIndex((p) => p[0] === 477)
      list.splice(start, end - start + 1, ...added)
      log.push(`368: repeated parts 460–477 replaced by ${lines.length} phrases from ${ANIS_PARAGRAPHS_SOURCE}.book, with translations`)
    }
  }

  // «دعای روز شنبه» (88): the heading cites footnotes (1) and (2); only 4.book has them.
  {
    const list = sections.get(88) ?? []
    if (list.some((p) => p[1] === Kind.Footnote)) log.push('88: 1.book has its footnotes; correction not needed')
    else {
      const notes = fromWithout(88).filter((p) => p[1] === Kind.Footnote)
      const last = list[list.length - 1][0]
      notes.forEach((p, i) => list.push([last + 1 + i, Kind.Footnote, p[2]]))
      log.push(`88: ${notes.length} footnotes added from ${ANIS_PARAGRAPHS_SOURCE}.book`)
    }
  }
  // A comma typed straight against the next word («اَمانَتی،اَوْ») runs the two together; 9 places.
  let commas = 0
  for (const list of sections.values()) {
    list.forEach((p, i) => {
      const fixed = p[2].replace(/([،,])(?=[ء-يٮ-ۓۺ-ۿ])/g, '$1 ')
      if (fixed !== p[2]) {
        commas += fixed.length - p[2].length
        list[i] = [p[0], p[1], fixed, ...p.slice(3)] as RawParagraph
      }
    })
  }
  if (commas) log.push(`spaces added after ${commas} commas`)
  return log
}

function buildBook(book: Book, manifest: DataManifest) {
  const { db, close } = openBook(book.id)
  // Anis: the edition without translation, for the corrections and the paragraph breaks below.
  const other = book.paired ? openBook(ANIS_PARAGRAPHS_SOURCE) : null
  try {
    const toc = readToc(db)
    const titles = new Map(toc.map((e) => [e.id, e.title]))
    const dir = join(outDir, String(book.id))
    mkdirSync(dir, { recursive: true })

    const search: RawSearchIndex = { s: [], k: [], y: '', t: '' }
    const searchTexts: string[] = []
    const searchKinds: KindCode[] = []
    const addSearch = (section: number, key: number, kind: KindCode, text: string) => {
      const norm = normalize(text)
      if (!norm.trim()) return
      search.s.push(section)
      search.k.push(key)
      searchKinds.push(kind)
      searchTexts.push(norm)
    }

    // Sections in reading order, each with its paragraphs.
    const sections = new Map<number, RawParagraph[]>()
    if (book.hasParagraphTable) {
      for (const e of toc) if (e.hasContent) sections.set(e.id, paragraphsFromNtable3(db, e.id))
      if (other) correctAnis(sections, other.db).forEach((l) => console.log(`book ${book.id}: ${l}`))
      for (const [id, list] of sections) for (const [key, kind, text] of list) addSearch(id, key, kind, text)
    } else {
      const texts = new Map<number, string>()
      for (const r of db.prepare('SELECT tindex, ttext FROM table3 ORDER BY tindex').all() as any[]) {
        texts.set(Number(r.tindex), String(r.ttext ?? ''))
      }
      for (const e of toc) if (e.hasContent) sections.set(e.id, paragraphsFromTable3(texts.get(e.id) ?? '', e.title))
      for (const [id, text] of texts) {
        text.split('\n').forEach((line, i) => {
          const raw = line.trim()
          if (!pageMarker.test(raw)) addSearch(id, i, footnote.test(raw) ? Kind.Footnote : Kind.Body, raw)
        })
      }
    }
    search.t = searchTexts.join('\n')
    search.y = searchKinds.join('')

    if (other) {
      // Mark where paragraphs begin for reading without the translation.
      let mapped = 0
      const lost: string[] = []
      let paragraphs = 0
      for (const [id, list] of sections) {
        const result = paragraphStarts(list, paragraphsFromNtable3(other.db, id))
        mapped += result.mapped
        lost.push(...result.lost.map((l) => `section ${id}: ${l}`))
        paragraphs += result.starts.size
        sections.set(id, list.map((p): RawParagraph => (p[1] === Kind.Arabic && result.starts.has(p[0]) ? [p[0], p[1], p[2], 1] : p)))
      }
      console.log(`book ${book.id}: without translation → ${paragraphs} Arabic paragraphs; ${mapped} breaks taken from ${ANIS_PARAGRAPHS_SOURCE}.book, ${lost.length} not found`)
      if (process.env.SHOW_LOST_BREAKS) lost.forEach((l) => console.log('  not found: ' + l))
    }

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
    for (const [id, list] of sections) {
      const paragraphs = list.map((p) => [p[0], p[1], persianDigits(p[2]), ...p.slice(3)] as RawParagraph)
      const bytes = Buffer.byteLength(JSON.stringify(paragraphs))
      if (size > 0 && size + bytes > CHUNK_BYTES) flush()
      current[id] = paragraphs
      chunkOf.set(id, chunkFiles.length)
      size += bytes
    }
    flush()

    const rawToc: RawToc = {
      e: toc.map((e): RawTocEntry => [e.id, e.level, persianDigits(e.title), e.hasContent ? 1 : 0, chunkOf.get(e.id) ?? -1]),
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
    other?.close()
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
