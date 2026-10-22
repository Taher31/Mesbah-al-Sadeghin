import { Kind, bookById, type BookId, type KindCode } from './books'
import { loadSearchIndex, loadSection, loadToc } from './data'
import { indexOfMatch, needleRanges, type Needle, type Range } from './normalize'

export interface SearchHit {
  book: BookId
  section: number
  paragraph: number
  sectionTitle: string
  snippet: string
  ranges: Range[]
}

export interface SearchResult {
  hits: SearchHit[]
  capped: boolean
}

/** Which text to search: everything, only the Arabic of the prayers, or only the Persian around it. */
export type SearchScope = 'all' | 'arabic' | 'persian'

const SNIPPET = 160
export const LIMIT_PER_BOOK = 150

/**
 * Searches the precomputed normalized paragraphs of `books`. The query is folded the same way the
 * index was built, so «علی», «علي» and «عَلِیّ» all match each other.
 */
export async function search(needle: Needle, books: BookId[], scope: SearchScope = 'all'): Promise<SearchResult> {
  let capped = false
  const [anchor, ...others] = needle.terms
  const perBook = await Promise.all(
    books.map(async (book) => {
      const arabicBook = !!bookById(book)?.arabicBody
      const inScope = (kind: KindCode) => scope === 'all' || (kind === Kind.Arabic || arabicBook) === (scope === 'arabic')
      const [index, toc] = await Promise.all([loadSearchIndex(book), loadToc(book)])
      const found: { section: number; paragraph: number }[] = []
      let from = 0
      while (found.length <= LIMIT_PER_BOOK) {
        // The longest word finds the candidates; the paragraph must then hold all the others too.
        const at = indexOfMatch(index.text, anchor, from, needle.whole)
        if (at < 0) break
        const i = paragraphAt(index.starts, at)
        const end = i + 1 < index.starts.length ? index.starts[i + 1] : index.text.length
        const text = others.length ? index.text.slice(index.starts[i], end) : ''
        if (inScope(index.kinds[i]) && others.every((t) => indexOfMatch(text, t, 0, needle.whole) >= 0)) {
          found.push({ section: index.sections[i], paragraph: index.keys[i] })
        }
        // One hit per paragraph: continue from the next one.
        from = end
      }
      if (found.length > LIMIT_PER_BOOK) {
        capped = true
        found.length = LIMIT_PER_BOOK
      }
      const hits = await Promise.all(
        found.map(async ({ section, paragraph }): Promise<SearchHit | null> => {
          const p = (await loadSection(book, section))?.find((x) => x.key === paragraph)
          if (!p) return null
          const { snippet, ranges } = makeSnippet(p.text, needle)
          return { book, section, paragraph, sectionTitle: toc.get(section)?.title ?? '', snippet, ranges }
        }),
      )
      return hits.filter((h): h is SearchHit => h !== null)
    }),
  )
  return { hits: perBook.flat(), capped }
}

function paragraphAt(starts: Int32Array, offset: number): number {
  let lo = 0
  let hi = starts.length - 1
  while (lo < hi) {
    const mid = (lo + hi + 1) >> 1
    if (starts[mid] <= offset) lo = mid
    else hi = mid - 1
  }
  return lo
}

/** Cuts a window around the first match so long paragraphs still show the hit. */
function makeSnippet(text: string, needle: Needle): { snippet: string; ranges: Range[] } {
  const matches = needleRanges(text, needle)
  const first = matches[0]
  if (!first) return { snippet: text.slice(0, SNIPPET), ranges: [] }
  if (text.length <= SNIPPET) return { snippet: text, ranges: matches }
  let start = Math.max(0, first[0] - Math.floor(SNIPPET / 3))
  // Start on a word boundary so the snippet doesn't open mid-word.
  if (start > 0) {
    const space = text.indexOf(' ', start)
    if (space >= start && space < first[0]) start = space + 1
  }
  const end = Math.min(text.length, start + SNIPPET)
  const prefix = start > 0 ? '… ' : ''
  const suffix = end < text.length ? ' …' : ''
  const shift = prefix.length - start
  const ranges = matches.filter(([a, b]) => a >= start && b <= end).map(([a, b]): Range => [a + shift, b + shift])
  return { snippet: prefix + text.slice(start, end) + suffix, ranges }
}
