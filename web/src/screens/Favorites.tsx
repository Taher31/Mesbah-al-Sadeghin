import { bookById, bookLabel } from '../lib/books'
import { useAllTocs } from '../lib/data'
import { navigate, routes } from '../lib/router'
import { moveFavorite, restoreFavorite, toggleFavorite, useStore, userStore } from '../lib/store'
import { toast } from '../lib/util'
import { EmptyState, IconButton, LoadError, Loading, TopBar } from '../ui/common'
import { Icon } from '../ui/icons'
import { num, t } from '../lib/i18n'

export function Favorites() {
  const user = useStore(userStore)
  const { data: tocs, error, retry } = useAllTocs()

  const items = tocs
    ? user.favorites.flatMap((f, index) => {
        const toc = tocs.get(f.book)
        const entry = toc?.get(f.section)
        return toc && entry ? [{ fav: f, index, title: entry.title, group: toc.pathTo(f.section).pop()?.title }] : []
      })
    : null

  return (
    <main class="page">
      <TopBar title={t('منتخب من')} />
      <div class="content">
        {error && <LoadError retry={retry} />}
        {!error && !items && <Loading />}
        {items && items.length === 0 && (
          <EmptyState
            icon="starOutline"
            title={t('هنوز چیزی منتخب نکرده‌اید')}
            body={t('هنگام مطالعهٔ هر دعا، ستارهٔ بالای صفحه را بزنید تا اینجا بیاید؛ مثلاً دعاهایی که هر روز می‌خوانید.')}
          />
        )}
        {items && items.length > 0 && (
          <>
            <p class="lead">{t('دعاها و بخش‌هایی که همیشه دم دستتان است')}</p>
            <ol class="fav-list">
              {items.map((item, i) => (
                <li key={`${item.fav.book}-${item.fav.section}`} class="card fav-item">
                  <button
                    type="button"
                    class="fav-open"
                    // In the book, to page on from it; the button below walks the list.
                    onClick={() => navigate(routes.reader(item.fav.book, item.fav.section))}
                  >
                    <span class="fav-num">{num(i + 1)}</span>
                    <span class="fav-text">
                      <span class="fav-title" dir="auto">{item.title}</span>
                      <span class="fav-meta" dir="auto">{[item.group, bookLabel(bookById(item.fav.book)!)].filter(Boolean).join(' · ')}</span>
                    </span>
                  </button>
                  <span class="fav-move">
                    <IconButton icon="up" label={t('بالاتر')} disabled={i === 0} onClick={() => moveFavorite(item.index, items[i - 1].index)} />
                    <IconButton
                      icon="down"
                      label={t('پایین‌تر')}
                      disabled={i === items.length - 1}
                      onClick={() => moveFavorite(item.index, items[i + 1].index)}
                    />
                  </span>
                  <IconButton
                    icon="delete"
                    label={t('حذف')}
                    class="muted"
                    onClick={() => {
                      toggleFavorite(item.fav.book, item.fav.section)
                      toast('از «منتخب من» حذف شد', { label: t('بازگردانی'), run: () => restoreFavorite(item.fav, item.index) })
                    }}
                  />
                </li>
              ))}
            </ol>
            <button
              type="button"
              class="fab"
              onClick={() => navigate(routes.reader(items[0].fav.book, items[0].fav.section, { favorites: true }))}
            >
              <Icon name="playlist" />
              {t('خواندن پشت‌سرهم')}
            </button>
          </>
        )}
      </div>
    </main>
  )
}
