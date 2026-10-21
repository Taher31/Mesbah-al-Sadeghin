/* Service worker for Mesbah al-Sadeqin. Generated at build time from sw/sw.template.js:
 * the build replaces PRECACHE with every file in dist/ and a content revision for each.
 *
 * - install: caches the app shell ("core": page, script, styles, UI font, images, tables of
 *   contents), carries over unchanged files from the previous version's cache, and takes over.
 * - message "fill": downloads the rest ("lazy": book text, search index, reader fonts) and
 *   reports progress to the pages, so after the first visit the whole app works offline.
 * - fetch: cache first for anything listed; everything else goes to the network untouched.
 * - message "skip-waiting": the page asks a waiting update to take over (kept for older pages).
 */
const PRECACHE = self.__PRECACHE__

const CACHE = 'mesbah-' + PRECACHE.version
const scope = self.registration.scope

/** Cache keys carry the revision, so a changed file never matches its old copy. */
const entry = ([url, rev]) => ({ url: new URL(url, scope).href, key: new URL(url, scope).href + '?__v=' + rev })
const core = PRECACHE.core.map(entry)
const lazy = PRECACHE.lazy.map(entry)
const all = [...core, ...lazy]
const byUrl = new Map(all.map((e) => [e.url, e]))
const page = byUrl.get(scope)

/** Hosts may redirect (e.g. /index.html → /); Safari refuses redirected responses for navigations. */
async function clean(response) {
  if (!response.redirected) return response
  return new Response(await response.blob(), { status: response.status, statusText: response.statusText, headers: response.headers })
}

async function cacheEntry(cache, e, network) {
  if (await cache.match(e.key)) return true
  // An unchanged file from the previous version's cache.
  const old = await caches.match(e.key)
  if (old) {
    await cache.put(e.key, old)
    return true
  }
  if (!network) return false
  const response = await fetch(e.url, { cache: 'no-cache' })
  if (!response.ok) throw new Error(response.status + ' ' + e.url)
  await cache.put(e.key, await clean(response))
  return true
}

/** Runs `task` over `items`, `limit` at a time. */
async function pool(items, limit, task) {
  let next = 0
  const worker = async () => {
    while (next < items.length) await task(items[next++])
  }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker))
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE)
      await pool(core, 6, (e) => cacheEntry(cache, e, true))
      await pool(lazy, 6, (e) => cacheEntry(cache, e, false))
      // Take over as soon as the new version is in place; open pages reload into it (pwa.ts).
      // Waiting for every tab to close would leave home-screen apps, which are rarely closed,
      // on the old version indefinitely.
      await self.skipWaiting()
    })(),
  )
})

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys()
      await Promise.all(names.filter((n) => n.startsWith('mesbah-') && n !== CACHE).map((n) => caches.delete(n)))
      await self.clients.claim()
    })(),
  )
})

async function broadcast(message) {
  const clients = await self.clients.matchAll({ includeUncontrolled: true })
  clients.forEach((c) => c.postMessage(message))
}

let filling = null

async function countCached(cache) {
  let done = 0
  for (const e of all) if (await cache.match(e.key)) done++
  return done
}

function fill() {
  if (!filling) {
    filling = (async () => {
      const cache = await caches.open(CACHE)
      let done = await countCached(cache)
      let failed = false
      let lastReport = 0
      const report = (force) => {
        const now = Date.now()
        if (force || now - lastReport > 400) {
          lastReport = now
          return broadcast({ type: 'progress', done, total: all.length, failed })
        }
      }
      await report(true)
      const missing = []
      for (const e of all) if (!(await cache.match(e.key))) missing.push(e)
      await pool(missing, 4, async (e) => {
        try {
          await cacheEntry(cache, e, true)
          done++
        } catch {
          failed = true
        }
        report(false)
      })
      await report(true)
    })().finally(() => {
      filling = null
    })
  }
  return filling
}

self.addEventListener('message', (event) => {
  const type = event.data && event.data.type
  if (type === 'skip-waiting') self.skipWaiting()
  else if (type === 'fill') event.waitUntil(fill())
})

self.addEventListener('fetch', (event) => {
  const request = event.request
  if (request.method !== 'GET') return
  const url = new URL(request.url)
  if (url.origin !== self.location.origin) return
  const path = url.origin + url.pathname
  // Only the app's own page is served for navigations; links to other files (the Android APK
  // under download/, anything the host adds later) go to the network untouched.
  const isPage = request.mode === 'navigate' && (path === scope || path === scope + 'index.html')
  const e = isPage ? page : byUrl.get(path)
  if (!e) return
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE)
      const hit = await cache.match(e.key)
      if (hit) return hit
      const response = await clean(await fetch(isPage ? e.url : request))
      if (response.ok) cache.put(e.key, response.clone()).catch(() => {})
      return response
    })(),
  )
})
