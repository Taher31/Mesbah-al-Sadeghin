/**
 * Folds Persian/Arabic text to a search key: drops diacritics and tatweel, unifies the letter
 * variants people type interchangeably (ی/ي/ى, ک/ك, أ/إ/آ → ا …) and digits, and collapses spacing.
 *
 * A port of the Android app's `TextNormalizer.kt` — keep the two in step. Every step maps one
 * UTF-16 unit to at most one output unit, so `normalizeWithMap` can report where each folded char
 * came from; that is what lets the reader highlight a match in the original, fully vowelled text.
 *
 * Shared by the data build script (run directly by Node) and the app, so it stays plain TS.
 */

/** Harakat, superscript alef, tatweel and Quranic marks. */
function isMark(c: number): boolean {
  return (c >= 0x064b && c <= 0x065f) || c === 0x0670 || c === 0x0640 || (c >= 0x06d6 && c <= 0x06ed)
}

/** Returns `null` for chars that carry no search meaning. */
function fold(c: number): number | null {
  if (isMark(c)) return null
  switch (c) {
    case 0x064a: // ي
    case 0x0649: // ى
    case 0x0626: // ئ
      return 0x06cc // ی
    case 0x0643: // ك
      return 0x06a9 // ک
    case 0x0623: // أ
    case 0x0625: // إ
    case 0x0622: // آ
    case 0x0671: // ٱ
      return 0x0627 // ا
    case 0x0624: // ؤ
      return 0x0648 // و
    case 0x0629: // ة
    case 0x06c0: // ۀ
      return 0x0647 // ه
    case 0x200c: // ZWNJ
    case 0x200f: // RLM
    case 0x200e: // LRM
    case 0x0a: // \n
    case 0x09: // \t
    case 0x0d: // \r
    case 0xa0: // NBSP
    case 0x20:
      return 0x20
    case 0xab: // «
    case 0xbb: // »
    case 0x22: // "
    case 0x201c: // “
    case 0x201d: // ”
      return null
  }
  if (c >= 0x06f0 && c <= 0x06f9) return 0x30 + (c - 0x06f0) // Persian digits
  if (c >= 0x0660 && c <= 0x0669) return 0x30 + (c - 0x0660) // Arabic-Indic digits
  return c
}

export function normalizeWithMap(text: string): { folded: string; map: Int32Array } {
  const out: number[] = []
  const map = new Int32Array(text.length)
  let lastWasSpace = true
  for (let i = 0; i < text.length; i++) {
    const f = fold(text.charCodeAt(i))
    if (f === null) continue
    if (f === 0x20) {
      if (lastWasSpace) continue
      lastWasSpace = true
    } else {
      lastWasSpace = false
    }
    map[out.length] = i
    out.push(f)
  }
  if (out.length > 0 && out[out.length - 1] === 0x20) out.pop()
  let folded = ''
  // Chunked to stay clear of argument-count limits on very long paragraphs.
  for (let i = 0; i < out.length; i += 8192) folded += String.fromCharCode.apply(null, out.slice(i, i + 8192))
  return { folded, map: map.subarray(0, out.length) }
}

export function normalize(text: string): string {
  return normalizeWithMap(text).folded
}

/** [start, endExclusive) in the original text's own coordinates. */
export type Range = [number, number]

/** Finds every occurrence of `normalizedQuery` in `text` and returns ranges in `text`'s coordinates. */
export function findMatches(text: string, normalizedQuery: string): Range[] {
  if (!normalizedQuery.trim()) return []
  const { folded, map } = normalizeWithMap(text)
  const result: Range[] = []
  let from = 0
  for (;;) {
    const at = folded.indexOf(normalizedQuery, from)
    if (at < 0) break
    let end = map[at + normalizedQuery.length - 1] + 1
    // Keep the last letter's vowel marks inside the highlight so they aren't cut off its base.
    while (end < text.length && isMark(text.charCodeAt(end))) end++
    result.push([map[at], end])
    from = at + normalizedQuery.length
  }
  return result
}

const persianDigits = '۰۱۲۳۴۵۶۷۸۹'

/** Shows numbers the way the rest of the Persian UI reads. */
export function fa(value: number | string): string {
  return String(value).replace(/[0-9]/g, (d) => persianDigits[d.charCodeAt(0) - 48])
}
