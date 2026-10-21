/**
 * One-off: compresses the Android app's TTF fonts to WOFF2 in `public/fonts/`.
 *
 *   node scripts/convert-fonts.mjs [--src <folder with the .ttf files>]
 *
 * Fonts are copied whole (no subsetting): the Arabic fonts carry the shaping tables the
 * vowelled supplication text depends on. The results are committed, so builds don't need this.
 */
import { mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import wawoff2 from 'wawoff2'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const srcArg = process.argv.indexOf('--src')
const srcDir = srcArg > 0
  ? resolve(process.argv[srcArg + 1])
  : resolve(root, '..', 'android', 'app', 'src', 'main', 'res', 'font')
const outDir = join(root, 'public', 'fonts')
mkdirSync(outDir, { recursive: true })

let before = 0
let after = 0
for (const name of readdirSync(srcDir).filter((f) => f.endsWith('.ttf'))) {
  const ttf = readFileSync(join(srcDir, name))
  const woff2 = Buffer.from(await wawoff2.compress(ttf))
  writeFileSync(join(outDir, name.replace(/\.ttf$/, '.woff2')), woff2)
  before += ttf.length
  after += woff2.length
  console.log(`${name}: ${(ttf.length / 1024).toFixed(0)} KB → ${(woff2.length / 1024).toFixed(0)} KB`)
}
console.log(`total ${(before / 1024).toFixed(0)} KB → ${(after / 1024).toFixed(0)} KB`)
