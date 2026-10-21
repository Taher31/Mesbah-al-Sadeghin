import { useState } from 'preact/hooks'
import { WORKS, bookById, bookLabel, type WorkId } from '../lib/books'
import { useAllTocs } from '../lib/data'
import { navigate, routes } from '../lib/router'
import { SECTION_LEVEL, removeBookmark, restoreBookmark, updateNote, useStore, userStore, type Bookmark } from '../lib/store'
import { toast } from '../lib/util'
import { Chip, Dialog, EmptyState, IconButton, TopBar } from '../ui/common'

export function Bookmarks() {
  const user = useStore(userStore)
  const { data: tocs } = useAllTocs()
  const [work, setWork] = useState<WorkId | null>(null)
  const [editing, setEditing] = useState<Bookmark | null>(null)

  const shown = user.bookmarks.filter((b) => work === null || bookById(b.book)!.work === work)

  return (
    <main class="page">
      <TopBar title="نشانه‌ها" />
      <div class="content">
        {user.bookmarks.length === 0 ? (
          <EmptyState
            icon="bookmarkOutline"
            title="هنوز نشانه‌ای ندارید"
            body="در صفحهٔ مطالعه، روی یک بند بزنید و «نشانه‌گذاری این بند» را انتخاب کنید."
          />
        ) : (
          <>
            <div class="chip-row chip-row-pad">
              <Chip selected={work === null} onClick={() => setWork(null)}>
                همهٔ کتاب‌ها
              </Chip>
              {WORKS.map((w) => (
                <Chip selected={work === w.id} onClick={() => setWork(w.id)}>
                  {w.title}
                </Chip>
              ))}
            </div>
            <ul class="bookmark-list">
              {shown.map((b) => (
                <li key={b.id} class="card bookmark">
                  <button
                    type="button"
                    class="bookmark-open"
                    onClick={() =>
                      navigate(routes.reader(b.book, b.section, b.paragraph !== SECTION_LEVEL ? { paragraph: b.paragraph } : {}))
                    }
                  >
                    <span class="hit-book">{bookLabel(bookById(b.book)!)}</span>
                    <span class="hit-title">{tocs?.get(b.book)?.get(b.section)?.title ?? ''}</span>
                    {b.excerpt.trim() && <span class="bookmark-excerpt">{b.excerpt}</span>}
                    {b.note && <span class="bookmark-note">{b.note}</span>}
                  </button>
                  <div class="bookmark-actions">
                    <IconButton icon="editNote" label="یادداشت" onClick={() => setEditing(b)} />
                    <IconButton
                      icon="delete"
                      label="حذف"
                      class="muted"
                      onClick={() => {
                        removeBookmark(b.id)
                        toast('نشانه حذف شد', { label: 'بازگردانی', run: () => restoreBookmark(b) })
                      }}
                    />
                  </div>
                </li>
              ))}
            </ul>
          </>
        )}
      </div>
      {editing && <NoteDialog bookmark={editing} onClose={() => setEditing(null)} />}
    </main>
  )
}

function NoteDialog({ bookmark, onClose }: { bookmark: Bookmark; onClose: () => void }) {
  const [text, setText] = useState(bookmark.note ?? '')
  return (
    <Dialog
      title="یادداشت"
      onClose={onClose}
      actions={
        <>
          <button type="button" class="btn btn-text" onClick={onClose}>
            انصراف
          </button>
          <button
            type="button"
            class="btn btn-text"
            onClick={() => {
              updateNote(bookmark.id, text)
              onClose()
            }}
          >
            ذخیره
          </button>
        </>
      }
    >
      <textarea
        class="note-input"
        rows={4}
        placeholder="یادداشت شما دربارهٔ این بند…"
        value={text}
        onInput={(e) => setText((e.target as HTMLTextAreaElement).value)}
        autoFocus
      />
    </Dialog>
  )
}
