/**
 * One-off: compresses the reader's TTF fonts (in the B4A project's `Files/`) to WOFF2 in `public/fonts/`.
 *
 *   node scripts/convert-fonts.mjs [--src <folder with the .ttf files>]
 *
 * Fonts are copied whole (no subsetting): the Arabic fonts carry the shaping tables the
 * vowelled supplication text depends on. The results are committed, so builds don't need this.
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import wawoff2 from 'wawoff2'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const srcArg = process.argv.indexOf('--src')
const srcDir = srcArg > 0 ? resolve(process.argv[srcArg + 1]) : resolve(root, '..', 'Files')
const outDir = join(root, 'public', 'fonts')
mkdirSync(outDir, { recursive: true })

/** Source file → name in public/fonts (as fonts.css refers to it). */
const FONTS = {
  'vazirmatn-light.ttf': 'vazirmatn_light',
  'vazirmatn-regular.ttf': 'vazirmatn_regular',
  'vazirmatn-semibold.ttf': 'vazirmatn_semibold',
  'vazirmatn-bold.ttf': 'vazirmatn_bold',
  'w_nazanin.ttf': 'nazanin',
  'w_nazanin bold.ttf': 'nazanin_bold',
  'w_lotus.ttf': 'lotus',
  'w_lotus bold.ttf': 'lotus_bold',
  'w_mitra.ttf': 'mitra',
  'w_mitra bold.ttf': 'mitra_bold',
  'w_zar.ttf': 'zar',
  'w_zar bold.ttf': 'zar_bold',
  'w_badr.ttf': 'badr',
  'w_badr bold.ttf': 'badr_bold',
  'wm_naskh qurani.ttf': 'naskh_qurani',
  'autaha.ttf': 'uthman_taha',
}

let before = 0
let after = 0
for (const [name, out] of Object.entries(FONTS)) {
  const ttf = readFileSync(join(srcDir, name))
  const woff2 = Buffer.from(await wawoff2.compress(ttf))
  writeFileSync(join(outDir, out + '.woff2'), woff2)
  before += ttf.length
  after += woff2.length
  console.log(`${name}: ${(ttf.length / 1024).toFixed(0)} KB → ${(woff2.length / 1024).toFixed(0)} KB`)
}
console.log(`total ${(before / 1024).toFixed(0)} KB → ${(after / 1024).toFixed(0)} KB`)
