import { useEffect, useState } from 'preact/hooks'
import manifestJson from '../generated/data-manifest.json'
import { BOOKS, type BookId, type DataManifest, type KindCode, type RawParagraph, type RawSearchIndex, type RawToc } from './books'

const manifest = manifestJson as DataManifest
const base = import.meta.env.BASE_URL
export const DATA_VERSION = manifest.version

export interface TocEntry {
  id: number
  level: number
  title: string
  /** Group headers (e.g. «تعقیبات مشترکه») only organise the list and have no text of their own. */
  hasContent: boolean
  parentId: number | null
  hasChildren: boolean
  chunk: number
}

export class TableOfContents {
  readonly byId = new Map<number, TocEntry>()
  /** Sections that can be opened, in reading order — what the reader pages through. */
  readonly readable: TocEntry[]

  constructor(
    readonly book: BookId,
    readonly entries: TocEntry[],
    readonly chunks: string[],
  ) {
    for (const e of entries) this.byId.set(e.id, e)
    this.readable = entries.filter((e) => e.hasContent)
  }

  get(id: number): TocEntry | undefined {
    return this.byId.get(id)
  }

  indexOfReadable(id: number): number {
    return this.readable.findIndex((e) => e.id === id)
  }

  /** Ancestors from the root down, e.g. to show «تعقیبات نماز › تعقیبات مشترکه». */
  pathTo(id: number): TocEntry[] {
    const path: TocEntry[] = []
    let parent = this.byId.get(id)?.parentId
    while (parent != null) {
      const e = this.byId.get(parent)
      if (!e) break
      path.unshift(e)
      parent = e.parentId
    }
    return path
  }
}

export interface Paragraph {
  key: number
  kind: KindCode
  text: string
  /** Anis: this Arabic phrase begins a paragraph when the translation is hidden. */
  start?: boolean
  /** Set on Arabic phrases the reader joined into one paragraph: the key of the last one. */
  last?: number
}

const toParagraph = ([key, kind, text, start]: RawParagraph): Paragraph => (start === 1 ? { key, kind, text, start: true } : { key, kind, text })

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url)
  if (!response.ok) throw new Error(`${response.status} ${url}`)
  return response.json() as Promise<T>
}

/** Memoizes a promise but forgets failures, so a retry after going online works. */
function memo<K, V>(load: (key: K) => Promise<V>) {
  const cache = new Map<K, Promise<V>>()
  const settled = new Map<K, V>()
  const get = (key: K): Promise<V> => {
    let p = cache.get(key)
    if (!p) {
      p = load(key).then(
        (v) => {
          settled.set(key, v)
          return v
        },
        (e) => {
          cache.delete(key)
          throw e
        },
      )
      cache.set(key, p)
    }
    return p
  }
  return { get, peek: (key: K) => settled.get(key) }
}

const tocs = memo(async (book: BookId) => {
  const raw = await fetchJson<RawToc>(base + manifest.books[book].toc)
  // Parents are implied by indentation level; rebuild them with a stack walk.
  const stack: { level: number; id: number }[] = []
  const entries = raw.e.map(([id, level, title, hasContent, chunk], i): TocEntry => {
    while (stack.length && stack[stack.length - 1].level >= level) stack.pop()
    const parentId = stack.length ? stack[stack.length - 1].id : null
    stack.push({ level, id })
    const nextLevel = raw.e[i + 1]?.[1] ?? 0
    return { id, level, title, hasContent: hasContent === 1, parentId, hasChildren: nextLevel > level, chunk }
  })
  return new TableOfContents(book, entries, raw.c)
})

export const loadToc = tocs.get
export const peekToc = tocs.peek

const chunks = memo((key: string) => {
  const [book, file] = key.split('/')
  return fetchJson<Record<string, RawParagraph[]>>(`${base}data/${book}/${file}`)
})

/** @returns null when the book has no such section. */
export async function loadSection(book: BookId, sectionId: number): Promise<Paragraph[] | null> {
  const toc = await loadToc(book)
  const entry = toc.get(sectionId)
  if (!entry || entry.chunk < 0) return entry ? [] : null
  const chunk = await chunks.get(`${book}/${toc.chunks[entry.chunk]}`)
  return (chunk[sectionId] ?? []).map(toParagraph)
}

export function peekSection(book: BookId, sectionId: number): Paragraph[] | undefined {
  const toc = peekToc(book)
  const entry = toc?.get(sectionId)
  if (!toc || !entry) return undefined
  if (entry.chunk < 0) return []
  const chunk = chunks.peek(`${book}/${toc.chunks[entry.chunk]}`)
  return chunk ? (chunk[sectionId] ?? []).map(toParagraph) : undefined
}

export interface SearchIndex {
  sections: number[]
  keys: number[]
  kinds: KindCode[]
  text: string
  /** Offset in `text` where each paragraph starts. */
  starts: Int32Array
}

const searchIndexes = memo(async (book: BookId): Promise<SearchIndex> => {
  const raw = await fetchJson<RawSearchIndex>(base + manifest.books[book].search)
  const kinds = Array.from(raw.y, (c) => Number(c) as KindCode)
  const starts = new Int32Array(raw.s.length)
  let at = 0
  for (let i = 0; i < raw.s.length; i++) {
    starts[i] = at
    const nl = raw.t.indexOf('\n', at)
    at = nl < 0 ? raw.t.length : nl + 1
  }
  return { sections: raw.s, keys: raw.k, kinds, text: raw.t, starts }
})

export const loadSearchIndex = searchIndexes.get

export interface Loaded<T> {
  data: T | undefined
  error: boolean
  retry: () => void
}

/** Runs an async loader for the given deps; starts from `initial` so cached data shows without a flash. */
export function useLoad<T>(load: () => Promise<T>, deps: unknown[], initial?: () => T | undefined): Loaded<T> {
  const [state, setState] = useState<{ data: T | undefined; error: boolean }>(() => ({ data: initial?.(), error: false }))
  const [attempt, setAttempt] = useState(0)
  useEffect(() => {
    let alive = true
    const ready = initial?.()
    if (ready !== undefined) {
      setState({ data: ready, error: false })
      return
    }
    setState((s) => ({ data: s.data, error: false }))
    load().then(
      (data) => alive && setState({ data, error: false }),
      () => alive && setState({ data: undefined, error: true }),
    )
    return () => {
      alive = false
    }
  }, [...deps, attempt])
  return { ...state, retry: () => setAttempt((a) => a + 1) }
}

export function useToc(book: BookId): Loaded<TableOfContents> {
  return useLoad(() => loadToc(book), [book], () => peekToc(book))
}

/** All four tables of contents (small, precached): the home shelves can mix books. */
export function useAllTocs(): Loaded<Map<BookId, TableOfContents>> {
  const peek = () => {
    const all = BOOKS.map((b) => peekToc(b.id))
    return all.every(Boolean) ? new Map(BOOKS.map((b, i) => [b.id, all[i]!])) : undefined
  }
  return useLoad(
    async () => new Map(await Promise.all(BOOKS.map(async (b) => [b.id, await loadToc(b.id)] as const))),
    [],
    peek,
  )
}
