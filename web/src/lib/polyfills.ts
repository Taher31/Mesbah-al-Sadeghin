/**
 * The few newer functions the app uses, for old phones: Android WebViews from Chrome 61 (2017) and
 * iOS 11 Safari. Loaded before anything else; each is added only where the browser lacks it.
 * Syntax (async, ?., ??, …) is lowered by the build (vite.config.ts `build.target`).
 */
/* eslint-disable no-extend-native */

const define = (target: object, name: string, value: unknown) => {
  if (!(name in target)) Object.defineProperty(target, name, { value, writable: true, configurable: true })
}

// Chrome 69, Safari 12
define(Array.prototype, 'flat', function flat(this: unknown[], depth = 1): unknown[] {
  return depth < 1
    ? this.slice()
    : this.reduce<unknown[]>((out, x) => out.concat(Array.isArray(x) ? (x as unknown[] & { flat: typeof flat }).flat(depth - 1) : [x]), [])
})
define(Array.prototype, 'flatMap', function flatMap(this: unknown[], fn: (x: unknown, i: number, a: unknown[]) => unknown) {
  return this.reduce<unknown[]>((out, x, i, a) => out.concat(fn(x, i, a)), [])
})

// Chrome 73, Safari 13 (only used with global regular expressions)
define(String.prototype, 'matchAll', function* matchAll(this: string, re: RegExp) {
  const copy = new RegExp(re.source, re.flags.includes('g') ? re.flags : re.flags + 'g')
  let m: RegExpExecArray | null
  while ((m = copy.exec(this))) {
    yield m
    if (m[0] === '') copy.lastIndex++
  }
})

// Safari before 14 only has addListener/removeListener on matchMedia results.
if (typeof MediaQueryList !== 'undefined' && !('addEventListener' in MediaQueryList.prototype)) {
  const proto = MediaQueryList.prototype as MediaQueryList & {
    addListener: (fn: (e: MediaQueryListEvent) => void) => void
    removeListener: (fn: (e: MediaQueryListEvent) => void) => void
  }
  define(proto, 'addEventListener', function (this: typeof proto, _type: string, fn: (e: MediaQueryListEvent) => void) {
    this.addListener(fn)
  })
  define(proto, 'removeEventListener', function (this: typeof proto, _type: string, fn: (e: MediaQueryListEvent) => void) {
    this.removeListener(fn)
  })
}

export {}
