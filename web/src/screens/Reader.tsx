import type { ComponentChildren } from 'preact'
import { useEffect, useLayoutEffect, useMemo, useRef, useState } from 'preact/hooks'
import { Kind, bookById, bookLabel, type Book, type BookId } from '../lib/books'
import { loadSection, loadToc, peekSection, peekToc, type Paragraph, type TableOfContents } from '../lib/data'
import { fa, findMatches, normalize } from '../lib/normalize'
import { keepScreenOn } from '../lib/pwa'
import { navigate, replaceSilently, routes, shareUrl, type Route } from '../lib/router'
import {
  ARABIC_FONTS,
  PERSIAN_FONTS,
  bookmarksIn,
  removeBookmark,
  isFavorite,
  recordVisit,
  saveProgress,
  setSetting,
  settingsStore,
  toggleBookmark,
  toggleFavorite,
  useStore,
  userStore,
  type Settings,
  type UserData,
} from '../lib/store'
import { APP_NAME, copyText, shareText, toast } from '../lib/util'
import { ActionRow, EmptyState, IconButton, LoadError, Loading, Ornament, Sheet, TopBar } from '../ui/common'
import { Icon } from '../ui/icons'
import { TextSettingsPanel } from '../ui/TextSettings'

interface Ref {
  book: BookId
  section: number
}

const refKey = (r: Ref) => `${r.book}:${r.section}`

interface Content {
  key: string
  toc: TableOfContents
  /** null: the book has no such section (e.g. a mistyped link). */
  paragraphs: Paragraph[] | null
}

/** The section's table of contents and text; synchronous when already loaded, so paging doesn't flash. */
function useSection(ref: Ref | undefined) {
  const key = ref ? refKey(ref) : ''
  const peek = (): Content | undefined => {
    if (!ref) return undefined
    const toc = peekToc(ref.book)
    if (!toc) return undefined
    if (!toc.get(ref.section)) return { key, toc, paragraphs: null }
    const paragraphs = peekSection(ref.book, ref.section)
    return paragraphs ? { key, toc, paragraphs } : undefined
  }
  const [state, setState] = useState(peek)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)
  useEffect(() => {
    if (!ref) return
    const ready = peek()
    setError(false)
    if (ready) {
      setState(ready)
      return
    }
    setState(undefined)
    let alive = true
    Promise.all([loadToc(ref.book), loadSection(ref.book, ref.section)]).then(
      ([toc, paragraphs]) => alive && setState({ key, toc, paragraphs }),
      () => alive && setError(true),
    )
    return () => {
      alive = false
    }
  }, [key, attempt])
  return { content: state?.key === key ? state : undefined, error, retry: () => setAttempt((a) => a + 1) }
}

