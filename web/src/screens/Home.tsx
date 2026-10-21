import { WORKS, bookById, bookLabel, editionsOf, workOf, type BookId, type Work } from '../lib/books'
import { useAllTocs, type TableOfContents } from '../lib/data'
import { fa } from '../lib/normalize'
import { navigate, routes } from '../lib/router'
import { editionOf, frequentVisits, setSetting, settingsStore, useStore, userStore, type Progress } from '../lib/store'
import { ANDROID_APK, APP_NAME, CHANNEL_URL, asset } from '../lib/util'
import { BookCover, SectionLabel, Segmented, TranslationToggle } from '../ui/common'
import { Icon } from '../ui/icons'
import { isAndroid } from '../lib/pwa'
import { InstallBanner, OfflineStatus } from '../ui/PwaUi'

const HOME_FAVORITES = 6

interface ShelfItem {
  book: BookId
  section: number
  title: string
  /** The group it sits in, e.g. «تعقیبات مشترکه», when there is one. */
  group?: string
  visits?: number
}

function shelfItem(tocs: Map<BookId, TableOfContents>, book: BookId, section: number): ShelfItem | null {
  const toc = tocs.get(book)
  const entry = toc?.get(section)
  if (!toc || !entry) return null
  return { book, section, title: entry.title, group: toc.pathTo(section).pop()?.title }
}

export function Home() {
  const settings = useStore(settingsStore)
  const user = useStore(userStore)
  const { data: tocs } = useAllTocs()

  const favorites = tocs ? user.favorites.map((f) => shelfItem(tocs, f.book, f.section)).filter((x): x is ShelfItem => !!x) : null
  const frequent: ShelfItem[] = tocs
    ? frequentVisits(user).flatMap((v) => {
        const item = shelfItem(tocs, v.book, v.section)
        return item ? [{ ...item, visits: v.count }] : []
      })
    : []
  const continueItems = tocs
    ? user.progress.flatMap((p) => {
        const toc = tocs.get(p.book)
        const entry = toc?.get(p.section)
        if (!toc || !entry) return []
        const index = Math.max(0, toc.indexOfReadable(p.section))
        return [{ progress: p, title: entry.title, fraction: (index + 1) / Math.max(1, toc.readable.length) }]
      })
    : []

  return (
    <main class="home">
      <Hero />
      <div class="home-body">
        <button type="button" class="search-pill" onClick={() => navigate(routes.search())}>
          <Icon name="search" />
          <span>جستجو در متن کتاب‌ها…</span>
        </button>

        <InstallBanner />

        {favorites && <FavoritesShelf items={favorites} />}

        {continueItems.length > 0 && (
          <>
            <SectionLabel>ادامهٔ مطالعه</SectionLabel>
            <div class="h-scroll">
              {continueItems.map((item) => (
                <ContinueCard key={item.progress.book} progress={item.progress} title={item.title} fraction={item.fraction} />
              ))}
            </div>
          </>
        )}

        {frequent.length > 0 && (
          <>
            <SectionLabel class="mt-8">پرکاربرد</SectionLabel>
            <div class="h-scroll">
              {frequent.map((item) => (
                <button
                  type="button"
                  key={`${item.book}-${item.section}`}
                  class="frequent-card"
                  onClick={() => navigate(routes.reader(item.book, item.section))}
                >
                  <span class="frequent-title">{item.title}</span>
                  <span class="frequent-meta">
                    <span>{workOf(bookById(item.book)!).title}</span>
                    <b>{fa(item.visits!)} بار</b>
                  </span>
                </button>
              ))}
            </div>
          </>
        )}

        <SectionLabel class="mt-8">کتابخانه</SectionLabel>
        {WORKS.map((work) => (
          <BookCard key={work.id} work={work} selected={editionOf(settings, work.id)} tocs={tocs} progress={user.progress} />
        ))}

        <div class="quick-links">
          <button type="button" class="quick-link" onClick={() => navigate(routes.bookmarks())}>
            <Icon name="bookmarkOutline" />
            <span>نشانه‌ها</span>
          </button>
          <a class="quick-link" href={CHANNEL_URL} target="_blank" rel="noopener">
            <Icon name="campaign" />
            <span>کانال صادقین در ایتا</span>
          </a>
          {isAndroid && (
            <a class="quick-link quick-link-wide" href={ANDROID_APK} download>
              <Icon name="download" />
              <span>دانلود نسخهٔ اندروید</span>
            </a>
          )}
        </div>

        <OfflineStatus />
        <p class="version">نسخهٔ {fa(__APP_VERSION__)}</p>
      </div>
    </main>
  )
}

