import { Kind, workOf, type Book } from './books'
import type { Paragraph } from './data'
import { num, t } from './i18n'

/** Page markers start a printed page; sections can also start on the preceding section's page. */
export function passagePages(paragraphs: Paragraph[], first: number, last: number, initialPage?: string): string[] {
  let page = initialPage
  const pages = new Set<string>()
  for (const p of paragraphs) {
    if (p.key > last) break
    if (p.kind === Kind.PageMarker) page = p.text
    // Footnotes are collected at the end of a chapter, not on their printed pages.
    else if (p.kind !== Kind.Footnote && (p.last ?? p.key) >= first && page) pages.add(page)
  }
  return [...pages]
}

export function passageReference(book: Book, title: string, pages: string[]): string {
  const page = pages.length > 1 ? `${num(pages[0])}–${num(pages[pages.length - 1])}` : pages[0] && num(pages[0])
  return [workOf(book).title, title, page ? t('ص {0}', page) : ''].filter(Boolean).join('، ')
}

export function citedPassage(text: string, reference: string, link: string): string {
  return `${text.trim()}\n\n— ${reference}\n${link}`
}

export interface SelectedPassage {
  text: string
  first: number
  last: number
}

/** Read only the selected book paragraphs, excluding headings, page labels and controls. */
export function selectedPassage(root: Element, selection: Selection | null): SelectedPassage | null {
  if (!selection || selection.isCollapsed || !selection.rangeCount) return null
  const range = selection.getRangeAt(0)
  if (!root.contains(range.startContainer) || !root.contains(range.endContainer)) return null
  const parts: { key: number; text: string }[] = []
  for (const node of root.querySelectorAll<HTMLElement>('.para:not(.k-page) p')) {
    if (!range.intersectsNode(node)) continue
    const part = range.cloneRange()
    if (!node.contains(range.startContainer)) part.setStart(node, 0)
    if (!node.contains(range.endContainer)) part.setEnd(node, node.childNodes.length)
    const text = part.toString().trim()
    if (text) parts.push({ key: Number(node.closest<HTMLElement>('.para')!.dataset.key), text })
  }
  return parts.length ? { text: parts.map((p) => p.text).join('\n\n'), first: parts[0].key, last: parts[parts.length - 1].key } : null
}