export function Reader({ route, book: startBook, section: startSection }: { route: Route; book: Book; section: number }) {
  const settings = useStore(settingsStore)
  const user = useStore(userStore)
  const favoritesMode = route.query.get('fav') === '1'
  // Search terms and the focused paragraph apply to the section the reader was opened at.
  const start = useMemo(() => {
    const q = normalize(route.query.get('q') ?? '')
    const p = route.query.get('p')
    const at = route.query.get('at')
    return {
      query: q.length >= 2 ? q : null,
      focus: p != null && p !== '' ? Number(p) : null,
      at: at != null && at !== '' ? Number(at) : null,
    }
  }, [])

  // What the pager pages through: the whole book, or the reader's «منتخب» list across books.
  const [pages, setPages] = useState<{ refs: Ref[]; initial: number } | null>(null)
  const [pagesError, setPagesError] = useState(false)
  const [index, setIndex] = useState(0)
  useEffect(() => {
    const begin: Ref = { book: startBook.id, section: startSection }
    const build = async () => {
      let refs: Ref[] = favoritesMode
        ? userStore.get().favorites.map((f) => ({ book: f.book, section: f.section }))
        : (await loadToc(startBook.id)).readable.map((e) => ({ book: startBook.id, section: e.id }))
      let i = refs.findIndex((r) => refKey(r) === refKey(begin))
      if (i < 0) {
        refs = [begin, ...refs]
        i = 0
      }
      setPages({ refs, initial: i })
      setIndex(i)
      setPagesError(false)
    }
    build().catch(() => setPagesError(true))
  }, [pagesError])

  const current = pages?.refs[index]
  const isStart = !!pages && index === pages.initial
  const { content, error, retry } = useSection(current)

  const [chromeHidden, setChromeHidden] = useState(false)
  const [sheet, setSheet] = useState<'text' | 'menu' | Paragraph | null>(null)
  const [focused, setFocused] = useState<number | null>(start.focus)
  const pager = useRef<HTMLDivElement>(null)
  const pendingEnter = useRef<0 | 1 | -1>(0)
  const visited = useRef(new Set<string>())

  useEffect(() => {
    keepScreenOn(settings.keepScreenOn)
    return () => keepScreenOn(false)
  }, [settings.keepScreenOn])

  // Keep neighbouring sections loaded so swiping is instant.
  useEffect(() => {
    if (!pages) return
    for (const r of [pages.refs[index - 1], pages.refs[index + 1]]) if (r) loadSection(r.book, r.section).catch(() => {})
  }, [pages, index])

  const visible = useMemo(() => {
    if (!content?.paragraphs || !current) return null
    const entry = content.toc.get(current.section)!
    // The first line usually repeats the title (or its group) already shown in the header.
    const shown = new Set([...content.toc.pathTo(current.section).map((e) => e.title), entry.title].map(normalize))
    // Without the translation, Anis's phrase-by-phrase Arabic is joined into the paragraphs of the
    // edition without translation (marked at build time); the words themselves are untouched.
    const join = !!bookById(current.book)?.paired && !settings.showTranslation
    const out: Paragraph[] = []
    for (const p of content.paragraphs) {
      if (p.kind === Kind.Translation && !settings.showTranslation) continue
      if (p.kind === Kind.Heading && shown.has(normalize(p.text))) continue
      const prev = out[out.length - 1]
      if (join && p.kind === Kind.Arabic && !p.start && prev?.kind === Kind.Arabic) {
        out[out.length - 1] = { ...prev, text: prev.text + ' ' + p.text, last: p.key }
      } else out.push(p)
    }
    return out
  }, [content, settings.showTranslation])

  // Switching the translation reflows the page; keep the paragraph that was at the top in view.
  // The old page is still in the document while this renders, so it can be measured here.
  const translationShown = useRef(settings.showTranslation)
  const keepInView = useRef<number | null>(null)
  if (translationShown.current !== settings.showTranslation) {
    translationShown.current = settings.showTranslation
    keepInView.current = firstVisibleParagraph()
  }
  useLayoutEffect(() => {
    const key = keepInView.current
    keepInView.current = null
    const node = key == null ? null : findParagraphNode(key)
    if (node) window.scrollTo(0, Math.max(0, node.getBoundingClientRect().top + window.scrollY - 90))
  }, [settings.showTranslation])

  const sectionLink = (ref: Ref, paragraph?: number) =>
    shareUrl(routes.reader(ref.book, ref.section, paragraph != null ? { paragraph } : {}))

  // Arriving at a section: position, visit count, address bar.
  useLayoutEffect(() => {
    if (!content || !current || !visible) return
    const el = pager.current
    if (el && pendingEnter.current) {
      // Slide the new section in from the side the reader swiped towards.
      const from = pendingEnter.current === 1 ? -1 : 1
      pendingEnter.current = 0
      el.style.transition = 'none'
      el.style.transform = `translateX(${from * 40}%)`
      el.style.opacity = '0'
      requestAnimationFrame(() => {
        el.style.transition = ''
        el.style.transform = ''
        el.style.opacity = ''
      })
    }
    const target = isStart ? (start.focus ?? start.at) : null
    const scrollToTarget = () => {
      const node = target == null ? null : findParagraphNode(target)
      window.scrollTo(0, node ? Math.max(0, node.getBoundingClientRect().top + window.scrollY - 120) : 0)
    }
    scrollToTarget()
    if (target != null) {
      // Web fonts arriving later reflow the text; settle on the target again unless the reader moved.
      const y = window.scrollY
      document.fonts?.ready.then(() => window.scrollY === y && scrollToTarget())
    }
    if (isStart && start.focus != null) {
      const timer = setTimeout(() => setFocused(null), 2500)
      return () => clearTimeout(timer)
    }
  }, [content?.key, !!visible])

  useEffect(() => {
    if (!content?.paragraphs || !current) return
    const key = refKey(current)
    if (!visited.current.has(key)) {
      visited.current.add(key)
      recordVisit(current.book, current.section)
    }
    // Debounced: scrolling reports positions constantly; storage only needs the resting one.
    let timer: ReturnType<typeof setTimeout> | undefined
    let lastY = window.scrollY
    const savePosition = () => {
      const p = firstVisibleParagraph()
      const paragraph = p ?? content.paragraphs![0]?.key ?? 0
      saveProgress(current.book, current.section, paragraph)
      replaceSilently(
        routes.reader(current.book, current.section, { favorites: favoritesMode }) +
          (p != null ? (favoritesMode ? '&' : '?') + 'at=' + p : ''),
      )
    }
    const onScroll = () => {
      const y = window.scrollY
      if (y > lastY + 6 && y > 80) setChromeHidden(true)
      else if (y < lastY - 6 || y < 40) setChromeHidden(false)
      lastY = y
      clearTimeout(timer)
      timer = setTimeout(savePosition, 700)
    }
    timer = setTimeout(savePosition, 300)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => {
      clearTimeout(timer)
      window.removeEventListener('scroll', onScroll)
    }
  }, [content?.key, !!content?.paragraphs])

  const canPrev = !!pages && index > 0
  const canNext = !!pages && index < pages.refs.length - 1

  /** dir 1 = next (to the left in a right-to-left book), -1 = previous. */
  const turn = (dir: 1 | -1) => {
    if (!pages || (dir === 1 ? !canNext : !canPrev)) return
    const el = pager.current
    const go = () => {
      pendingEnter.current = dir
      setChromeHidden(false)
      setFocused(null)
      setIndex((i) => i + dir)
    }
    if (!el) return go()
    el.style.transition = 'transform 160ms ease-in, opacity 160ms ease-in'
    el.style.transform = `translateX(${dir * 40}%)`
    el.style.opacity = '0'
    setTimeout(go, 150)
  }

  // Swipe between sections. Next page lies to the left, so dragging right turns forward.
  const drag = useRef<{ x: number; y: number; t: number; axis: 'x' | 'y' | null; dx: number } | null>(null)
  const onTouchStart = (e: TouchEvent) => {
    if (e.touches.length !== 1) {
      drag.current = null
      return
    }
    drag.current = { x: e.touches[0].clientX, y: e.touches[0].clientY, t: Date.now(), axis: null, dx: 0 }
  }
  const onTouchMove = (e: TouchEvent) => {
    const d = drag.current
    const el = pager.current
    if (!d || !el || e.touches.length !== 1) return
    const dx = e.touches[0].clientX - d.x
    const dy = e.touches[0].clientY - d.y
    if (!d.axis) {
      if (Math.abs(dx) < 12 && Math.abs(dy) < 12) return
      d.axis = Math.abs(dx) > Math.abs(dy) * 1.4 ? 'x' : 'y'
    }
    if (d.axis !== 'x') return
    d.dx = dx
    const allowed = dx > 0 ? canNext : canPrev
    el.style.transition = 'none'
    el.style.transform = `translateX(${allowed ? dx : dx * 0.2}px)`
  }
  const onTouchEnd = () => {
    const d = drag.current
    const el = pager.current
    drag.current = null
    if (!d || d.axis !== 'x' || !el) return
    const speed = Math.abs(d.dx) / Math.max(1, Date.now() - d.t)
    const dir = d.dx > 0 ? 1 : -1
    const allowed = dir === 1 ? canNext : canPrev
    if (allowed && (Math.abs(d.dx) > el.clientWidth * 0.22 || (speed > 0.5 && Math.abs(d.dx) > 40))) {
      turn(dir)
    } else {
      el.style.transition = ''
      el.style.transform = ''
    }
  }

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (sheet || e.altKey || e.ctrlKey || e.metaKey || (e.target as HTMLElement)?.closest?.('input, textarea')) return
      if (e.key === 'ArrowLeft') turn(1)
      else if (e.key === 'ArrowRight') turn(-1)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  })

  if (pagesError) return <ReaderShell><LoadError retry={() => setPagesError(false)} /></ReaderShell>
  if (!pages || !current) return <ReaderShell><Loading /></ReaderShell>

  const book = bookById(current.book)!
  const entry = content?.toc.get(current.section)
  const path = content ? content.toc.pathTo(current.section).map((e) => e.title) : []
  const title = entry?.title ?? ''
  const favorite = isFavorite(user, current.book, current.section)

  const sectionText = () =>
    [
      title,
      (visible ?? [])
        .filter((p) => p.kind !== Kind.PageMarker)
        .map((p) => p.text)
        .join('\n\n'),
      '— ' + APP_NAME + '\n' + sectionLink(current),
    ].join('\n\n')

  const menu = (
    <>
      <ActionRow icon="list" label="فهرست مطالب" onClick={() => (setSheet(null), navigate(routes.toc(current.book)))} />
      <ActionRow icon="search" label="جستجو در این کتاب" onClick={() => (setSheet(null), navigate(routes.search(current.book)))} />
      <ActionRow
        icon="copy"
        label="کپی کل این بخش"
        onClick={async () => {
          setSheet(null)
          toast((await copyText(sectionText())) ? 'کپی شد' : 'کپی نشد')
        }}
      />
      <ActionRow
        icon="share"
        label="اشتراک‌گذاری این بخش"
        onClick={async () => {
          setSheet(null)
          if ((await shareText({ title, text: sectionText() })) === 'copied') toast('متن کپی شد')
        }}
      />
      <ActionRow
        icon="link"
        label="اشتراک‌گذاری پیوند این بخش"
        onClick={async () => {
          setSheet(null)
          const result = await shareText({ title, text: title + ' — ' + APP_NAME, url: sectionLink(current) })
          if (result === 'copied') toast('پیوند کپی شد')
        }}
      />
    </>
  )

  return (
    <main class="reader">
      <TopBar
        hidden={chromeHidden}
        class="reader-bar"
        actions={
          <>
            {book.paired && (
              // Anis reads phrase by phrase with its translation, or as flowing Arabic without it.
              <button
                type="button"
                class={'tr-toggle' + (settings.showTranslation ? ' is-on' : '')}
                aria-pressed={settings.showTranslation}
                title={settings.showTranslation ? 'پنهان کردن ترجمه' : 'نمایش ترجمه'}
                onClick={() => {
                  setSetting('showTranslation', !settings.showTranslation)
                  toast(settings.showTranslation ? 'بدون ترجمه' : 'با ترجمه')
                }}
              >
                {settings.showTranslation && <Icon name="check" size={16} />}
                ترجمه
              </button>
            )}
            <IconButton
              icon={favorite ? 'star' : 'starOutline'}
              class={favorite ? 'gold' : ''}
              pressed={favorite}
              label={favorite ? 'حذف از منتخب' : 'افزودن به منتخب'}
              onClick={() => toast(toggleFavorite(current.book, current.section) ? 'به «منتخب من» اضافه شد' : 'از «منتخب من» حذف شد')}
            />
            <IconButton icon="textFields" label="تنظیمات متن" onClick={() => setSheet('text')} />
            <IconButton icon="more" label="بیشتر" onClick={() => setSheet('menu')} />
          </>
        }
      >
        <h1>{title}</h1>
        <p>{favoritesMode ? 'منتخب من · ' + bookLabel(book) : bookLabel(book)}</p>
      </TopBar>

      <div
        class="reader-pager"
        ref={pager}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onTouchCancel={onTouchEnd}
      >
        <article class="section" style={readerStyle(settings, book)}>
          {error && <LoadError retry={retry} />}
          {!error && !content && <Loading />}
          {content && content.paragraphs === null && (
            <EmptyState icon="search" title="این بخش پیدا نشد">
              <button type="button" class="btn btn-tonal" onClick={() => navigate(routes.toc(current.book), { replace: true })}>
                فهرست مطالب
              </button>
            </EmptyState>
          )}
          {content && visible && (
            <>
              <SectionTitle title={title} path={path} bookLabel={favoritesMode ? bookLabel(book) : null} />
              {visible.length === 0 && <p class="empty-section">این بخش متنی ندارد</p>}
              {visible.map((p, i) => (
                <ParagraphView
                  key={p.key}
                  p={p}
                  previous={visible[i - 1]}
                  paired={book.paired && settings.showTranslation}
                  query={isStart ? start.query : null}
                  focused={isStart && p.key === focusedKey(visible, focused)}
                  bookmarked={bookmarksIn(user, current.book, current.section, p.key, p.last ?? p.key).length > 0}
                  onOpen={() => setSheet(p)}
                />
              ))}
              <div class="section-end">
                <Ornament />
              </div>
            </>
          )}
        </article>
      </div>

      <nav class="reader-bottom" aria-label="پیمایش بخش‌ها">
        <div class="progress progress-line" style={`--value:${((index + 1) / pages.refs.length) * 100}%`} />
        <div class="reader-bottom-row">
          <button type="button" class="btn btn-text" disabled={!canPrev} onClick={() => turn(-1)}>
            <Icon name="back" />
            قبلی
          </button>
          <span class="page-count">
            {(favoritesMode ? '★ ' : '') + fa(index + 1) + ' / ' + fa(pages.refs.length)}
          </span>
          <button type="button" class="btn btn-text" disabled={!canNext} onClick={() => turn(1)}>
            بعدی
            <Icon name="forward" />
          </button>
        </div>
      </nav>

      {sheet === 'text' && (
        <Sheet label="تنظیمات متن" onClose={() => setSheet(null)}>
          <TextSettingsPanel />
        </Sheet>
      )}
      {sheet === 'menu' && (
        <Sheet label="بیشتر" onClose={() => setSheet(null)}>
          {menu}
        </Sheet>
      )}
      {sheet && typeof sheet === 'object' && (
        <ParagraphSheet
          p={sheet}
          user={user}
          current={current}
          link={sectionLink(current, sheet.key)}
          onClose={() => setSheet(null)}
        />
      )}
    </main>
  )
}

