import { Kind, type RawParagraph } from './books.ts'

/** Group short Arabic phrases from the translated edition into readable paragraphs. */
export function paragraphStarts(paragraphs: RawParagraph[]): Set<number> {
  const starts = new Set<number>()
  let previousArabic = false
  let length = 0
  let endsSentence = false
  for (const [key, kind, text] of paragraphs) {
    if (kind === Kind.Translation) continue
    if (kind !== Kind.Arabic) {
      previousArabic = false
      length = 0
      endsSentence = false
      continue
    }
    if (!previousArabic || endsSentence || length >= 320) {
      starts.add(key)
      length = 0
    }
    length += text.length + 1
    endsSentence = /[.!؟؛۔۞](?:\s*\([\d۰-۹٠-٩]+\))?\s*$/.test(text)
    previousArabic = true
  }
  return starts
}
