// Run with: node scripts/test-sharing.mjs
// Exercise the actual citation and share modules without contacting a recipient app.
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
    assert.ok(id.startsWith('.'))
    return loadTs(resolve(dirname(path), id.endsWith('.ts') ? id : id + '.ts'))
  }
  vm.runInNewContext(code, { module, exports: module.exports, require }, { filename: path })
  return module.exports
}

const { citedPassage, passageReference } = loadTs(resolve(root, 'src/lib/excerpts.ts'))
const { bookById } = loadTs(resolve(root, 'src/lib/books.ts'))
const reference = passageReference(bookById(3), 'در کسوت روحانیت', ['۸۰'])
const text = citedPassage('فقط در این فکر بودم که اگر با این آلودگی‌ها بمیرم چه خواهد شد!', reference)
assert.equal(reference, 'سفینة الصادقین، در کسوت روحانیت، ص ۸۰')

function loadSharing({ android = null, share, copy } = {}) {
  const module = { exports: {} }
  const source = readFileSync(resolve(root, 'src/lib/util.ts'), 'utf8')
    .replaceAll('import.meta.env.BASE_URL', "'/'")
  const code = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText
  const require = (id) => {
    if (id === './native') return { android }
    if (id === './store') return { Store: class { constructor(value) { this.value = value } } }
    throw new Error('Unexpected dependency: ' + id)
  }
  vm.runInNewContext(code, {
    module, exports: module.exports, require,
    navigator: { share, clipboard: { writeText: copy } },
  }, { filename: 'util.ts' })
  return module.exports.shareText
}

// A target such as Eitaa reads EXTRA_TEXT, so the citation must be in text itself.
const nativeCalls = []
const nativeShare = loadSharing({ android: { share: (...args) => nativeCalls.push(args) } })
assert.equal(await nativeShare({ text }), 'shared')
assert.deepEqual(nativeCalls, [[text, '']])
assert.equal(nativeCalls[0][0].split(reference).length - 1, 1, 'native payload includes one source reference')
assert.equal(nativeCalls[0][0].includes('https://'), false, 'native sharing does not append a link')

const browserCalls = []
const browserShare = loadSharing({ share: async (data) => browserCalls.push(JSON.parse(JSON.stringify(data))) })
assert.equal(await browserShare({ text }), 'shared')
assert.deepEqual(browserCalls, [{ text }], 'browser text alone contains the full citation, without relying on title/url fields')

const clipboardCalls = []
const fallbackShare = loadSharing({ copy: async (value) => clipboardCalls.push(value) })
assert.equal(await fallbackShare({ text }), 'copied')
assert.deepEqual(clipboardCalls, [text], 'browsers without sharing copy the same cited payload')

const failedShareCopies = []
const failedShare = loadSharing({
  share: async () => { throw Object.assign(new Error('Not allowed'), { name: 'NotAllowedError' }) },
  copy: async (value) => failedShareCopies.push(value),
})
assert.equal(await failedShare({ text }), 'copied')
assert.deepEqual(failedShareCopies, [text], 'failed sharing keeps the source when falling back to copy')

let copiedAfterCancel = false
const cancelledShare = loadSharing({
  share: async () => { throw Object.assign(new Error('Cancelled'), { name: 'AbortError' }) },
  copy: async () => { copiedAfterCancel = true },
})
assert.equal(await cancelledShare({ text }), 'shared')
assert.equal(copiedAfterCancel, false, 'cancelling the share sheet must not silently replace the clipboard')
console.log('PASS: cited payload retained by Android sharing, Web Share, clipboard fallback and cancellation')
