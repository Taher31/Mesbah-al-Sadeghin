/**
 * Fallbacks for phones whose WebView predates Chrome 87 (2020): they ignore logical properties
 * (inset-inline, padding-inline …) and, before Chrome 84, gap in flex rows. After each rule that
 * uses one, the build adds a rule with the physical equivalent, active only under a class on
 * <html> that src/lib/polyfills.ts sets on such phones (`no-logical`, `no-flex-gap`). Newer
 * browsers never match those rules, so they render exactly as before.
 *
 * Works on the minified CSS: every innermost `selector{declarations}` is looked at in place, so a
 * rule inside @media gets its fallback inside the same @media.
 */

/** Splits a value on top-level spaces: «calc(1px + 2px) 0» → two parts. */
function parts(value: string): string[] {
  const out: string[] = []
  let depth = 0
  let current = ''
  for (const c of value.trim()) {
    if (c === '(') depth++
    if (c === ')') depth--
    if (c === ' ' && depth === 0) {
      if (current) out.push(current)
      current = ''
    } else current += c
  }
  if (current) out.push(current)
  return out
}

type Side = 'start' | 'end'
/** The physical side of a logical one, by direction. */
const side = (s: Side, rtl: boolean) => ((s === 'start') !== rtl ? 'left' : 'right')

/** Physical declarations for one logical declaration, or null if it isn't one. */
function physical(prop: string, value: string, rtl: boolean): string | null {
  const v = parts(value.replace(/!important$/, '').trim())
  const important = /!important$/.test(value) ? '!important' : ''
  const decl = (p: string, x: string) => `${p}:${x}${important}`
  let m: RegExpMatchArray | null
  if ((m = prop.match(/^(inset|padding|margin)-inline$/))) {
    const name = (s: Side) => (m![1] === 'inset' ? side(s, rtl) : `${m![1]}-${side(s, rtl)}`)
    return [decl(name('start'), v[0]), decl(name('end'), v[1] ?? v[0])].join(';')
  }
  if ((m = prop.match(/^(inset|padding|margin)-inline-(start|end)$/))) {
    const s = side(m[2] as Side, rtl)
    return decl(m[1] === 'inset' ? s : `${m[1]}-${s}`, value)
  }
  if ((m = prop.match(/^border-inline-(start|end)(-\w+)?$/))) {
    return decl(`border-${side(m[1] as Side, rtl)}${m[2] ?? ''}`, value)
  }
  if ((m = prop.match(/^(inset|padding|margin)-block$/))) {
    const name = (s: string) => (m![1] === 'inset' ? s : `${m![1]}-${s}`)
    return [decl(name('top'), v[0]), decl(name('bottom'), v[1] ?? v[0])].join(';')
  }
  return null
}

/** `html.flag[dir=rtl] .x` for `.x`; selectors on <html> itself get the class attached. */
function scoped(selector: string, flag: string): string {
  return selector
    .split(',')
    .map((s) => {
      s = s.trim()
      if (/^html\b/.test(s)) return s.replace(/^html/, `html.${flag}`)
      if (/^(\[|:root)/.test(s)) return `html.${flag}${s.replace(/^:root/, '')}`
      return `html.${flag} ${s}`
    })
    .join(',')
}

function declarations(body: string): [string, string][] {
  return body
    .split(';')
    .map((d) => d.trim())
    .filter(Boolean)
    .map((d) => {
      const i = d.indexOf(':')
      return [d.slice(0, i).trim(), d.slice(i + 1).trim()] as [string, string]
    })
}

export function legacyCss(css: string): string {
  return css.replace(/([^{}]+)\{([^{}]*)\}/g, (rule, rawSelector: string, body: string) => {
    const selector = rawSelector.trim()
    // @font-face bodies and keyframe steps (from, to, 50%) are left alone.
    if (selector.startsWith('@') || /^(from|to|[\d.]+%)(,|$)/.test(selector)) return rule
    const decls = declarations(body)
    const extra: string[] = []

    for (const dir of ['rtl', 'ltr'] as const) {
      const fixed = decls.map(([p, v]) => physical(p, v, dir === 'rtl')).filter((x): x is string => !!x)
      if (fixed.length) {
        const sel = scoped(selector, 'no-logical')
          .split(',')
          .map((s) => s.replace(/^html\.no-logical/, `html.no-logical[dir=${dir}]`))
          .join(',')
        extra.push(`${sel}{${fixed.join(';')}}`)
      }
    }

    // gap in a flex container (grid has had it since Chrome 66): margins between the children.
    const gap = decls.find(([p]) => p === 'gap')
    const display = decls.find(([p]) => p === 'display')?.[1] ?? ''
    if (gap && !/grid/.test(display) && !/::/.test(selector)) {
      const [row, column = row] = parts(gap[1])
      const vertical = decls.some(([p, v]) => p === 'flex-direction' && v.startsWith('column'))
      const wraps = decls.some(([p, v]) => p === 'flex-wrap' && v === 'wrap')
      const base = scoped(selector, 'no-flex-gap').split(',')
      if (wraps) extra.push(`${base.map((s) => s + '>*').join(',')}{-webkit-margin-end:${column};margin-bottom:${row}}`)
      else if (vertical) extra.push(`${base.map((s) => s + '>*+*').join(',')}{margin-top:${row}}`)
      // A row: space after each child but the last. An icon followed by plain text (a button's
      // label is a text node, not an element) is its container's only element.
      else extra.push(`${base.map((s) => `${s}>*:not(:last-child),${s}>.icon:only-child`).join(',')}{-webkit-margin-end:${column}}`)
    }
    return rule + extra.join('')
  })
}