function ReaderShell({ children }: { children: ComponentChildren }) {
  return (
    <main class="reader">
      <TopBar title="" />
      <div class="reader-pager">{children}</div>
    </main>
  )
}

/**
 * The paragraph to highlight for `key`: the one containing it (a joined paragraph spans several
 * keys, and a hidden translation belongs to the Arabic above it), else the next one shown.
 */
function focusedKey(visible: Paragraph[], key: number | null): number | null {
  if (key == null) return null
  let found: Paragraph | undefined
  for (const p of visible) {
    if (p.key > key) break
    found = p
  }
  if (found && key <= (found.last ?? found.key) + 1) return found.key
  return visible.find((p) => p.key >= key)?.key ?? null
}

/** The shown paragraph holding `key`: the last one starting at or before it. */
function findParagraphNode(key: number): HTMLElement | null {
  const nodes = document.querySelectorAll<HTMLElement>('.reader .para[data-key]')
  let found: HTMLElement | null = null
  for (const n of nodes) {
    if (Number(n.dataset.key) > key) break
    found = n
  }
  return found ?? nodes[0] ?? null
}

function firstVisibleParagraph(): number | null {
  const nodes = document.querySelectorAll<HTMLElement>('.reader .para[data-key]')
  for (const n of nodes) if (n.getBoundingClientRect().bottom > 90) return Number(n.dataset.key)
  return null
}

