// Run with: node scripts/test-excerpts.mjs
// Test citation generation against the actual printed-page markers shipped with the books.
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import vm from 'node:vm'
import ts from 'typescript'

const root = fileURLToPath(new URL('../', import.meta.url))
const modules = new Map()
function loadTs(filename) {
  const path = resolve(filename)
  if (modules.has(path)) return modules.get(path).exports
  const module = { exports: {} }
  modules.set(path, module)
  const code = ts.transpileModule(readFileSync(path, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText
  const require = (id) => {
    assert.ok(id.startsWith('.'), 'test only loads the real local citation dependencies')
    return loadTs(resolve(dirname(path), id.endsWith('.ts') ? id : id + '.ts'))
  }
  vm.runInNewContext(code, { module, exports: module.exports, require }, { filename: path })
  return module.exports
}

const { passagePages, passageReference, citedPassage } = loadTs(resolve(root, 'src/lib/excerpts.ts'))
const { bookById } = loadTs(resolve(root, 'src/lib/books.ts'))
const manifest = JSON.parse(readFileSync(resolve(root, 'src/generated/data-manifest.json'), 'utf8'))
function section(book, id) {
  const tocPath = resolve(root, 'public', manifest.books[book].toc)
  const toc = JSON.parse(readFileSync(tocPath, 'utf8'))
  const entry = toc.e.find((e) => e[0] === id)
  assert.ok(entry)
  const chunk = JSON.parse(readFileSync(resolve(dirname(tocPath), toc.c[entry[4]]), 'utf8'))
  const paragraphs = chunk[id].map(([key, kind, text]) => ({ key, kind, text }))
  return { paragraphs, title: entry[2], initialPage: toc.p?.[id] }
}
const pages = (s, first, last = first) => Array.from(passagePages(s.paragraphs, first, last, s.initialPage))

const safineh = section(3, 8)
assert.equal(safineh.title, 'در کسوت روحانیت')
assert.deepEqual(pages(safineh, 19), ['۸۰'])
assert.deepEqual(pages(safineh, 17, 19), ['۷۹', '۸۰'])
assert.deepEqual(pages(safineh, 19, 25), ['۸۰'])
assert.deepEqual(pages(safineh, -Infinity, Infinity), Array.from({ length: 19 }, (_, n) => String(n + 77).replace(/\d/g, (d) => '۰۱۲۳۴۵۶۷۸۹'[+d])))
const ref = passageReference(bookById(3), safineh.title, pages(safineh, 19))
assert.equal(ref, 'سفینة الصادقین، در کسوت روحانیت، ص ۸۰')
assert.equal(passageReference(bookById(3), safineh.title, pages(safineh, 17, 19)), 'سفینة الصادقین، در کسوت روحانیت، ص ۷۹–۸۰')
assert.equal(citedPassage('  متن انتخاب‌شده  ', ref), 'متن انتخاب‌شده\n\n— ' + ref)

// These chapters begin in the middle of a page, before their own first page marker.
assert.deepEqual(pages(section(3, 14), 1), ['۱۲۴'])
assert.deepEqual(pages(section(3, 14), 3), ['۱۲۵'])
assert.deepEqual(pages(section(3, 54), 1), ['۴۷۲'])
assert.deepEqual(pages(section(3, 85), -Infinity, Infinity), [], 'app version information has no printed page')
const footnote = safineh.paragraphs.find((p) => p.kind === 5)
assert.ok(footnote)
assert.deepEqual(pages(safineh, footnote.key), [], 'collected footnotes do not inherit the last body page')

// Editions without printed page data still cite book and section, without inventing a page.
const anis = section(1, 10)
assert.deepEqual(pages(anis, -Infinity, Infinity), [])
assert.equal(passageReference(bookById(1), anis.title, []), 'انیس الصادقین، ' + anis.title)
// Use an actual fourth-level Anis prayer to verify that no parent category is omitted.
const toc = JSON.parse(readFileSync(resolve(root, 'public', manifest.books[1].toc), 'utf8'))
const parents = []
let deepEntry
for (const entry of toc.e) {
  while (parents.length && parents.at(-1)[1] >= entry[1]) parents.pop()
  if (entry[0] === 228) { deepEntry = entry; break }
  parents.push(entry)
}
assert.equal(deepEntry[1], 4)
assert.equal(passageReference(bookById(1), deepEntry[2], [], parents.map((e) => e[2])),
  'انیس الصادقین، نمازها، * ۷. نماز شب، دعاهای پس از هشت رکعت نافلۀ شب، * الف) دعای حضرت آدم (ع) (یا رَبّاهُ یا رَبّاهُ یا رَبّاهُ)')
assert.equal(passageReference(bookById(1), 'صلوات', [], ['انیس الصّادقین', 'صلوات']), 'انیس الصادقین، صلوات')
assert.deepEqual(pages(section(2, 8), -Infinity, Infinity), [])
console.log('PASS: real Safineh single/multiple pages, mid-page chapter starts, exact citation footer and editions without page markers')