function Hero() {
  return (
    <header class="hero">
      <img class="hero-img" src={asset('img/portrait.jpg')} alt="" width="900" height="900" decoding="async" fetchpriority="high" />
      <div class="hero-shade" />
      <div class="hero-actions">
        <button type="button" class="hero-icon" aria-label="تنظیمات" title="تنظیمات" onClick={() => navigate(routes.settings())}>
          <Icon name="settings" />
        </button>
        <button type="button" class="hero-icon" aria-label="دربارهٔ برنامه" title="دربارهٔ برنامه" onClick={() => navigate(routes.about())}>
          <Icon name="info" />
        </button>
      </div>
      <div class="hero-text">
        <h1>{APP_NAME}</h1>
        <p>آثار و سیرهٔ عالم ربانی آیت‌الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه)</p>
      </div>
    </header>
  )
}

/**
 * «منتخب من»: the sections the reader starred — typically the supplications they recite daily —
 * one tap away, plus a button to read them all in a row.
 */
function FavoritesShelf({ items }: { items: ShelfItem[] }) {
  return (
    <section class="favorites-shelf">
      <div class="shelf-head">
        <SectionLabel>منتخب من</SectionLabel>
        {items.length > 0 && (
          <button type="button" class="btn btn-text" onClick={() => navigate(routes.favorites())}>
            همه و ترتیب
          </button>
        )}
      </div>
      {items.length === 0 ? (
        <div class="hint-card">
          <Icon name="starOutline" />
          <p>دعاهای روزانه‌تان را با ستاره ☆ منتخب کنید تا همیشه یک لمس فاصله داشته باشند.</p>
        </div>
      ) : (
        <div class="card fav-card">
          {items.slice(0, HOME_FAVORITES).map((item) => (
            <button
              type="button"
              key={`${item.book}-${item.section}`}
              class="fav-row"
              onClick={() => navigate(routes.reader(item.book, item.section, { favorites: true }))}
            >
              <Icon name="star" class="gold" />
              <span class="fav-text">
                <span class="fav-title">{item.title}</span>
                <span class="fav-meta">{[item.group, workOf(bookById(item.book)!).title].filter(Boolean).join(' · ')}</span>
              </span>
              <Icon name="chevronEnd" class="muted" />
            </button>
          ))}
          <button
            type="button"
            class="btn btn-tonal btn-block"
            onClick={() => navigate(routes.reader(items[0].book, items[0].section, { favorites: true }))}
          >
            <Icon name="playlist" size={20} />
            خواندن پشت‌سرهم
          </button>
        </div>
      )}
    </section>
  )
}

function ContinueCard({ progress, title, fraction }: { progress: Progress; title: string; fraction: number }) {
  const book = bookById(progress.book)!
  return (
    <button
      type="button"
      class="continue-card"
      onClick={() => navigate(routes.reader(progress.book, progress.section, { paragraph: progress.paragraph }))}
    >
      <BookCover book={book} width={52} />
      <span class="continue-text">
        <span class="continue-book">{bookLabel(book)}</span>
        <span class="continue-title">{title}</span>
        <span class="progress" style={`--value:${Math.round(fraction * 100)}%`} />
      </span>
    </button>
  )
}

function BookCard(props: { work: Work; selected: BookId; tocs: Map<BookId, TableOfContents> | undefined; progress: Progress[] }) {
  const { work, selected, tocs } = props
  const book = bookById(selected)!
  const progress = props.progress.find((p) => p.book === selected)
  const start = () => {
    if (progress) navigate(routes.reader(selected, progress.section, { paragraph: progress.paragraph }))
    else {
      const first = tocs?.get(selected)?.readable[0]
      if (first) navigate(routes.reader(selected, first.id))
    }
  }
  return (
    <article class="card book-card">
      <div class="book-card-top">
        <BookCover book={book} width={104} onClick={() => navigate(routes.toc(selected))} />
        <div class="book-card-info">
          <h3>{work.title}</h3>
          <p>{work.description}</p>
          {book.paired ? (
            <TranslationToggle />
          ) : (
            <Segmented
              label={`نسخهٔ ${work.title}`}
              options={editionsOf(work.id).map((b) => ({ id: b.id, label: b.edition }))}
              value={selected}
              onChange={(id) => setSetting('safinehEdition', id as BookId)}
            />
          )}
        </div>
      </div>
      <div class="book-card-actions">
        <button type="button" class="btn btn-filled" onClick={() => navigate(routes.toc(selected))}>
          <Icon name="menuBook" size={18} />
          فهرست کتاب
        </button>
        <button type="button" class="btn btn-outlined" onClick={start}>
          {progress ? 'ادامهٔ مطالعه' : 'شروع مطالعه'}
        </button>
      </div>
    </article>
  )
}