function readerStyle(s: Settings, book: Book): string {
  const persian = PERSIAN_FONTS.find((f) => f.id === s.persianFont)!.family
  const arabic = ARABIC_FONTS.find((f) => f.id === s.arabicFont)!.family
  return [
    `--fa-font:${persian}`,
    `--ar-font:${arabic}`,
    `--body-font:${book.arabicBody ? arabic : persian}`,
    `--body-size:${book.arabicBody ? s.textSize + 3 : s.textSize}px`,
    `--text-size:${s.textSize}px`,
    `--ar-size:${s.arabicSize}px`,
    `--lh:${s.lineHeight}`,
    `--align:${s.justify ? 'justify' : 'start'}`,
  ].join(';')
}

/** Title block at the top of each section: breadcrumb, title and a small ornament. */
function SectionTitle({ title, path, bookLabel }: { title: string; path: string[]; bookLabel: string | null }) {
  const crumbs = [...(bookLabel ? [bookLabel] : []), ...path]
  return (
    <header class="section-title">
      {crumbs.length > 0 && <p class="crumbs">{crumbs.join('  ›  ')}</p>}
      <h2>{title}</h2>
      <Ornament />
    </header>
  )
}

const kindClass: Record<number, string> = {
  [Kind.Heading]: 'k-heading',
  [Kind.Body]: 'k-body',
  [Kind.Arabic]: 'k-arabic',
  [Kind.Translation]: 'k-translation',
  [Kind.Note]: 'k-note',
  [Kind.Footnote]: 'k-footnote',
  [Kind.PageMarker]: 'k-page',
}

