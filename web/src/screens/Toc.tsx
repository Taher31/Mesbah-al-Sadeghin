import { useEffect, useMemo, useState } from 'preact/hooks'
import { workOf, type Book, type BookId } from '../lib/books'
import { useToc, type TableOfContents, type TocEntry } from '../lib/data'
import { normalize } from '../lib/normalize'
import { initialScroll, navigate, routes, type Route } from '../lib/router'
import { isFavorite, progressFor, toggleFavorite, useStore, userStore } from '../lib/store'
import { BookCover, EmptyState, IconButton, LoadError, Loading, TopBar } from '../ui/common'
import { Icon } from '../ui/icons'

/** Open branches and the filter survive going into the reader and back. */
const memory = new Map<BookId, { open: Set<number>; filter: string }>()

interface Row {
  entry: TocEntry
  open: boolean
  /** Shown only while filtering, so a match can be placed in the book. */
  path?: string
}

function buildRows(toc: TableOfContents, open: Set<number>, filter: string): Row[] {
  const needle = normalize(filter)
  if (needle) {
    return toc.entries
      .filter((e) => normalize(e.title).includes(needle))
      .map((e) => ({ entry: e, open: false, path: toc.pathTo(e.id).map((p) => p.title).join(' › ') || undefined }))
  }
  // Entries are in reading order; skip everything nested under a collapsed parent.
  const rows: Row[] = []
  let hideDeeperThan = Infinity
  for (const e of toc.entries) {
    if (e.level > hideDeeperThan) continue
    hideDeeperThan = Infinity
    const isOpen = open.has(e.id)
    rows.push({ entry: e, open: isOpen })
    if (e.hasChildren && !isOpen) hideDeeperThan = e.level
  }
  return rows
}

export function Toc({ route, book }: { route: Route; book: Book }) {
  const { data: toc, error, retry } = useToc(book.id)
  const user = useStore(userStore)
  const progress = progressFor(user, book.id)

  const [state, setState] = useState(() => memory.get(book.id))
  // First visit: open the branch the reader is currently in, so they land where they left off.
  useEffect(() => {
    if (toc && !state) {
      const initial = { open: new Set(progress ? toc.pathTo(progress.section).map((e) => e.id) : []), filter: '' }
      setState(initial)
    }
  }, [toc])
  useEffect(() => {
    if (state) memory.set(book.id, state)
  }, [state])

  const rows = useMemo(() => (toc && state ? buildRows(toc, state.open, state.filter) : null), [toc, state])
  const filtering = !!state && normalize(state.filter).length > 0

  useEffect(() => {
    if (rows) window.scrollTo(0, initialScroll(route))
  }, [!!rows])

  const allOpen = !!toc && !!state && toc.entries.some((e) => e.hasChildren) && toc.entries.every((e) => !e.hasChildren || state.open.has(e.id))
  const toggle = (id: number) =>
    setState((s) => {
      if (!s) return s
      const open = new Set(s.open)
      if (open.has(id)) open.delete(id)
      else open.add(id)
      return { ...s, open }
    })

  const start = () => {
    if (progress) navigate(routes.reader(book.id, progress.section, { paragraph: progress.paragraph }))
    else if (toc?.readable[0]) navigate(routes.reader(book.id, toc.readable[0].id))
  }

  return (
    <main class="page">
      <TopBar
        title="فهرست مطالب"
        actions={
          <>
            <IconButton
              icon={allOpen ? 'unfoldLess' : 'unfoldMore'}
              label={allOpen ? 'بستن همه' : 'باز کردن همه'}
              onClick={() =>
                setState((s) => s && { ...s, open: allOpen ? new Set() : new Set(toc!.entries.filter((e) => e.hasChildren).map((e) => e.id)) })
              }
            />
            <IconButton icon="search" label="جستجو در این کتاب" onClick={() => navigate(routes.search(book.id))} />
          </>
        }
      />
      <div class="content">
        <div class="toc-header">
          <BookCover book={book} width={88} />
          <div>
            <h2>{workOf(book).title}</h2>
            {book.edition && <p class="edition">{book.edition}</p>}
            <button type="button" class={'btn ' + (progress ? 'btn-filled' : 'btn-tonal')} onClick={start} disabled={!toc}>
              {progress ? 'ادامهٔ مطالعه' : 'شروع مطالعه'}
            </button>
          </div>
        </div>

        <label class="filter">
          <Icon name="search" />
          <input
            type="search"
            placeholder="جستجو در عناوین…"
            value={state?.filter ?? ''}
            onInput={(e) => {
              const filter = (e.target as HTMLInputElement).value
              setState((s) => s && { ...s, filter })
            }}
          />
          {state?.filter && <IconButton icon="close" label="پاک کردن" onClick={() => setState((s) => s && { ...s, filter: '' })} />}
        </label>

        {error && <LoadError retry={retry} />}
        {!error && !rows && <Loading />}
        {rows && rows.length === 0 && <EmptyState icon="search" title="عنوانی با این عبارت نیست" />}
        {rows && (
          <ul class="toc-list">
            {rows.map((row) => (
              <TocRow
                key={row.entry.id}
                row={row}
                filtering={filtering}
                current={row.entry.id === progress?.section}
                favorite={isFavorite(user, book.id, row.entry.id)}
                onOpen={() => (row.entry.hasContent ? navigate(routes.reader(book.id, row.entry.id)) : toggle(row.entry.id))}
                onToggle={() => toggle(row.entry.id)}
                onFavorite={() => toggleFavorite(book.id, row.entry.id)}
              />
            ))}
          </ul>
        )}
      </div>
    </main>
  )
}

function TocRow(props: { row: Row; filtering: boolean; current: boolean; favorite: boolean; onOpen: () => void; onToggle: () => void; onFavorite: () => void }) {
  const { entry: e, open, path } = props.row
  const filtering = props.filtering
  const depth = filtering ? 0 : e.level - 1
  return (
    <li class={'toc-row' + (props.current ? ' is-current' : '') + (e.hasContent ? '' : ' is-group')} style={`--depth:${depth}`}>
      <span class="toc-lead">
        {e.hasChildren && !filtering ? (
          <button type="button" class={'toc-chevron' + (open ? ' is-open' : '')} aria-expanded={open} aria-label={open ? 'بستن' : 'باز کردن'} onClick={props.onToggle}>
            <Icon name="chevronEnd" />
          </button>
        ) : (
          <i class={'toc-dot' + (depth === 0 ? ' is-big' : '')} />
        )}
      </span>
      <button type="button" class="toc-main" onClick={props.onOpen} aria-expanded={!e.hasContent && e.hasChildren ? open : undefined}>
        {path && <span class="toc-path">{path}</span>}
        <span class={'toc-title' + (depth === 0 ? ' is-top' : '')}>{e.title}</span>
      </button>
      {e.hasContent && (
        <button
          type="button"
          class={'toc-star' + (props.favorite ? ' is-on' : '')}
          aria-label={props.favorite ? 'حذف از منتخب' : 'افزودن به منتخب'}
          aria-pressed={props.favorite}
          onClick={props.onFavorite}
        >
          <Icon name={props.favorite ? 'star' : 'starOutline'} size={22} />
        </button>
      )}
    </li>
  )
}
