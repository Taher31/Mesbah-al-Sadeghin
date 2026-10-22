import { Store } from './store'

/**
 * Hash routing, so the app works from any static host and any sub-folder, and deep links like
 * `#/r/1/10` open a section directly. Routes:
 *   (empty)            home
 *   toc/<book>         table of contents
 *   r/<book>/<section> reader; query: p=<paragraph> q=<search query> (w=1 whole words, all=1 all
 *                      words) fav=1 (walk the favourites)
 *   search[/<book>]    search; query: q=<text> w=1 all=1 in=ar|fa (only the Arabic / the Persian)
 *   favorites, bookmarks, settings, about
 */
export interface Route {
  path: string[]
  query: URLSearchParams
  /** The hash without '#/', used as the screen's identity. */
  raw: string
  /** Position in this tab's history; lets «back» leave the app's first screen gracefully. */
  depth: number
  /** True when we arrived by going back, so the screen can restore its scroll position. */
  back: boolean
}

function currentHash(): string {
  return location.hash.replace(/^#\/?/, '')
}

function parse(depth: number, back: boolean): Route {
  const raw = currentHash()
  const [path, query = ''] = raw.split('?')
  return {
    path: path.split('/').filter(Boolean).map((s) => decodeURIComponent(s)),
    query: new URLSearchParams(query),
    raw,
    depth,
    back,
  }
}

if (typeof history.state?.depth !== 'number') history.replaceState({ depth: 0 }, '')
if ('scrollRestoration' in history) history.scrollRestoration = 'manual'

export const routeStore = new Store<Route>(parse(history.state.depth, false))

const scrollMemory = new Map<string, number>()
const memoryKey = (r: { depth: number; raw: string }) => `${r.depth}|${r.raw}`

window.addEventListener('hashchange', () => {
  const prev = routeStore.get()
  scrollMemory.set(memoryKey(prev), window.scrollY)
  let depth: number
  if (typeof history.state?.depth === 'number') {
    depth = history.state.depth
  } else {
    // A fresh entry (link, typed hash, or our own navigate()).
    depth = prev.depth + 1
    history.replaceState({ depth }, '')
  }
  routeStore.set(parse(depth, depth < prev.depth))
})

export function navigate(to: string, options: { replace?: boolean } = {}) {
  if (options.replace) {
    const depth = routeStore.get().depth
    history.replaceState({ depth }, '', '#/' + to)
    routeStore.set(parse(depth, false))
  } else {
    location.hash = '/' + to
  }
}

/** Updates the address (e.g. the section being read) without re-rendering the screen. */
export function replaceSilently(to: string) {
  history.replaceState(history.state, '', '#/' + to)
}

export function goBack() {
  if (routeStore.get().depth > 0) history.back()
  else navigate('', { replace: true })
}

/** Where the screen should start: the remembered position when coming back, else the top. */
export function initialScroll(route: Route): number {
  return route.back ? (scrollMemory.get(memoryKey(route)) ?? 0) : 0
}

/** A link that opens `to` in this app, for sharing. */
export function shareUrl(to: string): string {
  return location.origin + location.pathname + '#/' + to
}

export interface SearchOptions {
  whole?: boolean
  allWords?: boolean
}

export const routes = {
  home: () => '',
  toc: (book: number) => `toc/${book}`,
  reader: (book: number, section: number, opts: { paragraph?: number; query?: string; favorites?: boolean } & SearchOptions = {}) => {
    const q = new URLSearchParams()
    if (opts.paragraph != null) q.set('p', String(opts.paragraph))
    if (opts.query) {
      q.set('q', opts.query)
      if (opts.whole) q.set('w', '1')
      if (opts.allWords) q.set('all', '1')
    }
    if (opts.favorites) q.set('fav', '1')
    const qs = q.toString()
    return `r/${book}/${section}` + (qs ? '?' + qs : '')
  },
  search: (book?: number, query?: string, opts: SearchOptions & { scope?: 'all' | 'arabic' | 'persian' } = {}) => {
    const q = new URLSearchParams()
    if (query) q.set('q', query)
    if (opts.whole) q.set('w', '1')
    if (opts.allWords) q.set('all', '1')
    if (opts.scope && opts.scope !== 'all') q.set('in', opts.scope === 'arabic' ? 'ar' : 'fa')
    const qs = q.toString()
    return (book ? `search/${book}` : 'search') + (qs ? '?' + qs : '')
  },
  favorites: () => 'favorites',
  bookmarks: () => 'bookmarks',
  settings: () => 'settings',
  about: () => 'about',
}
