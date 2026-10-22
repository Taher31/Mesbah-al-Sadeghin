import { useEffect, useRef, useState } from 'preact/hooks'
import { BOOKS, bookById, bookLabel, type BookId } from '../lib/books'
import { makeNeedle } from '../lib/normalize'
import { initialScroll, navigate, replaceSilently, routes, type Route } from '../lib/router'
import { search, type SearchHit, type SearchResult, type SearchScope } from '../lib/search'
import { Chip, EmptyState, IconButton, LoadError, Loading, Segmented, Sheet, TopBar } from '../ui/common'
import { ListTextSettings } from '../ui/TextSettings'
import { Icon } from '../ui/icons'
import { num, t } from '../lib/i18n'

type State = { kind: 'idle' } | { kind: 'loading' } | { kind: 'error' } | { kind: 'done'; result: SearchResult }

export function Search({ route }: { route: Route }) {
  const [query, setQuery] = useState(route.query.get('q') ?? '')
  const [book, setBook] = useState<BookId | null>(bookById(Number(route.path[1]))?.id ?? null)
  const [whole, setWhole] = useState(route.query.get('w') === '1')
  const [allWords, setAllWords] = useState(route.query.get('all') === '1')
  const [scope, setScope] = useState<SearchScope>(() => {
    const at = route.query.get('in')
    return at === 'ar' ? 'arabic' : at === 'fa' ? 'persian' : 'all'
  })
  const [advanced, setAdvanced] = useState(allWords || scope !== 'all')
  const [state, setState] = useState<State>({ kind: 'idle' })
  const [listSettings, setListSettings] = useState(false)
  const [attempt, setAttempt] = useState(0)
  const input = useRef<HTMLInputElement>(null)
  const restored = useRef(false)

  useEffect(() => {
    if (!query) input.current?.focus()
  }, [])

  useEffect(() => {
    // Remember the query in the address, so coming back from a result shows the same list.
    replaceSilently(routes.search(book ?? undefined, query.trim() || undefined, { whole, allWords, scope }))
    const needle = makeNeedle(query, { whole, allWords })
    if (!needle) {
      setState({ kind: 'idle' })
      return
    }
    let alive = true
    const timer = setTimeout(
      () => {
        setState((s) => (s.kind === 'done' ? s : { kind: 'loading' }))
        search(needle, book ? [book] : BOOKS.map((b) => b.id), scope).then(
          (result) => alive && setState({ kind: 'done', result }),
          () => alive && setState({ kind: 'error' }),
        )
      },
      restored.current ? 250 : 0,
    )
    return () => {
      alive = false
      clearTimeout(timer)
    }
  }, [query, book, whole, allWords, scope, attempt])

  useEffect(() => {
    if (state.kind === 'done' && !restored.current) {
      restored.current = true
      window.scrollTo(0, initialScroll(route))
    } else if (state.kind === 'idle') restored.current = true
  }, [state])

  const open = (hit: SearchHit) => {
    input.current?.blur()
    navigate(routes.reader(hit.book, hit.section, { paragraph: hit.paragraph, query, whole, allWords }))
  }

  return (
    <main class="page">
      <TopBar>
        <form
          class="search-field"
          role="search"
          onSubmit={(e) => {
            e.preventDefault()
            input.current?.blur()
          }}
        >
          <input
            ref={input}
            type="search"
            enterKeyHint="search"
            placeholder={book ? t('جستجو در این کتاب…') : t('جستجو در متن کتاب‌ها…')}
            value={query}
            onInput={(e) => setQuery((e.target as HTMLInputElement).value)}
          />
          {query && <IconButton icon="close" label={t('پاک کردن')} onClick={() => (setQuery(''), input.current?.focus())} />}
        </form>
        <IconButton icon="textFields" label={t('فهرست و نتایج جستجو')} onClick={() => setListSettings(true)} />
      </TopBar>
      {listSettings && (
        <Sheet label={t('فهرست و نتایج جستجو')} onClose={() => setListSettings(false)}>
          <ListTextSettings />
        </Sheet>
      )}
      <div class="content">
        <div class="chip-row chip-row-pad">
          <Chip selected={book === null} onClick={() => setBook(null)}>
            {t('همهٔ کتاب‌ها')}
          </Chip>
          {BOOKS.map((b) => (
            <Chip selected={book === b.id} onClick={() => setBook(b.id)}>
              {bookLabel(b)}
            </Chip>
          ))}
        </div>
        <div class="chip-row search-options">
          <Chip selected={whole} onClick={() => setWhole(!whole)}>
            {whole && <Icon name="check" size={16} />}
            {t('کلمهٔ کامل')}
          </Chip>
          <Chip selected={advanced} onClick={() => setAdvanced(!advanced)}>
            {t('جستجوی پیشرفته')}
            <Icon name={advanced ? 'up' : 'down'} size={18} />
          </Chip>
        </div>
        {advanced && (
          <div class="search-advanced">
            <p class="field-label">{t('کلمه‌ها')}</p>
            <Segmented
              label={t('کلمه‌ها')}
              options={[
                { id: 'phrase', label: t('عین عبارت') },
                { id: 'all', label: t('همهٔ کلمه‌ها، به هر ترتیب') },
              ]}
              value={allWords ? 'all' : 'phrase'}
              onChange={(v) => setAllWords(v === 'all')}
            />
            <p class="field-label">{t('جستجو در')}</p>
            <Segmented
              label={t('جستجو در')}
              options={[
                { id: 'all' as SearchScope, label: t('همهٔ متن') },
                { id: 'arabic' as SearchScope, label: t('متن عربی') },
                { id: 'persian' as SearchScope, label: t('ترجمه و توضیحات') },
              ]}
              value={scope}
              onChange={setScope}
            />
          </div>
        )}

        {state.kind === 'idle' && (
          <EmptyState
            icon="search"
            title={t('عبارتی برای جستجو بنویسید')}
            body={t('اعراب، «ی/ي» و «ک/ك» در جستجو اهمیتی ندارند. با «کلمهٔ کامل»، «الله» دیگر «اللهم» را پیدا نمی‌کند.')}
          />
        )}
        {state.kind === 'loading' && <Loading />}
        {state.kind === 'error' && <LoadError retry={() => setAttempt((a) => a + 1)} />}
        {state.kind === 'done' && state.result.hits.length === 0 && <EmptyState icon="search" title={t('نتیجه‌ای پیدا نشد')} />}
        {state.kind === 'done' && state.result.hits.length > 0 && (
          <>
            <p class="result-count">
              {state.result.capped
                ? t('بیش از {0} نتیجه — عبارت دقیق‌تری بنویسید', num(state.result.hits.length))
                : t('{0} نتیجه', num(state.result.hits.length))}
            </p>
            <ul class="hits">
              {state.result.hits.map((hit) => (
                <li key={`${hit.book}-${hit.section}-${hit.paragraph}`}>
                  <button type="button" class="card hit" onClick={() => open(hit)}>
                    {book === null && <span class="hit-book">{bookLabel(bookById(hit.book)!)}</span>}
                    <span class="hit-title" dir="auto">{hit.sectionTitle}</span>
                    <span class="hit-snippet" dir="auto">
                      <Snippet hit={hit} />
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </>
        )}
      </div>
    </main>
  )
}

function Snippet({ hit }: { hit: SearchHit }) {
  const parts = []
  let at = 0
  for (const [a, b] of hit.ranges) {
    if (a > at) parts.push(hit.snippet.slice(at, a))
    parts.push(<mark>{hit.snippet.slice(a, b)}</mark>)
    at = b
  }
  if (at < hit.snippet.length) parts.push(hit.snippet.slice(at))
  return <>{parts}</>
}