function spacing(p: Paragraph, previous: Paragraph | undefined): number {
  switch (p.kind) {
    case Kind.Translation:
      return 2
    case Kind.Arabic:
      return previous?.kind === Kind.Translation || previous?.kind === Kind.Arabic ? 14 : 10
    case Kind.Footnote:
      return previous?.kind === Kind.Footnote ? 2 : 20
    case Kind.Body:
      return 10
    default:
      return 16
  }
}

function Highlighted({ text, query }: { text: string; query: string | null }) {
  if (!query) return <>{text}</>
  const ranges = findMatches(text, query)
  if (ranges.length === 0) return <>{text}</>
  const out: ComponentChildren[] = []
  let at = 0
  for (const [a, b] of ranges) {
    if (a > at) out.push(text.slice(at, a))
    out.push(<mark>{text.slice(a, b)}</mark>)
    at = b
  }
  if (at < text.length) out.push(text.slice(at))
  return <>{out}</>
}

function ParagraphView(props: {
  p: Paragraph
  previous: Paragraph | undefined
  paired: boolean
  query: string | null
  focused: boolean
  bookmarked: boolean
  onOpen: () => void
}) {
  const { p } = props
  const firstFootnote = p.kind === Kind.Footnote && props.previous?.kind !== Kind.Footnote
  const open = () => {
    // Selecting text to copy part of it shouldn't pop the menu.
    const selection = window.getSelection()
    if (selection && !selection.isCollapsed && selection.toString().trim()) return
    props.onOpen()
  }
  const text = <Highlighted text={p.text} query={props.query} />
  return (
    <div
      class={
        'para ' +
        kindClass[p.kind] +
        (props.paired ? ' is-paired' : '') +
        (props.focused ? ' is-focused' : '') +
        (firstFootnote ? ' first-footnote' : '')
      }
      data-key={p.key}
      style={`margin-top:${spacing(p, props.previous)}px`}
      onClick={open}
    >
      {p.kind === Kind.Note ? (
        <div class="note-card">
          <Icon name="lightbulb" size={18} />
          <p>{text}</p>
        </div>
      ) : p.kind === Kind.PageMarker ? (
        <p class="page-marker">
          <span>صفحهٔ {fa(p.text)}</span>
        </p>
      ) : (
        <p>{text}</p>
      )}
      {props.bookmarked && <Icon name="bookmark" size={16} class="para-mark" />}
    </div>
  )
}

