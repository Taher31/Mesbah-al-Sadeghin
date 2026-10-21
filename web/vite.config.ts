import { createHash } from 'node:crypto'
import { readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs'
import { join, relative, resolve } from 'node:path'
import { defineConfig, type Plugin } from 'vite'

const pkg = JSON.parse(readFileSync(new URL('./package.json', import.meta.url), 'utf8')) as { version: string }

/** Not precached: the deploy adds the APK; large install-time icons are only read by the OS. */
const SKIP = [/^sw\.js$/, /^\./, /(^|\/)\.htaccess$/, /^download\//, /\.map$/, /^icons\/(icon-512|maskable-)/]
/** Needed to show anything at all: cached at install. Everything else is downloaded right after. */
const CORE = [/^index\.html$/, /^manifest\.webmanifest$/, /^assets\//, /^img\//, /^icons\//, /^fonts\/vazirmatn_/, /^data\/\d+\/toc\./]

function walk(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? walk(path) : [path]
  })
}

/**
 * Writes dist/sw.js from sw/sw.template.js with the list of every built file and a content
 * revision for each, so a new build (new book data, new code) is picked up as an update and
 * unchanged files are carried over instead of downloaded again.
 */
function serviceWorker(): Plugin {
  let outDir = ''
  return {
    name: 'mesbah-service-worker',
    apply: 'build',
    configResolved(config) {
      outDir = resolve(config.root, config.build.outDir)
    },
    closeBundle() {
      const core: [string, string][] = []
      const lazy: [string, string][] = []
      for (const file of walk(outDir)) {
        const path = relative(outDir, file).split('\\').join('/')
        if (SKIP.some((re) => re.test(path))) continue
        const rev = createHash('sha256').update(readFileSync(file)).digest('hex').slice(0, 10)
        // The page is requested as the site root, never as /index.html.
        const url = path === 'index.html' ? '' : path
        ;(CORE.some((re) => re.test(path)) ? core : lazy).push([url, rev])
      }
      const sort = (a: [string, string], b: [string, string]) => a[0].localeCompare(b[0])
      core.sort(sort)
      lazy.sort(sort)
      const version = createHash('sha256').update(JSON.stringify([core, lazy])).digest('hex').slice(0, 10)
      const template = readFileSync(new URL('./sw/sw.template.js', import.meta.url), 'utf8')
      const precache = JSON.stringify({ version, core, lazy })
      writeFileSync(join(outDir, 'sw.js'), template.replace('self.__PRECACHE__', precache))
      const size = (list: [string, string][]) =>
        (list.reduce((n, [url]) => n + statSync(join(outDir, url || 'index.html')).size, 0) / 1024 / 1024).toFixed(1)
      console.log(`  sw.js ${version}: ${core.length} core files (${size(core)} MB) + ${lazy.length} downloaded after install (${size(lazy)} MB)`)
    },
  }
}

export default defineConfig({
  // Site root by default (the cPanel subdomain). GitHub Pages serves from /<repo>/: BASE_PATH=/<repo>/ npm run build
  base: process.env.BASE_PATH || '/',
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  esbuild: {
    jsx: 'automatic',
    jsxImportSource: 'preact',
  },
  build: {
    target: ['es2020', 'safari15', 'chrome90', 'firefox90'],
    assetsInlineLimit: 0,
    modulePreload: { polyfill: false },
    reportCompressedSize: false,
  },
  plugins: [serviceWorker()],
})
