import { Kind, type RawParagraph } from './books.ts'

/** Start a new Arabic paragraph after a full stop, or at the start of an Arabic passage. */
export function paragraphStarts(paragraphs: RawParagraph[]): Set<number> {
  const starts = new Set<number>()
  let startsParagraph = true
  for (const [key, kind, text] of paragraphs) {
    if (kind === Kind.Translation) continue
    if (kind !== Kind.Arabic) {
      startsParagraph = true
      continue
    }
    if (startsParagraph) starts.add(key)
    startsParagraph = /[.۔](?:\s*\([\d۰-۹٠-٩]+\))?\s*$/.test(text)
  }
  return starts
}