function ParagraphSheet(props: { p: Paragraph; user: UserData; current: Ref; link: string; onClose: () => void }) {
  const { p, current } = props
  // A joined paragraph counts as bookmarked if any of its phrases is.
  const marks = bookmarksIn(props.user, current.book, current.section, p.key, p.last ?? p.key)
  const bookmarked = marks.length > 0
  return (
    <Sheet label="بند" onClose={props.onClose}>
      <p class="sheet-excerpt">{p.text}</p>
      <ActionRow
        icon={bookmarked ? 'bookmark' : 'bookmarkAdd'}
        label={bookmarked ? 'حذف نشانه' : 'نشانه‌گذاری این بند'}
        onClick={() => {
          props.onClose()
          if (marks.length > 0) {
            marks.forEach((m) => removeBookmark(m.id))
            toast('نشانه حذف شد')
          } else {
            toggleBookmark(current.book, current.section, p.key, p.text)
            toast('نشانه اضافه شد')
          }
        }}
      />
      <ActionRow
        icon="copy"
        label="کپی"
        onClick={async () => {
          props.onClose()
          toast((await copyText(p.text)) ? 'کپی شد' : 'کپی نشد')
        }}
      />
      <ActionRow
        icon="share"
        label="اشتراک‌گذاری"
        onClick={async () => {
          props.onClose()
          const result = await shareText({ text: p.text + '\n\n— ' + APP_NAME + '\n' + props.link })
          if (result === 'copied') toast('متن کپی شد')
        }}
      />
    </Sheet>
  )
}

