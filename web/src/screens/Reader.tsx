import type { ComponentChildren } from 'preact'
import { useEffect, useLayoutEffect, useMemo, useRef, useState } from 'preact/hooks'
import { Kind, bookById, bookLabel, type Book, type BookId } from '../lib/books'
import { loadSection, loadToc, peekSection, peekToc, type Paragraph, type TableOfContents } from '../lib/data'
import { makeNeedle, needleRanges, normalize, type Needle } from '../lib/normalize'
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
import { copyText, shareText, toast } from '../lib/util'
import { ActionRow, Chip, EmptyState, IconButton, LoadError, Loading, Ornament, Sheet, TopBar } from '../ui/common'
import { Icon } from '../ui/icons'
import { TextSettingsPanel } from '../ui/TextSettings'
import { num, t } from '../lib/i18n'

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
    const q = route.query.get('q') ?? ''
    const p = route.query.get('p')
    const at = route.query.get('at')
    return {
      needle: makeNeedle(q, { whole: route.query.get('w') === '1', allWords: route.query.get('all') === '1' }),
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
  // Page-wide classes for styles outside the reader (snackbar position, scroll bar); a class,
  // not :has(), so old phones get them too.
  useEffect(() => {
    const root = document.documentElement.classList
    root.add('reading')
    return () => root.remove('reading', 'bars-hidden')
  }, [])
  useEffect(() => {
    document.documentElement.classList.toggle('bars-hidden', chromeHidden)
  }, [chromeHidden])
  // Paragraphs used to open their menu with a tap; say once how it works now.
  useEffect(() => {
    try {
      if (localStorage.getItem('mesbah.holdHint')) return
      localStorage.setItem('mesbah.holdHint', '1')
    } catch {
      return
    }
    const timer = setTimeout(() => toast(t('برای نشانه‌گذاری، کپی یا اشتراک یک بند، انگشت را روی آن نگه دارید')), 1200)
    return () => clearTimeout(timer)
  }, [])

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

  // «جستجو در متن جاری»: the matches in the section on screen, visited one at a time.
  // Auto-scroll: null when off; paused by touching the page or reaching the section's end.
  const [autoScroll, setAutoScroll] = useState<{ playing: boolean } | null>(null)
  useEffect(() => {
    if (!autoScroll?.playing) return
    // Speed 1–10 → 10–100 px a second; fractions add up, so slow speeds stay smooth.
    const perSecond = settings.scrollSpeed * 10
    let last = performance.now()
    let carry = 0
    let frame = requestAnimationFrame(function step(now) {
      carry += ((now - last) / 1000) * perSecond
      last = now
      const px = Math.floor(carry)
      if (px > 0) {
        carry -= px
        window.scrollBy(0, px)
      }
      if (window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 2) {
        setAutoScroll({ playing: false })
        toast(t('به پایان این بخش رسید'))
        return
      }
      frame = requestAnimationFrame(step)
    })
    // The reader taking over (a touch, the wheel) pauses it.
    const pause = (e: Event) => !(e.target as Element | null)?.closest?.('.autoscroll-bar') && setAutoScroll({ playing: false })
    window.addEventListener('touchstart', pause, { passive: true })
    window.addEventListener('wheel', pause, { passive: true })
    return () => {
      cancelAnimationFrame(frame)
      window.removeEventListener('touchstart', pause)
      window.removeEventListener('wheel', pause)
    }
  }, [autoScroll?.playing, settings.scrollSpeed])

  // Shown bars step aside after a few seconds of reading; a tap brings them back.
  useEffect(() => {
    // Not while a sheet is open; using a button in the bar starts the wait again.
    if (chromeHidden || sheet) return
    const timer = setTimeout(() => setChromeHidden(true), 4000)
    return () => clearTimeout(timer)
  }, [chromeHidden, index, sheet, settings, autoScroll])

  const [find, setFind] = useState<{ text: string; whole: boolean } | null>(null)
  const [findAt, setFindAt] = useState(0)
  const findNeedle = useMemo(() => (find ? makeNeedle(find.text, { whole: find.whole }) : null), [find?.text, find?.whole])
  const matches = useMemo(() => {
    const list: { key: number; nth: number }[] = []
    if (!findNeedle || !visible) return list
    for (const p of visible) {
      if (p.kind !== Kind.PageMarker) needleRanges(p.text, findNeedle).forEach((_, nth) => list.push({ key: p.key, nth }))
    }
    return list
  }, [visible, findNeedle])
  const currentMatch = matches.length ? matches[Math.min(findAt, matches.length - 1)] : null
  useEffect(() => setFindAt(0), [matches])
  useEffect(() => {
    if (currentMatch) document.querySelector('.reader mark.is-current')?.scrollIntoView({ block: 'center' })
  }, [currentMatch])

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
    setAutoScroll((a) => a && { playing: false })
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
      '— ' + t('مصباح الصادقین') + '\n' + sectionLink(current),
    ].join('\n\n')

  const menu = (
    <>
      <ActionRow icon="list" label={t('فهرست مطالب')} onClick={() => (setSheet(null), navigate(routes.toc(current.book)))} />
      <ActionRow icon="play" label={t('اسکرول خودکار')} onClick={() => (setSheet(null), setAutoScroll({ playing: true }))} />
      <ActionRow icon="search" label={t('جستجو در متن جاری')} onClick={() => (setSheet(null), setFind((f) => f ?? { text: '', whole: false }))} />
      <ActionRow icon="search" label={t('جستجو در این کتاب')} onClick={() => (setSheet(null), navigate(routes.search(current.book)))} />
      <ActionRow
        icon="copy"
        label={t('کپی کل این بخش')}
        onClick={async () => {
          setSheet(null)
          toast((await copyText(sectionText())) ? t('کپی شد') : t('کپی نشد'))
        }}
      />
      <ActionRow
        icon="share"
        label={t('اشتراک‌گذاری این بخش')}
        onClick={async () => {
          setSheet(null)
          if ((await shareText({ title, text: sectionText() })) === 'copied') toast('متن کپی شد')
        }}
      />
      <ActionRow
        icon="link"
        label={t('اشتراک‌گذاری پیوند این بخش')}
        onClick={async () => {
          setSheet(null)
          const result = await shareText({ title, text: title + ' — ' + t('مصباح الصادقین'), url: sectionLink(current) })
          if (result === 'copied') toast('پیوند کپی شد')
        }}
      />
    </>
  )

  return (
    <main class={'reader' + (find ? ' is-finding' : '') + (chromeHidden ? ' chrome-hidden' : '')}>
      {autoScroll && (
        <div class="autoscroll-bar" role="toolbar" aria-label={t('اسکرول خودکار')}>
          <IconButton icon="close" label={t('بستن اسکرول خودکار')} onClick={() => setAutoScroll(null)} />
          <IconButton
            icon="remove"
            label={t('آهسته‌تر')}
            disabled={settings.scrollSpeed <= 1}
            onClick={() => setSetting('scrollSpeed', settings.scrollSpeed - 1)}
          />
          <span class="autoscroll-speed">{t('سرعت {0}', num(settings.scrollSpeed))}</span>
          <IconButton
            icon="add"
            label={t('تندتر')}
            disabled={settings.scrollSpeed >= 10}
            onClick={() => setSetting('scrollSpeed', settings.scrollSpeed + 1)}
          />
          <IconButton
            icon={autoScroll.playing ? 'pause' : 'play'}
            class="autoscroll-play"
            label={autoScroll.playing ? t('توقف') : t('ادامه')}
            onClick={() => setAutoScroll({ playing: !autoScroll.playing })}
          />
        </div>
      )}
      {find && (
        <FindBar
          find={find}
          count={matches.length}
          at={currentMatch ? matches.indexOf(currentMatch) : -1}
          tooShort={!findNeedle && find.text.trim() !== ''}
          onChange={setFind}
          onStep={(dir) => matches.length && setFindAt((i) => (Math.min(i, matches.length - 1) + dir + matches.length) % matches.length)}
          onClose={() => setFind(null)}
        />
      )}
      {/* Only the title on top; the tools are in the bar at the bottom, where readers look for them. */}
      <ScrollBar />
      <TopBar hidden={chromeHidden || !!find} class="reader-bar">
        <h1 dir="auto">{title}</h1>
        <p>{favoritesMode ? t('منتخب من · {0}', bookLabel(book)) : bookLabel(book)}</p>
      </TopBar>

      <div
        class="reader-pager"
        ref={pager}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onTouchCancel={onTouchEnd}
        onClick={(e) => {
          // A tap shows or hides the bars (selecting text to copy doesn't).
          const selection = window.getSelection()
          if (selection && !selection.isCollapsed && selection.toString().trim()) return
          if ((e.target as Element).closest('button, a, input')) return
          setChromeHidden((h) => !h)
        }}
      >
        <article class="section" dir="rtl" style={readerStyle(settings, book)}>
          {error && <LoadError retry={retry} />}
          {!error && !content && <Loading />}
          {content && content.paragraphs === null && (
            <EmptyState icon="search" title={t('این بخش پیدا نشد')}>
              <button type="button" class="btn btn-tonal" onClick={() => navigate(routes.toc(current.book), { replace: true })}>
                {t('فهرست مطالب')}
              </button>
            </EmptyState>
          )}
          {content && visible && (
            <>
              <SectionTitle title={title} path={path} bookLabel={favoritesMode ? bookLabel(book) : null} />
              {visible.length === 0 && <p class="empty-section">{t('این بخش متنی ندارد')}</p>}
              {visible.map((p, i) => (
                <ParagraphView
                  key={p.key}
                  p={p}
                  previous={visible[i - 1]}
                  paired={book.paired && settings.showTranslation}
                  arabic={p.kind === Kind.Arabic || (book.arabicBody && p.kind !== Kind.Footnote)}
                  needle={find ? findNeedle : isStart ? start.needle : null}
                  currentMatch={currentMatch?.key === p.key ? currentMatch.nth : null}
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

      {/* Right to left like the book, so «قبلی» sits on the right in every language. */}
      <nav class={'reader-bottom' + (chromeHidden ? ' is-hidden' : '')} dir="rtl" aria-label={t('پیمایش بخش‌ها')}>
        <div class="reader-bottom-row">
          <IconButton icon="back" label={t('قبلی')} disabled={!canPrev} onClick={() => turn(-1)} />
          {book.paired && (
            // Anis reads phrase by phrase with its translation, or as flowing Arabic without it.
            <IconButton
              icon="translate"
              pressed={settings.showTranslation}
              label={settings.showTranslation ? t('پنهان کردن ترجمه') : t('نمایش ترجمه')}
              onClick={() => {
                setSetting('showTranslation', !settings.showTranslation)
                toast(settings.showTranslation ? t('بدون ترجمه') : t('با ترجمه'))
              }}
            />
          )}
          <IconButton
            icon={favorite ? 'star' : 'starOutline'}
            class={favorite ? 'gold' : ''}
            pressed={favorite}
            label={favorite ? t('حذف از منتخب') : t('افزودن به منتخب')}
            onClick={() => toast(toggleFavorite(current.book, current.section) ? t('به «منتخب من» اضافه شد') : t('از «منتخب من» حذف شد'))}
          />
          <IconButton icon="textFields" label={t('تنظیمات متن')} onClick={() => setSheet('text')} />
          <IconButton
            icon={autoScroll?.playing ? 'pause' : 'play'}
            label={t('اسکرول خودکار')}
            pressed={!!autoScroll}
            onClick={() => setAutoScroll({ playing: !autoScroll?.playing })}
          />
          <IconButton icon="more" label={t('بیشتر')} onClick={() => setSheet('menu')} />
          <IconButton icon="forward" label={t('بعدی')} disabled={!canNext} onClick={() => turn(1)} />
        </div>
      </nav>

      {sheet === 'text' && (
        <Sheet label={t('تنظیمات متن')} onClose={() => setSheet(null)}>
          <TextSettingsPanel translationSwitch={book.paired} />
        </Sheet>
      )}
      {sheet === 'menu' && (
        <Sheet label={t('بیشتر')} onClose={() => setSheet(null)}>
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
    `--body-weight:${book.arabicBody && s.arabicBold ? 700 : 400}`,
    `--text-size:${s.textSize}px`,
    `--tr-size:${s.translationSize}px`,
    `--ar-size:${s.arabicSize}px`,
    `--ar-weight:${s.arabicBold ? 700 : 400}`,
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

/**
 * Numbers in Arabic text («* ۱۲. اَللّٰهُمَّ», «.(۱)»), each set apart in the UI font. The Arabic fonts
 * draw digits in Arabic rather than Persian shapes, and Safari on iPhone placed them on top of the
 * next word; an isolated run in another font is laid out on its own.
 */
const NUMBER = /\(\s*[۰-۹]+\s*\)|[۰-۹]+(?:[./:-][۰-۹]+)*[.)]?/g

function withNumbers(text: string, arabic: boolean): ComponentChildren {
  if (!arabic) return text
  const out: ComponentChildren[] = []
  let at = 0
  for (const m of text.matchAll(NUMBER)) {
    if (m.index > at) out.push(text.slice(at, m.index))
    out.push(<span class="num">{m[0]}</span>)
    at = m.index + m[0].length
  }
  if (at === 0) return text
  if (at < text.length) out.push(text.slice(at))
  return out
}

function Highlighted({ text, needle, current, arabic }: { text: string; needle: Needle | null; current: number | null; arabic: boolean }) {
  const ranges = needle ? needleRanges(text, needle) : []
  if (ranges.length === 0) return <>{withNumbers(text, arabic)}</>
  const out: ComponentChildren[] = []
  let at = 0
  ranges.forEach(([a, b], nth) => {
    if (a > at) out.push(withNumbers(text.slice(at, a), arabic))
    out.push(<mark class={nth === current ? 'is-current' : undefined}>{withNumbers(text.slice(a, b), arabic)}</mark>)
    at = b
  })
  if (at < text.length) out.push(withNumbers(text.slice(at), arabic))
  return <>{out}</>
}

/** The bar of «جستجو در متن جاری», in place of the reader's top bar while it is open. */
function FindBar(props: {
  find: { text: string; whole: boolean }
  count: number
  /** Index of the current match, -1 when there is none. */
  at: number
  tooShort: boolean
  onChange: (find: { text: string; whole: boolean }) => void
  onStep: (dir: 1 | -1) => void
  onClose: () => void
}) {
  const { find } = props
  const input = useRef<HTMLInputElement>(null)
  useEffect(() => input.current?.focus(), [])
  // Escape (or Android's back button) closes the bar, after any sheet open over it.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && !document.querySelector('.scrim') && props.onClose()
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [props.onClose])
  const status = props.tooShort
    ? t('دست‌کم دو حرف بنویسید')
    : !find.text.trim()
      ? t('واژه‌ای از همین بخش را بنویسید')
      : props.count === 0
        ? t('در این بخش پیدا نشد')
        : t('{0} از {1}', num(props.at + 1), num(props.count))
  return (
    <div class="find-bar" role="search">
      <div class="find-row">
        <IconButton icon="close" label={t('بستن جستجو')} onClick={props.onClose} />
        <input
          ref={input}
          type="search"
          enterKeyHint="search"
          aria-label={t('جستجو در متن جاری')}
          placeholder={t('جستجو در متن جاری…')}
          value={find.text}
          onInput={(e) => props.onChange({ ...find, text: (e.target as HTMLInputElement).value })}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault()
              props.onStep(e.shiftKey ? -1 : 1)
            }
          }}
        />
        <IconButton icon="up" label={t('مورد قبلی')} disabled={props.count < 2} onClick={() => props.onStep(-1)} />
        <IconButton icon="down" label={t('مورد بعدی')} disabled={props.count < 2} onClick={() => props.onStep(1)} />
      </div>
      <div class="find-row find-meta">
        <span class="find-count" role="status">
          {status}
        </span>
        <Chip selected={find.whole} onClick={() => props.onChange({ ...find, whole: !find.whole })}>
          {find.whole && <Icon name="check" size={16} />}
          {t('کلمهٔ کامل')}
        </Chip>
      </div>
    </div>
  )
}

function ParagraphView(props: {
  p: Paragraph
  previous: Paragraph | undefined
  paired: boolean
  /** Arabic text: numbers are set apart (see `withNumbers`). */
  arabic: boolean
  needle: Needle | null
  /** Which of this paragraph's matches is the current one of «جستجو در متن جاری». */
  currentMatch: number | null
  focused: boolean
  bookmarked: boolean
  onOpen: () => void
}) {
  const { p } = props
  const firstFootnote = p.kind === Kind.Footnote && props.previous?.kind !== Kind.Footnote
  // A tap shows or hides the bars (handled by the page); holding a paragraph opens its menu
  // (bookmark, copy, share). Right-click does the same with a mouse.
  const hold = useRef<{ timer: ReturnType<typeof setTimeout>; x: number; y: number } | null>(null)
  const held = useRef(false)
  const release = () => {
    if (hold.current) clearTimeout(hold.current.timer)
    hold.current = null
  }
  const onTouchEnd = (e: TouchEvent) => {
    release()
    // The finger lifting after a hold is not a tap: no click, so the bars stay as they are.
    if (held.current && e.cancelable) e.preventDefault()
    held.current = false
  }
  const onTouchStart = (e: TouchEvent) => {
    release()
    held.current = false
    if (e.touches.length !== 1) return
    const { clientX: x, clientY: y } = e.touches[0]
    hold.current = {
      x,
      y,
      timer: setTimeout(() => {
        hold.current = null
        held.current = true
        window.getSelection()?.removeAllRanges()
        props.onOpen()
      }, 500),
    }
  }
  const onTouchMove = (e: TouchEvent) => {
    const h = hold.current
    if (h && Math.hypot(e.touches[0].clientX - h.x, e.touches[0].clientY - h.y) > 10) release()
  }
  const text = <Highlighted text={p.text} needle={props.needle} current={props.currentMatch} arabic={props.arabic} />
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
      onTouchStart={onTouchStart}
      onTouchMove={onTouchMove}
      onTouchEnd={onTouchEnd}
      onTouchCancel={release}
      onContextMenu={(e) => {
        e.preventDefault()
        release()
        props.onOpen()
      }}
    >
      {p.kind === Kind.Note ? (
        <div class="note-card">
          <Icon name="lightbulb" size={18} />
          <p>{text}</p>
        </div>
      ) : p.kind === Kind.PageMarker ? (
        <p class="page-marker">
          <span>{t('صفحهٔ {0}', num(p.text))}</span>
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
    <Sheet label={t('بند')} onClose={props.onClose}>
      <p class="sheet-excerpt" dir="auto">{p.text}</p>
      <ActionRow
        icon={bookmarked ? 'bookmark' : 'bookmarkAdd'}
        label={bookmarked ? t('حذف نشانه') : t('نشانه‌گذاری این بند')}
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
        label={t('کپی')}
        onClick={async () => {
          props.onClose()
          toast((await copyText(p.text)) ? t('کپی شد') : t('کپی نشد'))
        }}
      />
      <ActionRow
        icon="share"
        label={t('اشتراک‌گذاری')}
        onClick={async () => {
          props.onClose()
          const result = await shareText({ text: p.text + '\n\n— ' + t('مصباح الصادقین') + '\n' + props.link })
          if (result === 'copied') toast('متن کپی شد')
        }}
      />
    </Sheet>
  )
}


/**
 * The reading page's own scroll bar: thicker and darker than the phone's, which is hard to see,
 * and it can be dragged to move quickly through a long section. It fades out when reading stops.
 */
function ScrollBar() {
  const [state, setState] = useState({ top: 0, height: 100, shown: false })
  const dragging = useRef<{ startY: number; startScroll: number } | null>(null)
  useEffect(() => {
    let hide: ReturnType<typeof setTimeout> | undefined
    const update = () => {
      const doc = document.documentElement
      const view = window.innerHeight
      const total = doc.scrollHeight
      if (total <= view + 1) return setState((s) => ({ ...s, shown: false }))
      const height = Math.max(8, (view / total) * 100)
      const top = (window.scrollY / (total - view)) * (100 - height)
      setState({ top, height, shown: true })
      clearTimeout(hide)
      hide = setTimeout(() => !dragging.current && setState((s) => ({ ...s, shown: false })), 1500)
    }
    window.addEventListener('scroll', update, { passive: true })
    window.addEventListener('resize', update)
    return () => {
      clearTimeout(hide)
      window.removeEventListener('scroll', update)
      window.removeEventListener('resize', update)
    }
  }, [])
  const onPointerDown = (e: PointerEvent) => {
    e.preventDefault()
    ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
    dragging.current = { startY: e.clientY, startScroll: window.scrollY }
  }
  const onPointerMove = (e: PointerEvent) => {
    const d = dragging.current
    if (!d) return
    const doc = document.documentElement
    const view = window.innerHeight
    const track = view * (1 - state.height / 100)
    window.scrollTo(0, d.startScroll + ((e.clientY - d.startY) / Math.max(1, track)) * (doc.scrollHeight - view))
  }
  const onPointerUp = () => {
    dragging.current = null
  }
  return (
    <div class={'scroll-bar' + (state.shown ? ' is-shown' : '')} aria-hidden="true">
      <div
        class="scroll-thumb"
        style={`top:${state.top}%;height:${state.height}%`}
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        onPointerCancel={onPointerUp}
      />
    </div>
  )
}
